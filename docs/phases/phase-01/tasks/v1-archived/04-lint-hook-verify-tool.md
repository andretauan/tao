# Task T04 — lint-hook.sh: Verify Tool Existence + Warn Empty

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P0

---

## Objective

Make lint-hook.sh check if the configured lint tool actually exists on the system before running, and warn (once per session) when lint_commands is empty.

## Context

Currently lint-hook.sh reads lint_commands from tao.config.json and runs them. If the tool doesn't exist (e.g., `eslint` not installed), bash throws a cryptic error. If lint_commands is empty (stack = "none"), it returns 0 silently — no feedback that quality gates are disabled.

## Files to Read (BEFORE editing)

- `hooks/lint-hook.sh` — full file

## Files to Create/Edit

- `hooks/lint-hook.sh` — add tool verification + empty warning

## Implementation Steps

1. Read lint-hook.sh completely
2. After reading lint_commands from config, add tool existence check:
   ```bash
   # Extract the base command (first word)
   LINT_TOOL=$(echo "$LINT_CMD" | awk '{print $1}')
   
   # Check if tool exists
   if ! command -v "$LINT_TOOL" &>/dev/null; then
     echo "⚠️  Lint tool '$LINT_TOOL' not found. Install it or update tao.config.json → lint_commands"
     echo "   Skipping lint check for this file."
     exit 0
   fi
   ```

3. Add empty lint_commands warning (with session dedup via temp file):
   ```bash
   if [ -z "$LINT_CMD" ] || [ "$LINT_CMD" = "null" ]; then
     WARN_FLAG="/tmp/.tao-lint-warned-$$"
     if [ ! -f "$WARN_FLAG" ]; then
       echo "⚠️  No lint configured. TAO won't catch syntax errors."
       echo "   Set lint_commands in .github/tao/tao.config.json"
       touch "$WARN_FLAG"
     fi
     exit 0
   fi
   ```

4. Test: configure a non-existent lint tool, verify warning appears; set lint_commands to empty, verify one-time warning

## Acceptance Criteria

- [ ] Non-existent lint tool → clear warning with tool name + fix instruction
- [ ] Non-existent lint tool → exit 0 (don't block, just warn)
- [ ] Empty lint_commands → warn once per "session" (using temp flag file)
- [ ] Empty lint_commands → exit 0
- [ ] Valid lint tool → existing behavior unchanged
- [ ] No new dependencies introduced

## Notes / Gotchas

- Use `command -v` not `which` (more portable)
- Session dedup via temp file is approximate but good enough for hook context
- `exit 0` on missing tool — warn but don't block. The user chose "none" or hasn't installed yet.
- `$LINT_CMD` may be JSON null if not set — check both empty and "null"

---

**Expected commit:** `fix(phase-01): T04 — lint-hook.sh verifies tool existence and warns on empty`
