#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# doc-validate.sh — BLOCK gate: Documentation completeness
# ═══════════════════════════════════════════════════════════════
# Validates that all execution artifacts are properly documented:
#
#   D1. CHANGELOG.md has entries with YYYY-MM-DD HH:MM + agent name
#   D2. CONTEXT.md has been updated (no date placeholder, status current)
#   D3. progress.txt has timestamped session entries
#   D4. STATUS.md has ✅ entries (work was actually done)
#   D5. Each ✅ task in STATUS.md has matching progress.txt entry
#
# "What was done is documented with date and executor agent name? NO = BLOCK"
#
# Usage:
#   bash .github/tao/scripts/doc-validate.sh [phase-dir]
#
# Exit: 0 = PASS, 1 = BLOCK

set -uo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"

# ─── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

if [[ "${NO_COLOR:-}" == "1" ]] || [[ "${TERM:-}" == "dumb" ]]; then
  RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ─── Resolve phase directory ──────────────────────────────────────
if [ -n "${1:-}" ]; then
  PHASE_DIR="$1"
  [[ "$PHASE_DIR" != /* ]] && PHASE_DIR="$WORKSPACE_DIR/$PHASE_DIR"
else
  _phases_dir="docs/phases"
  if [ -f "$CONFIG_FILE" ]; then
    _phases_dir=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('phases','docs/phases').rstrip('/'))
except:
    print('docs/phases')
" "$CONFIG_FILE" 2>/dev/null) || _phases_dir="docs/phases"
  fi
  PHASE_DIR=$(ls -d "${WORKSPACE_DIR}/${_phases_dir}"/phase-* 2>/dev/null | \
    sort -t- -k2 -n 2>/dev/null | tail -1 || true)
fi

# ─── Header ──────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  TAO — Documentation Validator            ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo ""

BLOCKS=0
WARNINGS=0

# ─── Locate files ────────────────────────────────────────────────
CHANGELOG_FILE="$WORKSPACE_DIR/.github/tao/CHANGELOG.md"
CONTEXT_FILE="$WORKSPACE_DIR/.github/tao/CONTEXT.md"

STATUS_FILE=""
PROGRESS_FILE=""
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  echo -e "Phase: ${PHASE_DIR##*/}"
  echo ""
  for candidate in "$PHASE_DIR/STATUS.md" "$PHASE_DIR/brainstorm/STATUS.md"; do
    [ -f "$candidate" ] && STATUS_FILE="$candidate" && break
  done
  [ -f "$PHASE_DIR/progress.txt" ] && PROGRESS_FILE="$PHASE_DIR/progress.txt"
else
  echo -e "${YELLOW}⚠  No phase directory supplied — checking project-level docs only${NC}"
  echo ""
fi

# ─── D1: CHANGELOG.md existe e tem entradas com data + agente ────
echo -e "${BOLD}── D1: CHANGELOG.md — date + agent entries ─${NC}"
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo -e "  ${RED}❌ BLOCK — CHANGELOG.md not found${NC}"
  BLOCKS=$((BLOCKS + 1))
else
  # Must have at least 1 entry with YYYY-MM-DD HH:MM format
  DATE_ENTRIES=$(grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}' "$CHANGELOG_FILE" 2>/dev/null || true)
  DATE_ENTRIES=${DATE_ENTRIES:-0}

  # Must reference an agent name in at least one entry
  # Accepted: @Execute-Tao, @Brainstorm-Wu, @Investigate-Shen, @Shen, @Di, @Qi, or any @word
  AGENT_ENTRIES=$(grep -cE '@(Execute-Tao|Executar-Tao|Brainstorm-Wu|Investigate-Shen|Investigar-Shen|Shen|Di|Qi)\b|Agent:\s*(Execute-Tao|Executar-Tao|Brainstorm-Wu|Investigate-Shen|Investigar-Shen|Shen|Di|Qi)' \
    "$CHANGELOG_FILE" 2>/dev/null || true)
  AGENT_ENTRIES=${AGENT_ENTRIES:-0}

  if [ "$DATE_ENTRIES" -eq 0 ]; then
    echo -e "  ${RED}❌ BLOCK — No dated entries (YYYY-MM-DD HH:MM) in CHANGELOG.md${NC}"
    echo -e "     Expected: entries from agent documenting their work"
    BLOCKS=$((BLOCKS + 1))
  else
    echo -e "  ${GREEN}✅ ${DATE_ENTRIES} dated entries found${NC}"
  fi

  if [ "$AGENT_ENTRIES" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠  No agent attribution found in CHANGELOG.md${NC}"
    echo -e "     Expected pattern: '@Execute-Tao' or '@Executar-Tao' or 'Agent: Tao' in at least one entry"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "  ${GREEN}✅ Agent attribution present (${AGENT_ENTRIES} entries)${NC}"
  fi

  # Latest entry is not too old (warn if > 7 days without explanation)
  LATEST_DATE=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$CHANGELOG_FILE" 2>/dev/null | sort | tail -1 || echo "")
  if [ -n "$LATEST_DATE" ]; then
    echo -e "  ${GREEN}→${NC} Latest entry: ${LATEST_DATE}"
  fi
fi
echo ""

# ─── D2: CONTEXT.md foi atualizado ───────────────────────────────
echo -e "${BOLD}── D2: CONTEXT.md — updated status ─────────${NC}"
if [ ! -f "$CONTEXT_FILE" ]; then
  echo -e "  ${RED}❌ BLOCK — CONTEXT.md not found${NC}"
  BLOCKS=$((BLOCKS + 1))
else
  # Must NOT have placeholder [YYYY-MM-DD HH:MM]
  if grep -qF '[YYYY-MM-DD HH:MM]' "$CONTEXT_FILE" 2>/dev/null; then
    echo -e "  ${RED}❌ BLOCK — CONTEXT.md still has [YYYY-MM-DD HH:MM] placeholder${NC}"
    echo -e "     Agents MUST update 'Last updated' before session ends."
    BLOCKS=$((BLOCKS + 1))
  else
    _ctx_date=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$CONTEXT_FILE" 2>/dev/null | sort | tail -1 || echo "")
    if [ -n "$_ctx_date" ]; then
      echo -e "  ${GREEN}✅ CONTEXT.md updated: ${_ctx_date}${NC}"
    else
      echo -e "  ${YELLOW}⚠  CONTEXT.md has no date — uncertain if updated${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  # Status should NOT be new_project/novo_projeto if CHANGELOG has entries
  _ctx_status=$(grep -oE 'status:\s*\S+' "$CONTEXT_FILE" 2>/dev/null | head -1 | sed 's/status:[[:space:]]*//')
  _changelog_dated=$(grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$CHANGELOG_FILE" 2>/dev/null || true)
  _changelog_dated=${_changelog_dated:-0}
  if [[ "$_ctx_status" =~ ^(new_project|novo_projeto)$ ]] && [ "$_changelog_dated" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠  CONTEXT.md status is '${_ctx_status}' but CHANGELOG has entries${NC}"
    echo -e "     Update status to: planning | in_progress | completed"
    WARNINGS=$((WARNINGS + 1))
  elif [ -n "$_ctx_status" ]; then
    echo -e "  ${GREEN}✅ Status: ${_ctx_status}${NC}"
  fi
fi
echo ""

# ─── D3: progress.txt tem entradas com timestamp ─────────────────
echo -e "${BOLD}── D3: progress.txt — timestamped entries ───${NC}"
if [ -z "$PROGRESS_FILE" ]; then
  echo -e "  ${YELLOW}⚠  progress.txt not found in phase dir — skipping${NC}"
  WARNINGS=$((WARNINGS + 1))
elif [ ! -f "$PROGRESS_FILE" ]; then
  echo -e "  ${RED}❌ BLOCK — progress.txt not found${NC}"
  BLOCKS=$((BLOCKS + 1))
else
  _prog_entries=$(grep -cE '^\[20[0-9]{2}-[0-9]{2}-[0-9]{2}' "$PROGRESS_FILE" 2>/dev/null || true)
  _prog_entries=${_prog_entries:-0}
  _prog_agent=$(grep -cE '@(Tao|Shen|Wu|Di|Qi)|Agent:\s*(Execute-Tao|Executar-Tao|Brainstorm-Wu|Investigate-Shen|Investigar-Shen|Shen|Di|Qi)' "$PROGRESS_FILE" 2>/dev/null || true)
  _prog_agent=${_prog_agent:-0}

  if [ "$_prog_entries" -eq 0 ]; then
    echo -e "  ${RED}❌ BLOCK — progress.txt has no [YYYY-MM-DD HH:MM] log entries${NC}"
    echo -e "     Every executed task must be logged by the agent."
    BLOCKS=$((BLOCKS + 1))
  else
    echo -e "  ${GREEN}✅ ${_prog_entries} timestamped entries in progress.txt${NC}"
  fi

  if [ "$_prog_agent" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠  No agent name in progress.txt entries${NC}"
    echo -e "     Format: [YYYY-MM-DD HH:MM] @Execute-Tao — TNN: description"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "  ${GREEN}✅ Agent attribution in progress.txt${NC}"
  fi
fi
echo ""

# ─── D4: STATUS.md tem ✅ se o agente declarou trabalho feito ────
echo -e "${BOLD}── D4: STATUS.md — tasks marked ✅ ─────────${NC}"
if [ -z "$STATUS_FILE" ]; then
  echo -e "  ${YELLOW}⚠  STATUS.md not found — skipping${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  _done=$(grep '^|' "$STATUS_FILE" 2>/dev/null | grep -c '✅' || true)
  _done=${_done:-0}
  _pending=$(grep '^|' "$STATUS_FILE" 2>/dev/null | grep -c '⏳' || true)
  _pending=${_pending:-0}
  _total=$(( _done + _pending ))

  if [ "$_total" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠  STATUS.md has no tasks (empty table)${NC}"
    WARNINGS=$((WARNINGS + 1))
  elif [ "$_done" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠  STATUS.md has no ✅ tasks — no work completed or agent forgot to mark${NC}"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "  ${GREEN}✅ ${_done}/${_total} tasks marked done (✅)${NC}"
  fi
fi
echo ""

# ─── D5: Cada ✅ no STATUS tem entrada em progress.txt ───────────
echo -e "${BOLD}── D5: STATUS ✅ ↔ progress.txt cross-check ─${NC}"
if [ -n "$STATUS_FILE" ] && [ -n "$PROGRESS_FILE" ] && [ -f "$PROGRESS_FILE" ]; then
  DONE_TASKS=$(python3 -c "
import re, sys
text = open(sys.argv[1]).read()
done = []
for line in text.splitlines():
    if '|' not in line or '✅' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        done.append(cols[0].lstrip('T').zfill(2))
print('\n'.join(done))
" "$STATUS_FILE" 2>/dev/null || true)

  if [ -n "$DONE_TASKS" ]; then
    MISSING_LOG=0
    while IFS= read -r tid; do
      [ -z "$tid" ] && continue
      # Check progress.txt mentions TNN or T0X
      if grep -qE "T0*${tid#0}" "$PROGRESS_FILE" 2>/dev/null; then
        echo -e "  ${GREEN}✅ T${tid} logged in progress.txt${NC}"
      else
        echo -e "  ${YELLOW}⚠  T${tid} marked ✅ in STATUS but not found in progress.txt${NC}"
        MISSING_LOG=$((MISSING_LOG + 1))
        WARNINGS=$((WARNINGS + 1))
      fi
    done <<< "$DONE_TASKS"
    if [ "$MISSING_LOG" -gt 0 ]; then
      echo -e "  ${YELLOW}  ${MISSING_LOG} task(s) missing from progress log${NC}"
    fi
  else
    echo -e "  ${GREEN}✅ No completed tasks to cross-check${NC}"
  fi
else
  echo -e "  ${YELLOW}⚠  Cannot cross-check: STATUS.md or progress.txt not available${NC}"
fi
echo ""

# ─── D6: Timestamp format enforcement (R4) ───────────────────────
echo -e "${BOLD}── D6: Timestamp format (R4) ───────────────${NC}"

_ts_issues=0

# Check CONTEXT.md for valid timestamp (not placeholder)
if [ -f "$CONTEXT_FILE" ]; then
  _ctx_ts=$(grep -cE '\d{4}-\d{2}-\d{2} \d{2}:\d{2}' "$CONTEXT_FILE" 2>/dev/null) || _ctx_ts=0
  _ctx_placeholder=$(grep -c '\[YYYY-MM-DD HH:MM\]' "$CONTEXT_FILE" 2>/dev/null) || _ctx_placeholder=0
  if [ "$_ctx_placeholder" -gt 0 ] && [ "$_ctx_ts" -eq 0 ]; then
    echo -e "  ${RED}❌ BLOCK — CONTEXT.md has only placeholder timestamps${NC}"
    echo -e "  ${CYAN}→${NC} Agent must replace [YYYY-MM-DD HH:MM] with actual timestamps"
    BLOCKS=$((BLOCKS + 1))
    _ts_issues=$((_ts_issues + 1))
  fi
fi

# Check CHANGELOG.md for valid timestamps
if [ -f "$CHANGELOG_FILE" ]; then
  _clog_ts=$(grep -cE '\d{4}-\d{2}-\d{2} \d{2}:\d{2}' "$CHANGELOG_FILE" 2>/dev/null) || _clog_ts=0
  if [ "$_clog_ts" -eq 0 ]; then
    echo -e "  ${RED}❌ BLOCK — CHANGELOG.md has no YYYY-MM-DD HH:MM timestamps${NC}"
    BLOCKS=$((BLOCKS + 1))
    _ts_issues=$((_ts_issues + 1))
  fi
fi

# Check progress.txt for valid timestamps
if [ -n "$PROGRESS_FILE" ] && [ -f "$PROGRESS_FILE" ]; then
  _prog_ts=$(grep -cE '\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\]' "$PROGRESS_FILE" 2>/dev/null) || _prog_ts=0
  if [ "$_prog_ts" -eq 0 ]; then
    echo -e "  ${RED}❌ BLOCK — progress.txt has no [YYYY-MM-DD HH:MM] timestamps${NC}"
    BLOCKS=$((BLOCKS + 1))
    _ts_issues=$((_ts_issues + 1))
  fi
fi

if [ "$_ts_issues" -eq 0 ]; then
  echo -e "  ${GREEN}✅ All documentation files have valid timestamps${NC}"
fi
echo ""

# ─── D7: Brainstorm persistence enforcement ──────────────────────
echo -e "${BOLD}── D7: Brainstorm artifacts persisted ──────${NC}"
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR/brainstorm" ]; then
  _bs_ok=0
  _bs_total=0

  for _bs_file in DISCOVERY.md DECISIONS.md BRIEF.md; do
    _bs_total=$((_bs_total + 1))
    if [ -f "$PHASE_DIR/brainstorm/$_bs_file" ]; then
      _bs_lines=$(wc -l < "$PHASE_DIR/brainstorm/$_bs_file" 2>/dev/null || echo "0")
      if [ "$_bs_lines" -gt 5 ]; then
        _bs_ok=$((_bs_ok + 1))
      else
        echo -e "  ${RED}❌ BLOCK — brainstorm/$_bs_file has only ${_bs_lines} lines (empty/stub)${NC}"
        BLOCKS=$((BLOCKS + 1))
      fi
    else
      echo -e "  ${RED}❌ BLOCK — brainstorm/$_bs_file not found${NC}"
      BLOCKS=$((BLOCKS + 1))
    fi
  done

  if [ "$_bs_ok" -eq "$_bs_total" ]; then
    echo -e "  ${GREEN}✅ All ${_bs_total} brainstorm artifacts present and substantive${NC}"
  fi
else
  echo -e "  ${YELLOW}⚠  No brainstorm/ directory — skipping${NC}"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ─── Final result ─────────────────────────────────────────────────
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$BLOCKS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS — Documentation complete and traceable${NC}"
elif [ "$BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS${NC} ${YELLOW}(${WARNINGS} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} Result: 🚫 BLOCK — ${BLOCKS} documentation gap(s) found${NC}"
  echo ""
  echo -e "${YELLOW}  Every task must be documented with:${NC}"
  echo -e "${YELLOW}  — CHANGELOG.md: date (YYYY-MM-DD HH:MM) + agent name${NC}"
  echo -e "${YELLOW}  — progress.txt: [YYYY-MM-DD HH:MM] @Agent — TNN: description${NC}"
  echo -e "${YELLOW}  — CONTEXT.md: updated 'Last updated' field${NC}"
fi
echo -e "${BOLD}════════════════════════════════════════════${NC}"
echo ""

[ "$BLOCKS" -gt 0 ] && exit 1
exit 0
