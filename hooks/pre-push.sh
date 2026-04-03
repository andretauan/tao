#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# pre-push.sh — TAO push protection (LOCK 2)
# ═══════════════════════════════════════════════════════════════
# Blocks: push to main/master, force push.
# Called by .git/hooks/pre-push (installed by install-hooks.sh).
# Exit 0 = allow push, Exit 1 = block push.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG=".github/tao/tao.config.json"
MAIN_BRANCH="main"

# ─── Read main_branch from config ────────────────────────────
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

# ─── Detect --force / -f via parent process args ─────────────
if ps -o args= -p $PPID 2>/dev/null | grep -qE '\s-f\b|\s--force\b|\s--force-with-lease\b'; then
  echo ""
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: Force push é PROIBIDO (LOCK 2).${NC}"
  echo -e "${YELLOW}  git push --force e --force-with-lease são proibidos pelo TAO.${NC}"
  echo ""
  exit 1
fi

# ─── Check target branch from refspecs (stdin) ───────────────
BLOCKED=0
while read -r local_ref local_sha remote_ref remote_sha; do
  TARGET_BRANCH=$(echo "$remote_ref" | sed 's|^refs/heads/||')

  if [ "$TARGET_BRANCH" = "$MAIN_BRANCH" ] || [ "$TARGET_BRANCH" = "master" ]; then
    echo ""
    echo -e "${RED}✗ BLOQUEADO / BLOCKED: Push para '${TARGET_BRANCH}' é PROIBIDO (LOCK 2).${NC}"
    echo -e "${YELLOW}  Faça push na branch dev: git push origin dev${NC}"
    echo -e "${YELLOW}  / Push to dev branch: git push origin dev${NC}"
    echo ""
    BLOCKED=1
  fi
done

[ "$BLOCKED" -eq 1 ] && exit 1

exit 0
