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

# ── Extract tool_name and file_path in a single python3 call ──
_parsed=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
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
    print('')
" 2>/dev/null)
TOOL_NAME=$(echo "$_parsed" | sed -n '1p')
FILE_PATH=$(echo "$_parsed" | sed -n '2p')

# Only process file edits
case "$TOOL_NAME" in
  editFiles|create_file|replace_string_in_file|multi_replace_string_in_file)
    ;;
  *)
    exit 0
    ;;
esac

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
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 0
fi

# ── Look up lint command for this extension ──
LINT_CMD=$(python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        cfg = json.load(f)
    cmds = cfg.get('lint_commands', {})
    if not cmds:
        print('__EMPTY__')
    else:
        cmd = cmds.get(sys.argv[2], '')
        print(cmd)
except:
    print('')
" "$CONFIG_FILE" "$EXT" 2>/dev/null)

if [ "$LINT_CMD" = "__EMPTY__" ]; then
  # Warn agent that no lint_commands are configured (only once — on .md or .json edits skip)
  case "$EXT" in
    .md|.json|.txt|.yaml|.yml) exit 0 ;;
  esac
  WARN_MSG=$(printf '%s' "⚠️ TAO lint: lint_commands is empty in .github/tao/tao.config.json. No lint check performed. Configure lint tools in tao.config.json → lint_commands." | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$WARN_MSG"
  exit 0
fi

if [ -z "$LINT_CMD" ]; then
  exit 0
fi

# ── Sanitize FILE_PATH before shell substitution ──
# Reject paths containing shell metacharacters that could cause injection
# via the `bash -c "$LINT_CMD"` call below.
if [[ "$FILE_PATH" =~ [';|&`$(){}\\<>'] ]]; then
  exit 0  # Skip linting for paths with unsafe characters — do not execute
fi

# ── Replace {file} placeholder with actual path ──
LINT_CMD="${LINT_CMD//\{file\}/$FILE_PATH}"

# ── Verify tool exists before running ──
_lint_tool=$(echo "$LINT_CMD" | awk '{print $1}')
# Handle npx → check second arg
if [ "$_lint_tool" = "npx" ]; then
  _lint_tool=$(echo "$LINT_CMD" | awk '{print $2}')
fi
# Strip any path prefix for command -v check
_lint_bin="${_lint_tool##*/}"
if ! command -v "$_lint_bin" &>/dev/null && [ ! -x "$_lint_tool" ]; then
  SKIP_MSG=$(printf '%s' "⚠️ TAO lint: tool '${_lint_bin}' not found — skipping lint for ${FILE_PATH}. Install it or update lint_commands in tao.config.json." | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SKIP_MSG"
  exit 0
fi

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
