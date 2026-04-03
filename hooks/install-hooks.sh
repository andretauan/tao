#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# install-hooks.sh — Install git hooks for TAO projects
# ═══════════════════════════════════════════════════════════════
# Called by install.sh during setup, or manually.
# Installs: pre-commit, commit-msg, pre-push, post-commit
#
# Usage: bash .github/tao/scripts/install-hooks.sh

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

if [ -f .github/tao/scripts/pre-commit.sh ]; then
  bash .github/tao/scripts/pre-commit.sh
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

CONFIG=".github/tao/tao.config.json"
if [ -f "$CONFIG" ]; then
  _git_cfg=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG'))
    g = c.get('git',{})
    print('true' if g.get('auto_push', False) else 'false')
    print(g.get('dev_branch', 'dev'))
except:
    print('false')
    print('dev')
" 2>/dev/null) || _git_cfg=""
  AUTO_PUSH=$(echo "$_git_cfg" | sed -n '1p')
  BRANCH=$(echo "$_git_cfg" | sed -n '2p')
  : "${AUTO_PUSH:=false}"
  : "${BRANCH:=dev}"

  if [ "$AUTO_PUSH" = "true" ]; then
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

# ─── Install commit-msg (format validation) ──────────────────
COMMIT_MSG_HOOK="$HOOKS_DIR/commit-msg"

if [ -f "$COMMIT_MSG_HOOK" ] && ! grep -q "TAO commit-msg" "$COMMIT_MSG_HOOK" 2>/dev/null; then
  echo -e "${YELLOW}⚠  Commit-msg hook already exists (not TAO). Skipping.${NC}"
  echo -e "   To override, remove $COMMIT_MSG_HOOK and re-run."
else
  cat > "$COMMIT_MSG_HOOK" << 'HOOK'
#!/usr/bin/env bash
# TAO commit-msg — validate commit message format (LOCK 6)
# Installed by install-hooks.sh

if [ -f .github/tao/scripts/commit-msg.sh ]; then
  bash .github/tao/scripts/commit-msg.sh "$1"
  exit $?
fi

exit 0
HOOK
  chmod +x "$COMMIT_MSG_HOOK" 2>/dev/null || true
  echo -e "${GREEN}✅ Commit-msg hook installed (format validation)${NC}"
fi

# ─── Install pre-push (branch protection) ────────────────────
PRE_PUSH="$HOOKS_DIR/pre-push"

if [ -f "$PRE_PUSH" ] && ! grep -q "TAO pre-push" "$PRE_PUSH" 2>/dev/null; then
  echo -e "${YELLOW}⚠  Pre-push hook already exists (not TAO). Skipping.${NC}"
  echo -e "   To override, remove $PRE_PUSH and re-run."
else
  cat > "$PRE_PUSH" << 'HOOK'
#!/usr/bin/env bash
# TAO pre-push — block push to main + force push (LOCK 2)
# Installed by install-hooks.sh

if [ -f .github/tao/scripts/pre-push.sh ]; then
  bash .github/tao/scripts/pre-push.sh "$@"
  exit $?
fi

exit 0
HOOK
  chmod +x "$PRE_PUSH" 2>/dev/null || true
  echo -e "${GREEN}✅ Pre-push hook installed (branch protection)${NC}"
fi

echo -e "${GREEN}Git hooks installation complete.${NC}"
