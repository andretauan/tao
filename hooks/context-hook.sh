#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# context-hook.sh — SessionStart hook: inject project context
# ═══════════════════════════════════════════════════════════════
# Cost: 0 premium requests (deterministic)
# Injects active phase, branch, tasks done/pending at session start
# Eliminates 2-3 roundtrips of manual CONTEXT.md reading
# Reads paths from tao.config.json (no hardcoded assumptions)

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/tao.config.json"
CONTEXT_FILE="$WORKSPACE_DIR/CONTEXT.md"

if [ ! -f "$CONTEXT_FILE" ]; then
  exit 0
fi

# ── Read config (phases dir + prefix) ──
PHASES_DIR="docs/phases"
PHASE_PREFIX="phase-"
PROJECT_NAME="Project"

if [ -f "$CONFIG_FILE" ]; then
  _cfg=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('phases','docs/phases'))
    print(c.get('paths',{}).get('phase_prefix','phase-'))
    print(c.get('project',{}).get('name','Project'))
except:
    print('docs/phases')
    print('phase-')
    print('Project')
" "$CONFIG_FILE" 2>/dev/null) || _cfg=""
  if [ -n "$_cfg" ]; then
    PHASES_DIR=$(echo "$_cfg" | sed -n '1p')
    PHASES_DIR="${PHASES_DIR%/}"
    PHASE_PREFIX=$(echo "$_cfg" | sed -n '2p')
    PROJECT_NAME=$(echo "$_cfg" | sed -n '3p')
  fi
fi

# ── Extract active phase number from CONTEXT.md ──
PHASE=""
# Try patterns: "Phase: 03", "Fase: 03", "phase-03", "fase-03"
PHASE=$(grep -oE '(Phase|Fase):?[[:space:]]*[0-9]+' "$CONTEXT_FILE" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "")
if [ -z "$PHASE" ]; then
  PHASE=$(grep -oE "${PHASE_PREFIX}[0-9]+" "$CONTEXT_FILE" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "")
fi

if [ -z "$PHASE" ]; then
  PHASE="??"
fi
if [[ "$PHASE" =~ ^[0-9]+$ ]]; then
  PHASE_PADDED=$(printf "%02d" "$PHASE")
else
  PHASE_PADDED="$PHASE"
fi

# ── Git branch ──
BRANCH=$(cd "$WORKSPACE_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

# ── Phase status ──
STATUS_FILE="$WORKSPACE_DIR/$PHASES_DIR/${PHASE_PREFIX}${PHASE_PADDED}/STATUS.md"
PENDING="0"
DONE="0"
if [ -f "$STATUS_FILE" ]; then
  PENDING=$(grep -c '⏳' "$STATUS_FILE" 2>/dev/null || echo "0")
  DONE=$(grep -c '✅' "$STATUS_FILE" 2>/dev/null || echo "0")
fi

# ── Pause check ──
PAUSED="false"
if [ -f "$WORKSPACE_DIR/.tao-pause" ] || [ -f "$WORKSPACE_DIR/.gsd-pause" ]; then
  PAUSED="true"
fi

# ── Recent progress entries ──
PROGRESS_FILE="$WORKSPACE_DIR/$PHASES_DIR/${PHASE_PREFIX}${PHASE_PADDED}/progress.txt"
LAST_ENTRIES=""
if [ -f "$PROGRESS_FILE" ]; then
  LAST_ENTRIES=$(grep '^\[' "$PROGRESS_FILE" 2>/dev/null | tail -3 | tr '\n' ' | ' || echo "")
fi

# ── Build context string ──
CONTEXT="${PROJECT_NAME} Context | Phase: ${PHASE_PADDED} | Branch: ${BRANCH} | Tasks: ${DONE} done, ${PENDING} pending | Paused: ${PAUSED}"
if [ -n "$LAST_ENTRIES" ]; then
  CONTEXT="$CONTEXT | Recent: $LAST_ENTRIES"
fi

# ── Output JSON (escape via python3 for safety) ──
SAFE_CTX=$(printf '%s' "$CONTEXT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null)
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$SAFE_CTX"
