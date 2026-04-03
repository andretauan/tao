#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# enforcement-hook.sh — PostToolUse hook: R0 + R5 + terminal enforcement
# ═══════════════════════════════════════════════════════════════
# Cost: 0 premium requests (deterministic)
# Maintains .tao-session/ state to track reads vs edits.
#
# R5: Detects edits on files not previously read → injects BLOCK message
# R0: Detects first edit without CONTEXT.md/CHANGELOG.md read → injects warning
# TERMINAL: Detects dangerous git/shell commands → injects LOCK violation
#
# Input:  JSON via stdin with tool_name, tool_input
# Output: JSON via stdout with additionalContext (if violation) or empty (if ok)

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"
SESSION_DIR="$WORKSPACE_DIR/.tao-session"

# ── Initialize session directory (idempotent) ──
mkdir -p "$SESSION_DIR" 2>/dev/null || exit 0

# Read current session ID for scoped log files (avoids race condition)
SESSION_ID=""
if [ -f "$SESSION_DIR/session_id" ]; then
  SESSION_ID=$(cat "$SESSION_DIR/session_id" 2>/dev/null || true)
fi
if [ -z "$SESSION_ID" ]; then
  SESSION_ID="default"
fi

READS_LOG="$SESSION_DIR/reads.${SESSION_ID}.log"
EDITS_LOG="$SESSION_DIR/edits.${SESSION_ID}.log"
touch "$READS_LOG" "$EDITS_LOG" 2>/dev/null || exit 0

# ── Read compliance config flags ──
REQUIRE_R5_CHECK="true"
REQUIRE_R0_CHECK="true"
REQUIRE_R3_CHECK="true"
if [ -f "$CONFIG_FILE" ]; then
  _compliance=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    comp = c.get('compliance', {})
    print('true' if comp.get('require_context_read', True) else 'false')
    print('true' if comp.get('require_skill_check', True) else 'false')
except:
    print('true')
    print('true')
" "$CONFIG_FILE" 2>/dev/null) || _compliance=""
  if [ -n "$_compliance" ]; then
    REQUIRE_R0_CHECK=$(echo "$_compliance" | sed -n '1p')
    REQUIRE_R5_CHECK=$(echo "$_compliance" | sed -n '1p')
    REQUIRE_R3_CHECK=$(echo "$_compliance" | sed -n '2p')
  fi
fi

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
# TERMINAL INTERCEPT — detect dangerous commands
# ══════════════════════════════════════════════════
case "$TOOL_NAME" in
  runInTerminal|run_in_terminal)
    COMMAND=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    print(ti.get('command', ''))
except:
    print('')
" 2>/dev/null) || COMMAND=""

    DANGER=""
    if echo "$COMMAND" | grep -qE 'push\s+(origin\s+)?(main|master)\b'; then
      DANGER="🚫 LOCK 2 VIOLATION: Este comando faz push para main/master. PROIBIDO pelo TAO. Use: git push origin dev"
    elif echo "$COMMAND" | grep -qE '\-\-force(-with-lease)?(\s|$)'; then
      DANGER="🚫 LOCK 2 VIOLATION: Force push detectado. PROIBIDO pelo TAO. Nunca use --force."
    elif echo "$COMMAND" | grep -qE '\-\-no-verify'; then
      DANGER="🚫 LOCK 6 VIOLATION: --no-verify ignora os quality gates. ABSOLUTAMENTE PROIBIDO pelo TAO. Corrija os erros ao invés de ignorá-los."
    elif echo "$COMMAND" | grep -qE '\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s+/'; then
      DANGER="🚫 LOCK 3 VIOLATION: rm -rf em path absoluto detectado. PROIBIDO pelo TAO. Nunca use rm -rf sem aprovação explícita."
    elif echo "$COMMAND" | grep -qiE '\bDROP\s+(TABLE|DATABASE|SCHEMA)\b|\bTRUNCATE\s+(TABLE\s+)?[a-zA-Z]'; then
      DANGER="🚫 LOCK 3 VIOLATION: Comando SQL destrutivo detectado. STOP. Documente o SQL e registe como checkpoint antes de prosseguir."
    fi

    if [ -n "$DANGER" ]; then
      SAFE_MSG=$(printf '%s' "$DANGER" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
      printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$SAFE_MSG"
    fi
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
  if [ "$TOOL_NAME" != "create_file" ] && [ "$REQUIRE_R5_CHECK" = "true" ]; then
    MESSAGES="🚫 VIOLAÇÃO R5 — PARE TODA EDIÇÃO IMEDIATAMENTE. Você editou '${FILE_BASENAME}' SEM lê-lo antes. Esta é uma regra INVIOLÁVEL. Você DEVE: (1) PARAR de editar agora (2) Ler este arquivo com read_file (3) Verificar se sua edição está correta (4) Só então continuar. NÃO prossiga com nenhuma outra edição até resolver isso. / R5 VIOLATION — STOP ALL EDITING. You edited '${FILE_BASENAME}' WITHOUT reading it first. INVIOLABLE rule breach."
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

if [ "$EDIT_COUNT" -eq 0 ] && [ "$REQUIRE_R0_CHECK" = "true" ]; then
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
