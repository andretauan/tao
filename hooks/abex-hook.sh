#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# abex-hook.sh — PostToolUse hook: ABEX security scan on edits
# ═══════════════════════════════════════════════════════════════
# Cost: 0 premium requests (deterministic)
# Fires on every file edit — runs abex-gate.sh on the edited file.
# Input: JSON via stdin with tool_name, tool_input
# Output: JSON via stdout with additionalContext (if issue) or empty (if ok/skip)

set -euo pipefail

INPUT=$(cat)

# ── Extract tool_name and file_path ──
_parsed=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', ''))
    ti = d.get('tool_input', {})
    p = ti.get('filePath') or ti.get('file_path') or ''
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

# ── Only process file edits ──
case "$TOOL_NAME" in
  editFiles|create_file|replace_string_in_file|multi_replace_string_in_file)
    ;;
  *)
    exit 0
    ;;
esac

[ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "None" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# ── Only scan code files ──
case "$FILE_PATH" in
  *.php|*.py|*.js|*.ts|*.jsx|*.tsx|*.java|*.go|*.rs|*.rb|*.sh|*.bash|*.c|*.cpp|*.cs)
    ;;
  *)
    exit 0
    ;;
esac

# ── Check compliance.abex_enabled from config ──
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"

if [ -f "$CONFIG_FILE" ]; then
  ABEX_ENABLED=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    val = c.get('compliance', {}).get('abex_enabled', True)
    print('true' if val else 'false')
except:
    print('true')
" "$CONFIG_FILE" 2>/dev/null) || ABEX_ENABLED="true"
  [ "$ABEX_ENABLED" = "false" ] && exit 0
fi

# ── Locate abex-gate.sh ──
ABEX_SCRIPT=""
for candidate in \
  "$WORKSPACE_DIR/.github/tao/scripts/abex-gate.sh" \
  "$(dirname "$0")/../../scripts/abex-gate.sh"; do
  if [ -x "$candidate" ]; then
    ABEX_SCRIPT="$candidate"
    break
  fi
done

[ -z "$ABEX_SCRIPT" ] && exit 0

# ── Sanitize path ──
if [[ "$FILE_PATH" =~ [';|&`$(){}\\<>'] ]]; then
  exit 0
fi

# ── Run ABEX scan ──
ABEX_EXIT=0
ABEX_OUTPUT=$(bash "$ABEX_SCRIPT" "$FILE_PATH" 2>&1) || ABEX_EXIT=$?

if [ "$ABEX_EXIT" -eq 1 ]; then
  # Extract BLOCK findings for the message (concise)
  FINDINGS=$(echo "$ABEX_OUTPUT" | grep -E '^\[BLOCK\]' | head -5 || echo "$ABEX_OUTPUT" | head -5)
  MSG="⚠️ ABEX SECURITY ISSUE in ${FILE_PATH}:
${FINDINGS}

Você DEVE corrigir estes problemas antes de continuar.
/ You MUST fix these security issues before proceeding."

  SAFE_MSG=$(printf '%s' "$MSG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
fi

exit 0
