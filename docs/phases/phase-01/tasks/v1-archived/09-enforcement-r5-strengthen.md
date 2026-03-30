# Task T09 — enforcement-hook.sh: Strengthen R5 Enforcement

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P2

---

## Objective

Change the R5 enforcement in enforcement-hook.sh from a soft warning to a strong blocking instruction that tells the agent to STOP and read the file before editing.

## Context

Currently R5 ("never edit without reading first") is enforced by enforcement-hook.sh with a warning message. But the message is mild and agents may ignore it. The hook should output a stronger directive that the agent model interprets as a hard constraint.

## Files to Read (BEFORE editing)

- `hooks/enforcement-hook.sh` — full file, especially R5 section

## Files to Create/Edit

- `hooks/enforcement-hook.sh` — strengthen R5 output

## Implementation Steps

1. Read enforcement-hook.sh completely
2. Find the R5 enforcement section
3. Replace the warning message with a stronger directive:
   ```
   🛑 R5 VIOLATION — STOP
   You are about to edit a file you haven't read in this session.
   ACTION REQUIRED: Read the complete file BEFORE making any changes.
   File: {filename}
   DO NOT PROCEED until you have read this file.
   ```
4. Ensure the hook still returns appropriate exit code
5. Test: trigger the hook and verify the stronger message appears

## Acceptance Criteria

- [ ] R5 message uses 🛑 and "STOP" language
- [ ] Message includes the specific filename
- [ ] Message includes "ACTION REQUIRED" directive
- [ ] Hook exit code behavior unchanged (still non-blocking for hook execution)
- [ ] No other enforcement rules affected

## Notes / Gotchas

- The hook output goes to the agent's context — it needs to be imperative language the model will respect
- Don't make it exit 1 (that would kill the tool execution) — keep it as context injection
- The current R5 detection may be based on tracking read files — verify the mechanism

---

**Expected commit:** `fix(phase-01): T09 — enforcement-hook.sh strengthens R5 to blocking directive`
