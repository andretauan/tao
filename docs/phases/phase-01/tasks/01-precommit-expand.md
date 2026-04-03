# Task T01 — Expand pre-commit.sh: Full Enforcement Gate

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P0-HARD (L0)
**Depends on:** T04 (abex-gate.sh must exist)

---

## Objective

Expand pre-commit.sh with 4 new checks: destructive pattern scan (LOCK 3), .tao-pause check (LOCK 5), ABEX basic security patterns, and timestamp validation for CHANGELOG.md. These make violations IMPOSSIBLE at commit time.

## Gaps Fixed

- G03: No destructive pattern scan in pre-commit
- G04: No .tao-pause check in pre-commit
- G05: No timestamp validation in pre-commit
- G06: No ABEX in pre-commit

## Files to Read

- `hooks/pre-commit.sh` — current implementation (full file)
- `scripts/abex-gate.sh` — created in T04, will be called from here
- `tao.config.json.example` — compliance.abex_enabled flag

## Files to Edit

- `hooks/pre-commit.sh` — add 4 new check sections after existing checks

## Implementation

Add these sections to pre-commit.sh BEFORE the final result block:

### Check 1: .tao-pause (LOCK 5)
```bash
if [ -f "$WORKSPACE_DIR/.tao-pause" ] || [ -f ".tao-pause" ]; then
  echo -e "${RED}✗ BLOCKED: .tao-pause exists — all operations paused (LOCK 5).${NC}"
  ERRORS=$((ERRORS + 1))
fi
```

### Check 2: Destructive patterns in staged diffs (LOCK 3)
```bash
DESTRUCTIVE=$(git diff --cached -U0 2>/dev/null | grep -E '^\+.*(DROP\s+(TABLE|DATABASE)|TRUNCATE\s|DELETE\s+FROM\s+\S+\s*;|rm\s+-rf\s)' | head -5)
if [ -n "$DESTRUCTIVE" ]; then
  echo -e "${RED}✗ BLOCKED: Destructive pattern in staged code (LOCK 3):${NC}"
  echo "$DESTRUCTIVE" | head -3
  ERRORS=$((ERRORS + 1))
fi
```

### Check 3: Timestamp validation for CHANGELOG.md
```bash
if echo "$STAGED_FILES" | grep -q "CHANGELOG.md"; then
  CHANGELOG_FILE=$(echo "$STAGED_FILES" | grep "CHANGELOG.md" | head -1)
  if [ -f "$CHANGELOG_FILE" ]; then
    LATEST_DATE=$(grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}\]' "$CHANGELOG_FILE" | head -1 || true)
    if [ -z "$LATEST_DATE" ]; then
      echo -e "${YELLOW}⚠  CHANGELOG.md staged but latest entry has no [YYYY-MM-DD HH:MM] timestamp (R4)${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi
```

### Check 4: ABEX basic patterns (if abex_enabled)
```bash
ABEX_ENABLED="true"
if [ -f "$CONFIG" ]; then
  ABEX_ENABLED=$(python3 -c "..." "$CONFIG" 2>/dev/null) || ABEX_ENABLED="true"
fi
if [ "$ABEX_ENABLED" = "true" ] && [ -x ".github/tao/scripts/abex-gate.sh" ]; then
  for staged_file in $STAGED_FILES; do
    if [[ "$staged_file" =~ \.(py|js|ts|php|rb|go|rs|sh)$ ]]; then
      if ! bash .github/tao/scripts/abex-gate.sh "$staged_file" >/dev/null 2>&1; then
        echo -e "${RED}✗ ABEX: Security issue in ${staged_file}${NC}"
        bash .github/tao/scripts/abex-gate.sh "$staged_file" 2>&1 | head -5
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
fi
```

## Acceptance Criteria

- [ ] .tao-pause blocks commit
- [ ] DROP TABLE/rm -rf in staged diff blocks commit
- [ ] CHANGELOG.md without timestamp blocks commit
- [ ] ABEX patterns (from T04) block commit
- [ ] All existing pre-commit checks still work (lint, branch, R6)
- [ ] Both EN and PT-BR output messages
