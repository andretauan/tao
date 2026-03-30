# Task T07 — Create abex-hook.sh: PostToolUse Security Scan

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P1-HOOKS (L1)
**Depends on:** T04 (abex-gate.sh must exist)

---

## Objective

Create abex-hook.sh — a PostToolUse hook that runs abex-gate.sh on each edited file. Add to hooks.json.

## Gaps Fixed

- G13: No ABEX PostToolUse scan

## Files to Read

- `hooks/lint-hook.sh` — reference for PostToolUse hook pattern (stdin JSON, file extraction, output format)
- `hooks/enforcement-hook.sh` — reference
- `scripts/abex-gate.sh` — created in T04, called from here
- `templates/shared/hooks.json` — current hook configuration
- `tao.config.json.example` — compliance.abex_enabled

## Files to Create

- `hooks/abex-hook.sh` — NEW: PostToolUse security scan hook

## Files to Edit

- `templates/shared/hooks.json` — add abex-hook.sh to PostToolUse array
- `install.sh` — add safe_copy_exec for abex-hook.sh

## Implementation

Follow the EXACT pattern of lint-hook.sh:
1. Read stdin JSON
2. Extract tool_name + file_path
3. Filter: only process edit tools
4. Check compliance.abex_enabled from config (if false, exit 0)
5. Run abex-gate.sh on the file
6. If findings → inject as additionalContext

Also add to hooks.json PostToolUse array:
```json
{
  "type": "command",
  "command": "./.github/tao/scripts/abex-hook.sh",
  "timeout": 10
}
```

## Acceptance Criteria

- [ ] Fires on every file edit (same filter as lint-hook)
- [ ] Runs abex-gate.sh on the edited file
- [ ] If security issues found → injects warning in context
- [ ] Respects compliance.abex_enabled from config
- [ ] Added to hooks.json
- [ ] Added to install.sh safe_copy_exec list
