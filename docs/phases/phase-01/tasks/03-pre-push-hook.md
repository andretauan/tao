# Task T03 — Create pre-push.sh: Block Push to Main + Force

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P0-HARD (L0)
**Depends on:** None

---

## Objective

Create a pre-push hook that blocks: (1) push to main/master branch, (2) `--force` flag. Read main_branch from tao.config.json. Update install-hooks.sh to install it.

## Gaps Fixed

- G02: No pre-push hook exists
- G07: --no-verify/--force bypass (partially)
- G22: Qi no real guard for main push
- G39: Post-commit auto-push has no pre-push guard

## Files to Read

- `hooks/install-hooks.sh` — current hook installation logic
- `tao.config.json.example` — git.main_branch value

## Files to Create

- `hooks/pre-push.sh` — NEW: push protection hook

## Files to Edit

- `hooks/install-hooks.sh` — add pre-push hook installation section

## Implementation

### pre-push.sh

```bash
#!/usr/bin/env bash
# TAO pre-push — branch protection (LOCK 2)
set -e

CONFIG=".github/tao/tao.config.json"
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

CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
REMOTE="$1"
# Read refspecs from stdin to detect target branch
while read local_ref local_sha remote_ref remote_sha; do
  TARGET_BRANCH=$(echo "$remote_ref" | sed 's|^refs/heads/||')
  if [ "$TARGET_BRANCH" = "$MAIN_BRANCH" ] || [ "$TARGET_BRANCH" = "master" ]; then
    echo "✗ BLOCKED: Push to '$TARGET_BRANCH' is FORBIDDEN (LOCK 2)."
    echo "  Push to dev branch instead: git push origin dev"
    exit 1
  fi
done

# Detect --force (check parent process args)
if ps -o args= -p $PPID 2>/dev/null | grep -q '\-\-force\|force-with-lease'; then
  echo "✗ BLOCKED: Force push is FORBIDDEN (LOCK 2)."
  exit 1
fi

exit 0
```

## Acceptance Criteria

- [ ] `git push origin main` → blocked
- [ ] `git push --force origin dev` → blocked
- [ ] `git push origin dev` → allowed
- [ ] Reads main_branch from tao.config.json
- [ ] install-hooks.sh installs the hook
