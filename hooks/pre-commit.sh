#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# pre-commit.sh — TAO pre-commit pipeline orchestrator
# ═══════════════════════════════════════════════════════════════
# Modular pipeline: reads tao.config.json for lint commands,
# runs syntax check on staged files by extension.
#
# Called by .git/hooks/pre-commit (installed by install-hooks.sh).
# Exit 0 = allow commit, Exit 1 = block commit.

set -e

CONFIG="tao.config.json"
ERRORS=0

# ─── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── Get staged files ────────────────────────────────────────
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# ─── Read lint commands from config ───────────────────────────
get_lint_command() {
  local ext="$1"
  if [ -f "$CONFIG" ]; then
    python3 -c "
import json
try:
    c = json.load(open('$CONFIG'))
    cmds = c.get('lint_commands', {})
    print(cmds.get('$ext', ''))
except:
    print('')
" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# ─── Lint each staged file ───────────────────────────────────
for file in $STAGED_FILES; do
  [ ! -f "$file" ] && continue

  # Extract extension
  ext=".${file##*.}"

  # Get lint command for this extension
  lint_cmd=$(get_lint_command "$ext")

  if [ -n "$lint_cmd" ]; then
    # Replace {file} placeholder with actual file path
    cmd="${lint_cmd//\{file\}/$file}"

    if ! eval "$cmd" > /dev/null 2>&1; then
      echo -e "${RED}✗ Lint failed: ${file}${NC}"
      eval "$cmd" 2>&1 | head -5
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}✓ ${file}${NC}"
    fi
  fi
done

# ─── Result ───────────────────────────────────────────────────
if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}✗ Pre-commit blocked: ${ERRORS} file(s) with errors.${NC}"
  echo -e "${YELLOW}Fix the errors and try again.${NC}"
  exit 1
fi

exit 0
