#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# abex-gate.sh — ABEX Security Scanner (L0 enforcement)
# ═══════════════════════════════════════════════════════════════
# Detects common vulnerability patterns in source code.
# Called by: pre-commit.sh, abex-hook.sh
# Exit: 0 = PASS (no BLOCKs), 1 = BLOCK (found critical issues), 2 = config error
#
# Usage:
#   bash .github/tao/scripts/abex-gate.sh [file-or-dir]
#   bash .github/tao/scripts/abex-gate.sh src/
#   bash .github/tao/scripts/abex-gate.sh src/models/user.php

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"

# ─── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [[ "${NO_COLOR:-}" == "1" ]] || [[ "${TERM:-}" == "dumb" ]]; then
  RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ─── Config: check abex_enabled ─────────────────────────────────
check_abex_enabled() {
  # Search upward from CWD if not found at WORKSPACE_DIR
  local config=""
  if [ -f "$CONFIG_FILE" ]; then
    config="$CONFIG_FILE"
  else
    local dir
    dir="$(pwd)"
    while [ "$dir" != "/" ]; do
      if [ -f "$dir/.github/tao/tao.config.json" ]; then
        config="$dir/.github/tao/tao.config.json"
        break
      fi
      dir="$(dirname "$dir")"
    done
  fi

  if [ -z "$config" ]; then
    # No config found — default: enabled
    return 0
  fi

  local enabled
  enabled=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    val = c.get('compliance', {}).get('abex_enabled', True)
    print('true' if val else 'false')
except Exception as e:
    print('true')
" "$config" 2>/dev/null) || enabled="true"

  if [ "$enabled" = "false" ]; then
    echo "ABEX: disabled in config"
    exit 0
  fi
}

# ─── File extension filter ───────────────────────────────────────
is_code_file() {
  local file="$1"
  case "$file" in
    *.php|*.py|*.js|*.ts|*.jsx|*.tsx|*.java|*.go|*.rs|*.rb|*.sh|*.bash|*.c|*.cpp|*.cs)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# ─── Skip directories ────────────────────────────────────────────
in_skip_dir() {
  local file="$1"
  case "$file" in
    */node_modules/*|*/vendor/*|*/.git/*|*/venv/*|*/env/*|*/__pycache__/*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# ─── Test file detection (for WARN-only skip) ────────────────────
is_test_file() {
  local file="$1"
  local base
  base="$(basename "$file")"
  case "$base" in
    *.test.*|*.spec.*|test_*.py|*_test.go)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# ─── Counters ────────────────────────────────────────────────────
BLOCK_COUNT=0
WARN_COUNT=0
FILE_COUNT=0
ISSUE_COUNT=0

# ─── Print finding ───────────────────────────────────────────────
print_finding() {
  local severity="$1"   # BLOCK | WARN
  local category="$2"
  local file="$3"
  local lineno="$4"
  local context_line="$5"

  # Trim leading/trailing whitespace from context
  context_line="${context_line#"${context_line%%[![:space:]]*}"}"

  if [ "$severity" = "BLOCK" ]; then
    echo -e ""
    echo -e "${RED}${BOLD}[BLOCK]${NC} ${BOLD}${category}${NC}"
    echo -e "  File: ${file}:${lineno}"
    echo -e "  Context: ...${context_line}..."
    BLOCK_COUNT=$((BLOCK_COUNT + 1))
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  else
    echo -e ""
    echo -e "${YELLOW}[WARN] ${NC} ${category}"
    echo -e "  File: ${file}:${lineno}"
    echo -e "  Context: ...${context_line}..."
    WARN_COUNT=$((WARN_COUNT + 1))
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  fi
}

# ─── Scan single file ────────────────────────────────────────────
scan_file() {
  local file="$1"
  local is_test=false
  is_test_file "$file" && is_test=true

  # Skip binary files
  if file "$file" 2>/dev/null | grep -qE 'binary|executable|ELF'; then
    return
  fi

  FILE_COUNT=$((FILE_COUNT + 1))

  # ── Helper: run one pattern check ─────────────────────────────
  # usage: check_pattern SEVERITY "CATEGORY" file pattern
  check_pattern() {
    local sev="$1"
    local cat="$2"
    local f="$3"
    local pat="$4"

    # For WARN severity, skip test files
    if [ "$sev" = "WARN" ] && [ "$is_test" = "true" ]; then
      return
    fi

    # grep -n: line numbers; -E: extended regex; -i: case-insensitive where appropriate
    # We pipe through a filter to remove:
    #   1. Lines starting with comment markers (# // * <!--)
    #   2. Lines containing # abex-ignore
    local matches
    matches=$(grep -nE "$pat" "$f" 2>/dev/null || true)

    if [ -z "$matches" ]; then
      return
    fi

    while IFS= read -r match_line; do
      [ -z "$match_line" ] && continue

      local lineno
      lineno="${match_line%%:*}"
      local line_content
      line_content="${match_line#*:}"

      # Skip comment lines
      local trimmed="${line_content#"${line_content%%[![:space:]]*}"}"
      case "$trimmed" in
        '#'*|'//'*|'*'*|'<!--'*)
          continue ;;
      esac

      # Skip abex-ignore annotation
      if echo "$line_content" | grep -q 'abex-ignore'; then
        continue
      fi

      print_finding "$sev" "$cat" "$file" "$lineno" "$line_content"
    done <<< "$matches"
  }

  # ════════════════════════════════════════════════════════════
  # BLOCK patterns
  # ════════════════════════════════════════════════════════════

  # SQL Injection — string concatenation in queries (multi-language)
  check_pattern "BLOCK" "SQL Injection — string concatenation in query" "$file" \
    '"SELECT[^"]*\+|"SELECT[^"]*\$\{|"SELECT[^"]*\.format|f"[^"]*SELECT|mysqli[^;]*\.\$'

  # SQL Injection — PHP mysql/mysqli direct variable
  check_pattern "BLOCK" "SQL Injection — PHP unsanitized query variable" "$file" \
    '\$[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*mysql_query[^;]*\.\$|\$[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*mysqli_query[^;]*\.\$|mysql_query\s*\([^)]*\.\$|mysqli_query\s*\([^)]*\.\$'

  # SQL Injection — Python cursor.execute with unsanitized input
  check_pattern "BLOCK" "SQL Injection — Python unsanitized cursor.execute" "$file" \
    'cursor\.execute\s*\([^)]*%[^)]*%|cursor\.execute\s*\([^)]*\.format|cursor\.execute\s*\(f"'

  # Code Injection — eval/exec with variable
  check_pattern "BLOCK" "Code Injection — eval/exec with variable input" "$file" \
    'eval\s*\(\s*\$[a-zA-Z_]|eval\s*\(\s*[a-zA-Z_][a-zA-Z0-9_]*\s*[+)]|exec\s*\(\s*[a-zA-Z_][a-zA-Z0-9_]*\s*[+)]|exec\s*\(\s*\$'

  # Command Injection — os.system / subprocess with concatenation
  check_pattern "BLOCK" "Command Injection — unsanitized shell execution" "$file" \
    'os\.system\s*\(\s*[a-zA-Z_$]|subprocess\.[a-zA-Z_]+\s*\([^)]*\+[^)]*\)|shell_exec\s*\(\s*\$|system\s*\(\s*\$'

  # Hardcoded Secrets
  check_pattern "BLOCK" "Hardcoded Secret — password/api_key/token/secret in source" "$file" \
    'password\s*=\s*["'"'"'][^"'"'"']{4,}|api_key\s*=\s*["'"'"'][^"'"'"']+|secret\s*=\s*["'"'"'][^"'"'"']{4,}|token\s*=\s*["'"'"'][^"'"'"']{4,}|AWS_SECRET\s*=\s*["'"'"']|private_key\s*=\s*["'"'"']'

  # ════════════════════════════════════════════════════════════
  # WARN patterns
  # ════════════════════════════════════════════════════════════

  # XSS — innerHTML / document.write / .html() with variable
  check_pattern "WARN" "XSS — potential unsafe DOM write" "$file" \
    'innerHTML\s*=\s*[^"'"'"' ;]|document\.write\s*\(\s*[^"'"'"']|\.html\s*\(\s*[a-zA-Z$_]'

  # Empty catch block
  check_pattern "WARN" "Empty catch block — swallowed exception" "$file" \
    'catch\s*[({][^)]*[)}]\s*\{\s*\}'

  # Path Traversal
  check_pattern "WARN" "Path Traversal — unsanitized file path" "$file" \
    '\.\./.*open\s*\(|fopen\s*\(\s*\$|file_get_contents\s*\(\s*\$'
}

# ─── Collect files to scan ───────────────────────────────────────
collect_files() {
  local target="$1"

  if [ -f "$target" ]; then
    # Single file
    local abs_target
    abs_target="$(realpath "$target" 2>/dev/null || echo "$target")"
    # Skip self
    if [ "$abs_target" = "$SCRIPT_PATH" ]; then
      return
    fi
    if is_code_file "$target" && ! in_skip_dir "$target"; then
      scan_file "$target"
    fi
  elif [ -d "$target" ]; then
    # Recursive directory scan
    while IFS= read -r -d '' f; do
      local abs_f
      abs_f="$(realpath "$f" 2>/dev/null || echo "$f")"

      # Skip self
      [ "$abs_f" = "$SCRIPT_PATH" ] && continue

      in_skip_dir "$f" && continue
      is_code_file "$f" || continue

      # Skip binary
      file "$f" 2>/dev/null | grep -qE 'binary|executable|ELF' && continue

      scan_file "$f"
    done < <(find "$target" -type f -print0 2>/dev/null)
  else
    echo -e "${RED}ERROR: '$target' is not a valid file or directory.${NC}" >&2
    exit 2
  fi
}

# ════════════════════════════════════════════════════════════════
# MAIN
# ════════════════════════════════════════════════════════════════

# Check abex_enabled before doing anything
check_abex_enabled

# ─── Header ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  TAO — ABEX Security Scanner${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"

# ─── Resolve scan target ─────────────────────────────────────────
TARGET="${1:-$(pwd)}"

# Validate target
if [ ! -e "$TARGET" ]; then
  echo -e "${RED}ERROR: Target does not exist: $TARGET${NC}" >&2
  exit 2
fi

# Make absolute
if [[ "$TARGET" != /* ]]; then
  TARGET="$(pwd)/$TARGET"
fi

collect_files "$TARGET"

# ─── Summary ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}─────────────────────────────────────────────────────${NC}"

if [ "$BLOCK_COUNT" -gt 0 ]; then
  echo -e "${RED}${BOLD}ABEX Summary: ${BLOCK_COUNT} BLOCK(s), ${WARN_COUNT} WARN(s)${NC}"
else
  echo -e "${GREEN}${BOLD}ABEX Summary: ${BLOCK_COUNT} BLOCK(s), ${WARN_COUNT} WARN(s)${NC}"
fi

echo -e "Files scanned: ${FILE_COUNT} | Issues: ${ISSUE_COUNT}"
echo -e "${BOLD}─────────────────────────────────────────────────────${NC}"
echo ""

# ─── Exit code ───────────────────────────────────────────────────
if [ "$BLOCK_COUNT" -gt 0 ]; then
  exit 1
fi

exit 0
