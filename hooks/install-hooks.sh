#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# install-hooks.sh — Install git hooks for TAO projects
# ═══════════════════════════════════════════════════════════════
# Called by install.sh during setup, or manually.
# Installs: pre-commit hook (lint + syntax check)
#
# Usage: bash scripts/install-hooks.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ─── Find git root ───────────────────────────────────────────
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || {
  echo -e "${RED}Error: not a git repository. Initialize git first: git init${NC}"
  exit 1
}

HOOKS_DIR="$GIT_DIR/hooks"
mkdir -p "$HOOKS_DIR"

# ─── Install pre-commit ──────────────────────────────────────
PRE_COMMIT="$HOOKS_DIR/pre-commit"

if [ -f "$PRE_COMMIT" ] && ! grep -q "TAO pre-commit" "$PRE_COMMIT" 2>/dev/null; then
  echo -e "${YELLOW}⚠  Pre-commit hook already exists (not TAO). Skipping.${NC}"
  echo -e "   To override, remove $PRE_COMMIT and re-run."
else
  cat > "$PRE_COMMIT" << 'HOOK'
#!/usr/bin/env bash
# TAO pre-commit — runs lint on staged files
# Installed by install-hooks.sh

if [ -f scripts/pre-commit.sh ]; then
  bash scripts/pre-commit.sh
  exit $?
fi

# Fallback: if pre-commit.sh doesn't exist, pass through
exit 0
HOOK
  chmod +x "$PRE_COMMIT" 2>/dev/null || true
  echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
fi

# ─── Install post-commit (auto-push) ─────────────────────────
POST_COMMIT="$HOOKS_DIR/post-commit"

if [ -f "$POST_COMMIT" ] && ! grep -q "TAO post-commit" "$POST_COMMIT" 2>/dev/null; then
  echo -e "${YELLOW}⚠  Post-commit hook already exists (not TAO). Skipping.${NC}"
else
  cat > "$POST_COMMIT" << 'HOOK'
#!/usr/bin/env bash
# TAO post-commit — auto-push if configured
# Installed by install-hooks.sh

CONFIG="tao.config.json"
if [ -f "$CONFIG" ]; then
  AUTO_PUSH=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG'))
    print('true' if c.get('git',{}).get('auto_push', False) else 'false')
except:
    print('false')
" 2>/dev/null) || AUTO_PUSH="false"

  if [ "$AUTO_PUSH" = "true" ]; then
    BRANCH=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG'))
    print(c.get('git',{}).get('dev_branch', 'dev'))
except:
    print('dev')
" 2>/dev/null) || BRANCH="dev"

    CURRENT=$(git branch --show-current 2>/dev/null)
    if [ "$CURRENT" = "$BRANCH" ]; then
      git push origin "$BRANCH" 2>/dev/null || true
    fi
  fi
fi
HOOK
  chmod +x "$POST_COMMIT" 2>/dev/null || true
  echo -e "${GREEN}✅ Post-commit hook installed (auto-push)${NC}"
fi

echo -e "${GREEN}Git hooks installation complete.${NC}"
