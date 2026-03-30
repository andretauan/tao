# Task T08 — Wire compliance.* Config Into All Hooks

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P1-HOOKS (L1)
**Depends on:** T05, T06, T07

---

## Objective

Ensure all hooks read the compliance section from tao.config.json and respect its flags. Currently these flags exist but nothing reads them.

## Gaps Fixed

- G14: compliance.* config is decorative

## Files to Read

- `tao.config.json.example` — compliance section structure
- `hooks/context-hook.sh` — after T05 changes
- `hooks/enforcement-hook.sh` — after T06 changes
- `hooks/abex-hook.sh` — after T07 creation

## Files to Edit

- `hooks/context-hook.sh` — read compliance.require_context_read, skip context injection if false
- `hooks/enforcement-hook.sh` — read compliance.require_skill_check, skip R3 if false
- `hooks/abex-hook.sh` — read compliance.abex_enabled, skip scan if false

## Implementation

Each hook should have a config-reading block near the top:

```bash
# Read compliance config
_compliance=""
if [ -f "$CONFIG_FILE" ]; then
  _compliance=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    comp = c.get('compliance', {})
    print('true' if comp.get('require_context_read', True) else 'false')
    print('true' if comp.get('require_skill_check', True) else 'false')
    print('true' if comp.get('abex_enabled', True) else 'false')
except:
    print('true'); print('true'); print('true')
" "$CONFIG_FILE" 2>/dev/null)
fi
```

If the relevant flag is `false`, the hook should exit 0 immediately for that check.

## Acceptance Criteria

- [ ] Setting `abex_enabled: false` → abex-hook and pre-commit ABEX skip
- [ ] Setting `require_context_read: false` → context-hook still runs but doesn't insist on reading
- [ ] Setting `require_skill_check: false` → enforcement-hook doesn't warn about missing skills
- [ ] Default behavior (all true) unchanged
- [ ] Config parse failure → defaults to true (fail-safe)
