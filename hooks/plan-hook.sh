#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# plan-hook.sh — PostToolUse hook: validate plan on save
# ═══════════════════════════════════════════════════════════════
# Fires when PLAN.md or STATUS.md are edited during planning.
# Runs validate-plan.sh and injects errors as agent context.
# Cost: 0 premium requests (deterministic)

set -euo pipefail

INPUT=$(cat)

# ── Extract tool_name and file_path ──
_parsed=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tn = d.get('tool_name', '')
    ti = d.get('tool_input', {})
    p = ti.get('filePath') or ti.get('file_path') or ''
    if not p:
        reps = ti.get('replacements', [])
        if reps:
            p = reps[0].get('filePath', '')
    print(tn)
    print(p)
except:
    print('')
    print('')
" 2>/dev/null) || exit 0

TOOL_NAME=$(echo "$_parsed" | sed -n '1p')
FILE_PATH=$(echo "$_parsed" | sed -n '2p')

# Only process file edits
case "$TOOL_NAME" in
  editFiles|create_file|replace_string_in_file|multi_replace_string_in_file) ;;
  *) exit 0 ;;
esac

[ -z "$FILE_PATH" ] && exit 0

# Only trigger on plan artifacts
FILE_BASENAME="${FILE_PATH##*/}"
case "$FILE_BASENAME" in
  PLAN.md|STATUS.md) ;;
  *) exit 0 ;;
esac

# ── Determine if this is a phase-level file (not brainstorm) ──
FILE_DIR=$(dirname "$FILE_PATH")
DIR_BASENAME="${FILE_DIR##*/}"
# Skip brainstorm-level files (handled by brainstorm-hook.sh)
if [ "$DIR_BASENAME" = "brainstorm" ]; then
  exit 0
fi

PHASE_DIR="$FILE_DIR"

# ── Locate validate-plan.sh ──
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
VP_SCRIPT=""
for p in "$WORKSPACE_DIR/.github/tao/scripts/validate-plan.sh" \
         "$WORKSPACE_DIR/scripts/validate-plan.sh"; do
  if [ -f "$p" ]; then
    VP_SCRIPT="$p"
    break
  fi
done
[ -z "$VP_SCRIPT" ] && exit 0

# ── Run validation ──
VP_EXIT=0
VP_OUTPUT=$(bash "$VP_SCRIPT" "$PHASE_DIR" 2>&1) || VP_EXIT=$?

if [ $VP_EXIT -ne 0 ]; then
  ERRORS=$(echo "$VP_OUTPUT" | grep -E '^\[BLOCK\]|^\[FAIL\]|missing|mismatch' | head -5)
  MSG="⚠️ PLAN VALIDATION FAILED for ${FILE_BASENAME}:
${ERRORS}
Fix the issues before proceeding."
  SAFE_MSG=$(printf '%s' "$MSG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
fi

exit 0
