#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# enforcement-hook.sh — PostToolUse hook: R0 + R5 enforcement
# ═══════════════════════════════════════════════════════════════
# Cost: 0 premium requests (deterministic)
# Maintains .tao-session/ state to track reads vs edits.
#
# R5: Detects edits on files not previously read → injects violation warning
# R0: Detects first edit without CONTEXT.md/CHANGELOG.md read → injects warning
#
# Input:  JSON via stdin with tool_name, tool_input
# Output: JSON via stdout with additionalContext (if violation) or empty (if ok)

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
SESSION_DIR="$WORKSPACE_DIR/.tao-session"

# ── Initialize session directory (idempotent) ──
mkdir -p "$SESSION_DIR" 2>/dev/null || exit 0

READS_LOG="$SESSION_DIR/reads.log"
EDITS_LOG="$SESSION_DIR/edits.log"
touch "$READS_LOG" "$EDITS_LOG" 2>/dev/null || exit 0

# ── Parse stdin JSON ──
INPUT=$(cat)

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

# ══════════════════════════════════════════════════
# TRACK READS — log every file the agent reads
# ══════════════════════════════════════════════════
case "$TOOL_NAME" in
  read_file|readFile)
    [ -n "$FILE_PATH" ] && echo "$FILE_PATH" >> "$READS_LOG"
    exit 0
    ;;
esac

# ══════════════════════════════════════════════════
# ENFORCE ON EDITS — R0 + R5
# ══════════════════════════════════════════════════
case "$TOOL_NAME" in
  editFiles|create_file|replace_string_in_file|multi_replace_string_in_file)
    ;;
  *)
    exit 0
    ;;
esac

[ -z "$FILE_PATH" ] && exit 0

MESSAGES=""

# ── R5: Was this file read before editing? ──
# Normalize: extract just the filename for partial matching (handles abs vs relative)
FILE_BASENAME="${FILE_PATH##*/}"
R5_OK="false"

if [ -f "$READS_LOG" ] && [ -s "$READS_LOG" ]; then
  # Check both full path and basename (agent may read with different path format)
  if grep -qF "$FILE_PATH" "$READS_LOG" 2>/dev/null; then
    R5_OK="true"
  elif grep -qF "$FILE_BASENAME" "$READS_LOG" 2>/dev/null; then
    R5_OK="true"
  fi
fi

if [ "$R5_OK" = "false" ]; then
  # create_file is exempt — new files don't need to be read first
  if [ "$TOOL_NAME" != "create_file" ]; then
    MESSAGES="⚠️ R5 VIOLATION DETECTED: You edited '${FILE_BASENAME}' without reading it first. You MUST read this file NOW to verify your edit is correct. Rule R5 is INVIOLABLE — never edit a file without reading it first."
  fi
fi

# ── R0: First edit without compliance? ──
EDIT_COUNT=0
if [ -f "$EDITS_LOG" ] && [ -s "$EDITS_LOG" ]; then
  EDIT_COUNT=$(wc -l < "$EDITS_LOG")
  EDIT_COUNT="${EDIT_COUNT// /}"
fi

# Log this edit
echo "$FILE_PATH" >> "$EDITS_LOG"

if [ "$EDIT_COUNT" -eq 0 ]; then
  # This is the first edit of the session — check if compliance prep was done
  CONTEXT_READ="false"
  CHANGELOG_READ="false"

  if [ -f "$READS_LOG" ] && [ -s "$READS_LOG" ]; then
    grep -qF "CONTEXT.md" "$READS_LOG" 2>/dev/null && CONTEXT_READ="true"
    grep -qF "CHANGELOG.md" "$READS_LOG" 2>/dev/null && CHANGELOG_READ="true"
  fi

  if [ "$CONTEXT_READ" = "false" ] || [ "$CHANGELOG_READ" = "false" ]; then
    R0_MSG="⚠️ R0 COMPLIANCE VIOLATION: This is your first code edit but you have NOT read CONTEXT.md and/or CHANGELOG.md. You MUST read both files and emit the compliance block BEFORE modifying code. Stop and comply NOW."
    if [ -n "$MESSAGES" ]; then
      MESSAGES="${MESSAGES} | ${R0_MSG}"
    else
      MESSAGES="$R0_MSG"
    fi
  fi
fi

# ── Output violations as additionalContext ──
if [ -n "$MESSAGES" ]; then
  SAFE_MSG=$(printf '%s' "$MESSAGES" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
fi

exit 0
