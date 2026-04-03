# Task T05 — Expand context-hook.sh: Inject Real Data

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P1-HOOKS (L1)
**Depends on:** None

---

## Objective

Expand context-hook.sh to inject REAL data at session start: current timestamp, skills list, lint status, hook status, and pre-computed compliance data. The agent receives FACTS, not templates to guess.

## Gaps Fixed

- G08: No real timestamp injected
- G09: No skills list injected
- G10: No compliance data pre-computed

## Files to Read

- `hooks/context-hook.sh` — current implementation (full file)
- `tao.config.json.example` — compliance section, lint_commands
- `templates/pt-br/INDEX.md` or `templates/en/INDEX.md` — skill list format

## Files to Edit

- `hooks/context-hook.sh` — add new data injection sections

## Implementation

Add these sections to the CONTEXT string building:

### 1. Real timestamp
```bash
REAL_TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
# Add to context: "Timestamp: 2026-03-30 14:35"
```

### 2. Skills list
```bash
INDEX_FILE="$WORKSPACE_DIR/.github/skills/INDEX.md"
SKILLS_LIST=""
if [ -f "$INDEX_FILE" ]; then
  SKILLS_LIST=$(grep -oE 'tao-[a-z-]+' "$INDEX_FILE" 2>/dev/null | sort -u | tr '\n' ', ')
fi
# Add to context: "Available skills: tao-clean-code, tao-security-audit, ..."
```

### 3. Lint status
```bash
LINT_EXTENSIONS=""
if [ -f "$CONFIG_FILE" ]; then
  LINT_EXTENSIONS=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    exts = list(c.get('lint_commands', {}).keys())
    print(', '.join(exts) if exts else 'NONE — no lint configured')
except:
    print('unknown')
" "$CONFIG_FILE" 2>/dev/null)
fi
# Add to context: "Lint active for: .php, .py, .ts" or "Lint: NONE"
```

### 4. Hook status
```bash
HOOKS_JSON="$WORKSPACE_DIR/.github/hooks/hooks.json"
HOOKS_ACTIVE="false"
if [ -f "$HOOKS_JSON" ]; then
  HOOKS_ACTIVE="true"
fi
# Add to context: "Hooks: active" or "Hooks: INACTIVE (hooks.json missing)"
```

### 5. Compliance data
Inject all of the above as a structured block:
```
System-provided compliance data (DO NOT guess these values):
- Timestamp: 2026-03-30 14:35
- Phase: 01
- Branch: dev
- Skills available: tao-clean-code, tao-security-audit, ...
- Lint configured: .php, .py
- Hooks: active
Use these EXACT values in your compliance check block.
```

## Acceptance Criteria

- [ ] Real timestamp injected (verified by checking session start context)
- [ ] Skills list from INDEX.md injected
- [ ] Lint status (configured extensions) injected
- [ ] Hook status injected
- [ ] Data labeled as "System-provided" so agent doesn't override
- [ ] Existing functionality preserved (phase, branch, tasks, handoff, orphan detection)
