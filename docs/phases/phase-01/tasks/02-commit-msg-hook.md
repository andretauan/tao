# Task T02 — Create commit-msg.sh: Validate Commit Message Format

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P0-HARD (L0)
**Depends on:** None

---

## Objective

Create a commit-msg hook that validates the commit message format `tipo(escopo): desc` with max 72 chars. Update install-hooks.sh to install it.

## Gaps Fixed

- G01: No commit-msg hook — format is text-only

## Files to Read

- `hooks/install-hooks.sh` — current hook installation logic
- `hooks/pre-commit.sh` — reference for TAO hook conventions
- `tao.config.json.example` — commit_scopes array

## Files to Create

- `hooks/commit-msg.sh` — NEW: commit message validation

## Files to Edit

- `hooks/install-hooks.sh` — add commit-msg hook installation section

## Implementation

### commit-msg.sh

```bash
#!/usr/bin/env bash
# TAO commit-msg — validate conventional commit format
set -e

MSG_FILE="$1"
MSG=$(head -1 "$MSG_FILE")

# Regex: type(scope): description
PATTERN='^(feat|fix|refactor|docs|chore|hotfix|test)\([a-zA-Z0-9_-]+\): .+'

if ! echo "$MSG" | grep -qE "$PATTERN"; then
  echo "✗ BLOCKED: Invalid commit message format."
  echo "  Expected: type(scope): description"
  echo "  Types: feat | fix | refactor | docs | chore | hotfix | test"
  echo "  Got: $MSG"
  exit 1
fi

# Max 72 chars
if [ ${#MSG} -gt 72 ]; then
  echo "✗ BLOCKED: Commit message too long (${#MSG} chars, max 72)."
  exit 1
fi

exit 0
```

### install-hooks.sh addition

Add COMMIT_MSG section after pre-commit installation, same pattern.

## Acceptance Criteria

- [ ] `git commit -m "bad message"` → blocked
- [ ] `git commit -m "feat(core): good message"` → accepted
- [ ] Message > 72 chars → blocked
- [ ] install-hooks.sh installs the hook automatically
