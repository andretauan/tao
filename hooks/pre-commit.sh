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

CONFIG=".github/tao/tao.config.json"
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

# ─── Result ───────────────────────────────────────────────────
if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}✗ Pre-commit blocked: ${ERRORS} file(s) with errors.${NC}"
  echo -e "${YELLOW}Fix the errors and try again.${NC}"
  exit 1
fi

exit 0
