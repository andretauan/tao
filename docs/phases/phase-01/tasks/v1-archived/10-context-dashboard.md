# Task T10 — context-hook.sh: Enhanced Dashboard

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P2

---

## Objective

Enhance context-hook.sh to display a mini-dashboard at session start showing the project's current state: active phase, task progress, lint status, and hook activation status.

## Context

Currently context-hook.sh outputs the CONTEXT.md content. A vibe coder doesn't know how to interpret raw markdown. A visual dashboard with box-drawing characters gives instant situational awareness: what phase am I in, how many tasks are done, is lint working, are hooks active.

## Files to Read (BEFORE editing)

- `hooks/context-hook.sh` — full file
- `templates/shared/tao.config.json` — to know where to read phase/task info

## Files to Create/Edit

- `hooks/context-hook.sh` — add dashboard output before existing content

## Implementation Steps

1. Read context-hook.sh completely
2. After the initial config loading, add a dashboard section:
   ```bash
   # ===== Mini Dashboard =====
   echo ""
   echo "┌─────────────────────────────────────┐"
   echo "│         🏯 TAO — Status              │"
   echo "├─────────────────────────────────────┤"
   
   # Active phase
   if [ -f "$CONFIG_PATH" ]; then
     PHASE_PREFIX=$(jq -r '.phases.phase_prefix // "phase-"' "$CONFIG_PATH")
     PHASES_DIR=$(jq -r '.phases.dir // ".github/tao/phases"' "$CONFIG_PATH")
     # Find highest-numbered phase directory
     ACTIVE_PHASE=$(ls -d "$PHASES_DIR/${PHASE_PREFIX}"* 2>/dev/null | sort -V | tail -1 | xargs basename 2>/dev/null)
     if [ -n "$ACTIVE_PHASE" ]; then
       echo "│  Phase:  $ACTIVE_PHASE"
       
       # Count tasks
       TASK_DIR="$PHASES_DIR/$ACTIVE_PHASE/tasks"
       if [ -d "$TASK_DIR" ]; then
         TOTAL=$(ls "$TASK_DIR"/*.md 2>/dev/null | wc -l)
         # Count completed (files containing "✅" or "[x]" in status)
         DONE=$(grep -rl '\[x\]\|✅' "$TASK_DIR"/*.md 2>/dev/null | wc -l)
         echo "│  Tasks:  $DONE / $TOTAL"
       fi
     else
       echo "│  Phase:  none created"
     fi
   fi
   
   # Lint status
   LINT_CMD=$(jq -r '.lint_commands | to_entries[0].value // empty' "$CONFIG_PATH" 2>/dev/null)
   if [ -n "$LINT_CMD" ] && [ "$LINT_CMD" != "null" ]; then
     LINT_TOOL=$(echo "$LINT_CMD" | awk '{print $1}')
     if command -v "$LINT_TOOL" &>/dev/null; then
       echo "│  Lint:   ✅ $LINT_TOOL"
     else
       echo "│  Lint:   ⚠️  $LINT_TOOL (not installed)"
     fi
   else
     echo "│  Lint:   ❌ not configured"
   fi
   
   # Hooks status
   if [ -f ".vscode/settings.json" ] && grep -q "chat.useCustomAgentHooks.*true" ".vscode/settings.json" 2>/dev/null; then
     echo "│  Hooks:  ✅ active"
   else
     echo "│  Hooks:  ⚠️  not activated"
   fi
   
   echo "└─────────────────────────────────────┘"
   echo ""
   ```

3. Keep existing CONTEXT.md output after the dashboard
4. Test: verify dashboard renders correctly in terminal with various states

## Acceptance Criteria

- [ ] Dashboard shows active phase name
- [ ] Dashboard shows task progress (done / total)
- [ ] Dashboard shows lint tool status (configured + installed, configured + missing, not configured)
- [ ] Dashboard shows hook activation status
- [ ] Box-drawing characters render correctly
- [ ] Dashboard appears before existing CONTEXT.md output
- [ ] Gracefully handles missing config, no phases, no tasks
- [ ] No new dependencies (uses jq which is already required by TAO)

## Notes / Gotchas

- jq is required — it's already a TAO dependency
- Box-drawing characters may not render in all terminals, but VS Code terminal handles them fine
- Don't make the dashboard too wide — keep under 40 chars for sidebar terminal
- Task completion detection is approximate — grep for checkboxes is a heuristic

---

**Expected commit:** `feat(phase-01): T10 — context-hook.sh shows mini-dashboard at session start`
