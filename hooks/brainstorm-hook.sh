#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# brainstorm-hook.sh — PostToolUse hook: validate brainstorm on save
# ═══════════════════════════════════════════════════════════════
# Fires when BRIEF.md / PLAN.md / STATUS.md are edited during brainstorm.
# Runs validate-brainstorm.sh and injects errors as agent context.
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

# Only trigger on brainstorm artifacts
FILE_BASENAME="${FILE_PATH##*/}"
case "$FILE_BASENAME" in
  BRIEF.md|PLAN.md|STATUS.md) ;;
  *) exit 0 ;;
esac

# ── Find brainstorm directory (parent of the edited file) ──
BRAINSTORM_DIR=$(dirname "$FILE_PATH")
DIR_BASENAME="${BRAINSTORM_DIR##*/}"
if [ "$DIR_BASENAME" != "brainstorm" ]; then
  exit 0
fi
PHASE_DIR=$(dirname "$BRAINSTORM_DIR")

# ── Locate validate-brainstorm.sh ──
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
VB_SCRIPT=""
for p in "$WORKSPACE_DIR/.github/tao/scripts/validate-brainstorm.sh" \
         "$WORKSPACE_DIR/scripts/validate-brainstorm.sh"; do
  if [ -f "$p" ]; then
    VB_SCRIPT="$p"
    break
  fi
done
[ -z "$VB_SCRIPT" ] && exit 0

# ── Run validation ──
VB_EXIT=0
VB_OUTPUT=$(bash "$VB_SCRIPT" "$PHASE_DIR" 2>&1) || VB_EXIT=$?

if [ $VB_EXIT -ne 0 ]; then
  ERRORS=$(echo "$VB_OUTPUT" | grep -E '^\[BLOCK\]|^\[FAIL\]|MATURITY|missing' | head -5)
  MSG="⚠️ BRAINSTORM VALIDATION FAILED for ${FILE_BASENAME}:
${ERRORS}
Fix the issues before proceeding."
  SAFE_MSG=$(printf '%s' "$MSG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
fi

exit 0
