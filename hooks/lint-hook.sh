#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# lint-hook.sh — PostToolUse hook: auto-lint after file edits
# ═══════════════════════════════════════════════════════════════
# Cost: 0 premium requests (deterministic, no LLM roundtrip)
# Fires on EVERY tool call — filters internally by tool_name + extension
# Reads lint commands from tao.config.json → lint_commands
# Input: JSON via stdin with tool_name, tool_input, tool_response
# Output: JSON via stdout with additionalContext (if error) or empty (if ok/skip)

set -euo pipefail

INPUT=$(cat)

# ── Extract tool_name using python3 (portable, no jq dependency) ──
TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

# Only process file edits
case "$TOOL_NAME" in
  editFiles|create_file|replace_string_in_file|multi_replace_string_in_file)
    ;;
  *)
    exit 0
    ;;
esac

# ── Extract file path ──
FILE_PATH=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    p = ti.get('filePath') or ti.get('file_path') or ''
    if not p:
        files = ti.get('files', [])
        if files:
            p = files[0] if isinstance(files[0], str) else files[0].get('filePath', '')
    if not p:
        reps = ti.get('replacements', [])
        if reps:
            p = reps[0].get('filePath', '')
    print(p)
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "None" ]; then
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# ── Get file extension ──
EXT="${FILE_PATH##*.}"
if [ -z "$EXT" ] || [ "$EXT" = "$FILE_PATH" ]; then
  exit 0
fi
EXT=".$EXT"

# ── Find tao.config.json ──
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/tao.config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi

# ── Look up lint command for this extension ──
LINT_CMD=$(python3 -c "
import json, sys
try:
    with open('$CONFIG_FILE') as f:
        cfg = json.load(f)
    cmds = cfg.get('lint_commands', {})
    cmd = cmds.get('$EXT', '')
    print(cmd)
except:
    print('')
" 2>/dev/null)

if [ -z "$LINT_CMD" ]; then
  exit 0
fi

# ── Replace {file} placeholder with actual path ──
LINT_CMD="${LINT_CMD//\{file\}/$FILE_PATH}"

# ── Run lint ──
LINT_EXIT=0
LINT_OUTPUT=$(bash -c "$LINT_CMD" 2>&1) || LINT_EXIT=$?

if [ $LINT_EXIT -ne 0 ]; then
  # Escape for JSON using python3
  SAFE_MSG=$(printf '%s' "⚠️ LINT ERROR in ${FILE_PATH}:
${LINT_OUTPUT}

Fix the error before proceeding." | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)

  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
  exit 0
fi

exit 0
