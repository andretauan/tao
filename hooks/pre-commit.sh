#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# pre-commit.sh — TAO pre-commit pipeline orchestrator
# ═══════════════════════════════════════════════════════════════
# Modular pipeline: reads tao.config.json for lint commands,
# runs syntax check on staged files by extension.
# Enforces: LOCK 2 (branch), LOCK 3 (destructive), LOCK 5 (pause),
#           R4 (timestamp), R6 (context freshness), ABEX (security).
#
# Called by .git/hooks/pre-commit (installed by install-hooks.sh).
# Exit 0 = allow commit, Exit 1 = block commit.

set -e

CONFIG=".github/tao/tao.config.json"
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
ERRORS=0

# ─── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── LOCK 5: .tao-pause check ────────────────────────────────
if [ -f "$WORKSPACE_DIR/.tao-pause" ] || [ -f ".tao-pause" ]; then
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: .tao-pause existe — todas as operações pausadas (LOCK 5).${NC}"
  echo -e "${YELLOW}  Remova o arquivo .tao-pause para retomar. / Remove .tao-pause to resume.${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ─── Get staged files ────────────────────────────────────────
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# ─── Read lint commands from config ───────────────────────────
get_lint_command() {
  local ext="$1"
  if [ -f "$CONFIG" ]; then
    python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    cmds = c.get('lint_commands', {})
    print(cmds.get(sys.argv[2], ''))
except:
    print('')
" "$CONFIG" "$ext" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# ─── Lint each staged file ───────────────────────────────────
while IFS= read -r file; do
  [ ! -f "$file" ] && continue

  # Extract extension
  ext=".${file##*.}"

  # Get lint command for this extension
  lint_cmd=$(get_lint_command "$ext")

  if [ -n "$lint_cmd" ]; then
    # Replace {file} placeholder with actual file path
    cmd="${lint_cmd//\{file\}/$file}"

    if ! bash -c "$cmd" > /dev/null 2>&1; then
      echo -e "${RED}✗ Lint failed: ${file}${NC}"
      bash -c "$cmd" 2>&1 | head -5
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}✓ ${file}${NC}"
    fi
  fi
done <<< "$STAGED_FILES"

# ─── Branch protection (LOCK 2) ──────────────────────────────
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
if [ -n "$CURRENT_BRANCH" ]; then
  MAIN_BRANCH="main"
  if [ -f "$CONFIG" ]; then
    MAIN_BRANCH=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('git',{}).get('main_branch','main'))
except:
    print('main')
" "$CONFIG" 2>/dev/null) || MAIN_BRANCH="main"
  fi

  if [ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo -e "${RED}✗ BLOCKED: Direct commit to '${CURRENT_BRANCH}' is FORBIDDEN.${NC}"
    echo -e "${YELLOW}  Switch to dev branch: git checkout dev${NC}"
    ERRORS=$((ERRORS + 1))
  fi
fi

# ─── CONTEXT.md freshness check (R6) ─────────────────────────
CONTEXT_FILE=".github/tao/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  if echo "$STAGED_FILES" | grep -qE '\.py$|\.ts$|\.js$|\.php$|\.rb$|\.go$|\.rs$|\.vue$|\.jsx$|\.tsx$'; then
    if ! echo "$STAGED_FILES" | grep -q "$CONTEXT_FILE"; then
      echo -e "${YELLOW}⚠  Code files staged but CONTEXT.md not updated (R6 violation)${NC}"
      echo -e "${YELLOW}   Agent must update .github/tao/CONTEXT.md after every file edit.${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ─── LOCK 3: Destructive pattern scan ────────────────────────
DESTRUCTIVE=$(git diff --cached -U0 2>/dev/null | grep -E '^\+.*(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE|DELETE\s+FROM\s+\S+\s*;|rm\s+-rf\s+/)' | grep -v '^+++' | head -5 || true)
if [ -n "$DESTRUCTIVE" ]; then
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: Padrão destrutivo no código (LOCK 3):${NC}"
  echo "$DESTRUCTIVE" | head -3
  echo -e "${YELLOW}  Remova comandos destrutivos antes de commitar.${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ─── R4: Timestamp validation for CHANGELOG.md ───────────────
if echo "$STAGED_FILES" | grep -q "CHANGELOG.md"; then
  CHANGELOG_FILE=$(echo "$STAGED_FILES" | grep "CHANGELOG.md" | head -1)
  if [ -f "$CHANGELOG_FILE" ]; then
    LATEST_DATE=$(grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}\]' "$CHANGELOG_FILE" 2>/dev/null | head -1 || true)
    if [ -z "$LATEST_DATE" ]; then
      echo -e "${YELLOW}⚠  CHANGELOG.md staged sem timestamp [YYYY-MM-DD HH:MM] (R4)${NC}"
      echo -e "${YELLOW}   / CHANGELOG.md staged without [YYYY-MM-DD HH:MM] timestamp${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ─── ABEX security scan (L0 enforcement) ─────────────────────
ABEX_ENABLED="true"
if [ -f "$CONFIG" ]; then
  ABEX_ENABLED=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    val = c.get('compliance', {}).get('abex_enabled', True)
    print('true' if val else 'false')
except:
    print('true')
" "$CONFIG" 2>/dev/null) || ABEX_ENABLED="true"
fi

# Locate abex-gate.sh relative to this script or installed location
ABEX_SCRIPT=""
for candidate in \
  "$WORKSPACE_DIR/.github/tao/scripts/abex-gate.sh" \
  "$(dirname "$0")/../../scripts/abex-gate.sh" \
  ".github/tao/scripts/abex-gate.sh"; do
  if [ -x "$candidate" ]; then
    ABEX_SCRIPT="$candidate"
    break
  fi
done

if [ "$ABEX_ENABLED" = "true" ] && [ -n "$ABEX_SCRIPT" ]; then
  while IFS= read -r staged_file; do
    [ ! -f "$staged_file" ] && continue
    case "$staged_file" in
      *.py|*.js|*.ts|*.jsx|*.tsx|*.php|*.rb|*.go|*.rs|*.java|*.c|*.cpp|*.cs)
        if ! bash "$ABEX_SCRIPT" "$staged_file" > /dev/null 2>&1; then
          echo -e "${RED}✗ ABEX: Problema de segurança / Security issue em: ${staged_file}${NC}"
          bash "$ABEX_SCRIPT" "$staged_file" 2>&1 | grep -E '^\[BLOCK\]' | head -3
          ERRORS=$((ERRORS + 1))
        fi
        ;;
    esac
  done <<< "$STAGED_FILES"
fi

# ─── Result ───────────────────────────────────────────────────
if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}✗ Pre-commit blocked: ${ERRORS} file(s) with errors.${NC}"
  echo -e "${YELLOW}Fix the errors and try again.${NC}"
  exit 1
fi

exit 0
