#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# validate-brainstorm.sh — TAO brainstorm quality gate
# ═══════════════════════════════════════════════════════════════
# Validates that brainstorm artifacts (DISCOVERY.md, DECISIONS.md,
# BRIEF.md) exist and contain substantive content — not just
# empty templates.
#
# Called by Tao after Wu completes brainstorm (BRAINSTORM_GATE).
# Exit 0 = PASS, Exit 1 = BLOCK.

set -euo pipefail

WORKSPACE_DIR="$(pwd)"
PHASE_DIR="${1:-}"

# ─── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

BLOCKS=0
WARNINGS=0

ok()   { echo -e "  ${GREEN}✅${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠ ${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo -e "  ${RED}❌ BLOCK${NC} — $1"; BLOCKS=$((BLOCKS + 1)); }
info() { echo -e "  ${CYAN}→${NC} $1"; }

# ─── Resolve phase directory ──────────────────────────────────
CONFIG_FILE=".github/tao/tao.config.json"

if [ -z "$PHASE_DIR" ]; then
  if [ -f "$CONFIG_FILE" ]; then
    _phases_dir=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('phases','docs/phases'))
except:
    print('docs/phases')
" "$CONFIG_FILE" 2>/dev/null) || _phases_dir="docs/phases"
  else
    _phases_dir="docs/phases"
  fi

  PHASE_DIR=$(ls -d "${WORKSPACE_DIR}/${_phases_dir}"/phase-* 2>/dev/null | \
    sort -V | tail -1 2>/dev/null || true)

  if [ -z "$PHASE_DIR" ]; then
    echo -e "${YELLOW}No phase directory found — nothing to validate.${NC}"
    exit 0
  fi
fi

# Make absolute if relative
if [[ "$PHASE_DIR" != /* ]]; then
  PHASE_DIR="$WORKSPACE_DIR/$PHASE_DIR"
fi

BRAINSTORM_DIR="$PHASE_DIR/brainstorm"

echo ""
echo -e "${BOLD}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}  TAO — Brainstorm Validator               ${NC}"
echo -e "${BOLD}═══════════════════════════════════════════${NC}"
echo ""
echo -e "Phase: ${PHASE_DIR##*/}"
echo ""

# ─── V1: brainstorm/ directory exists ─────────────────────────
if [ ! -d "$BRAINSTORM_DIR" ]; then
  fail "brainstorm/ directory does not exist in ${PHASE_DIR##*/}"
  info "Run @Brainstorm-Wu to brainstorm this phase first."
  echo ""
  echo -e "${RED}${BOLD}🚫 BLOCK — No brainstorm artifacts found${NC}"
  exit 1
fi

# ─── V2: DISCOVERY.md exists and has content ──────────────────
echo -e "${BOLD}── V1: DISCOVERY.md — exploration content ──${NC}"
DISCOVERY_FILE="$BRAINSTORM_DIR/DISCOVERY.md"

if [ ! -f "$DISCOVERY_FILE" ]; then
  fail "DISCOVERY.md not found in brainstorm/"
  info "Wu must create DISCOVERY.md with exploration, reasoning chains, and references."
else
  _disc_lines=$(grep -cvE '^\s*$|^\s*#|^\s*>|^\s*<!--|^\s*---' "$DISCOVERY_FILE" 2>/dev/null || echo "0")
  _disc_sections=$(grep -cE '^#{1,3} ' "$DISCOVERY_FILE" 2>/dev/null || echo "0")

  if [ "$_disc_lines" -lt 10 ]; then
    fail "DISCOVERY.md has only ${_disc_lines} content lines (minimum: 10)"
    info "Wu must save exploration, reasoning, counter-arguments — not just headers."
  elif [ "$_disc_sections" -lt 2 ]; then
    warn "DISCOVERY.md has few sections (${_disc_sections}) — may be incomplete"
  else
    ok "DISCOVERY.md has ${_disc_lines} content lines across ${_disc_sections} sections"
  fi
fi

# ─── V3: DECISIONS.md exists and has D{N} entries ─────────────
echo ""
echo -e "${BOLD}── V2: DECISIONS.md — IBIS decisions ──────${NC}"
DECISIONS_FILE="$BRAINSTORM_DIR/DECISIONS.md"

if [ ! -f "$DECISIONS_FILE" ]; then
  fail "DECISIONS.md not found in brainstorm/"
  info "Wu must create DECISIONS.md with D{N} entries following IBIS protocol."
else
  _dec_count=$(python3 -c "
import re
text = open('$DECISIONS_FILE').read()
decisions = set(re.findall(r'\bD(\d+)\b', text))
print(len(decisions))
" 2>/dev/null || echo "0")

  _has_positions=$(grep -ciE 'position|posição|argument|argumento|pro:|con:' "$DECISIONS_FILE" 2>/dev/null || echo "0")

  if [ "$_dec_count" = "0" ]; then
    fail "DECISIONS.md has no D{N} decision entries"
    info "Wu must register decisions as D1, D2, etc. with positions and arguments."
  elif [ "$_has_positions" -lt 2 ]; then
    fail "DECISIONS.md has ${_dec_count} decision(s) but no positions/arguments"
    info "Each decision needs positions, arguments, and counter-arguments (IBIS protocol)."
  else
    ok "DECISIONS.md has ${_dec_count} decision(s) with argumentation"
  fi
fi

# ─── V4: BRIEF.md exists, has content, maturity ≥ 5/7 ───────
echo ""
echo -e "${BOLD}── V3: BRIEF.md — synthesis + maturity ────${NC}"
BRIEF_FILE="$BRAINSTORM_DIR/BRIEF.md"

if [ ! -f "$BRIEF_FILE" ]; then
  fail "BRIEF.md not found in brainstorm/"
  info "Wu must synthesize exploration into BRIEF.md when maturity ≥ 5/7."
else
  # Check maturity
  _mat_result=$(python3 -c "
import re, sys
text = open(sys.argv[1]).read()
mat = re.search(r'^##\s+(?:Maturity|Maturidade)[^\n]*\n(.*?)(?=\n---|\n## )', text, re.DOTALL|re.IGNORECASE|re.MULTILINE)
if not mat:
    print('NO_CHECKLIST')
    sys.exit()
checked = len(re.findall(r'- \[x\]', mat.group(1), re.IGNORECASE))
unchecked = len(re.findall(r'- \[ \]', mat.group(1)))
total = checked + unchecked
if total == 0:
    total = 7
print(f'{checked}/{total}')
" "$BRIEF_FILE" 2>/dev/null || echo "ERROR")

  case "$_mat_result" in
    NO_CHECKLIST)
      warn "BRIEF.md has no maturity checklist section"
      ;;
    ERROR)
      warn "Could not parse BRIEF.md maturity"
      ;;
    *)
      _mat_num="${_mat_result%%/*}"
      if [ "$_mat_num" -ge 5 ] 2>/dev/null; then
        ok "BRIEF maturity: ${_mat_result} ✅"
      else
        fail "BRIEF maturity: ${_mat_result} — below gate (need ≥ 5/7)"
        info "Continue brainstorming until maturity ≥ 5/7."
      fi
      ;;
  esac

  # Check BRIEF has scope (IN/OUT)
  _has_scope=$(grep -ciE 'scope|escopo|will not|não (vai|irá)|out of scope|fora do escopo' "$BRIEF_FILE" 2>/dev/null || echo "0")
  if [ "$_has_scope" -lt 1 ]; then
    warn "BRIEF.md may be missing scope definition (what's IN vs OUT)"
  else
    ok "BRIEF.md has scope definition"
  fi

  # Check BRIEF references decisions
  _brief_decisions=$(python3 -c "
import re
text = open('$BRIEF_FILE').read()
print(len(set(re.findall(r'\bD(\d+)\b', text))))
" 2>/dev/null || echo "0")

  if [ "$_brief_decisions" = "0" ]; then
    warn "BRIEF.md does not reference any D{N} decisions"
  else
    ok "BRIEF.md references ${_brief_decisions} decision(s)"
  fi
fi

# ─── V5: Cross-reference DECISIONS ↔ BRIEF ───────────────────
echo ""
echo -e "${BOLD}── V4: Cross-reference — DECISIONS ↔ BRIEF ─${NC}"

if [ -f "$DECISIONS_FILE" ] && [ -f "$BRIEF_FILE" ]; then
  _cross_result=$(python3 -c "
import re
dec_text = open('$DECISIONS_FILE').read()
brief_text = open('$BRIEF_FILE').read()

dec_ids = sorted(set(int(x) for x in re.findall(r'\bD(\d+)\b', dec_text)))
brief_ids = set(int(x) for x in re.findall(r'\bD(\d+)\b', brief_text))

missing = [f'D{d}' for d in dec_ids if d not in brief_ids]
if missing:
    print('MISSING:' + ','.join(missing))
else:
    print('OK:' + str(len(dec_ids)))
" 2>/dev/null || echo "ERROR")

  case "$_cross_result" in
    OK:*)
      _count="${_cross_result#OK:}"
      ok "All ${_count} decisions from DECISIONS.md referenced in BRIEF.md"
      ;;
    MISSING:*)
      _missed="${_cross_result#MISSING:}"
      fail "Decisions in DECISIONS.md but NOT in BRIEF.md: ${_missed}"
      info "BRIEF must reference every active decision from DECISIONS.md."
      ;;
    *)
      warn "Could not cross-reference DECISIONS ↔ BRIEF"
      ;;
  esac
else
  warn "Cannot cross-reference — missing DECISIONS.md or BRIEF.md"
fi

# ─── Result ───────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$BLOCKS" -eq 0 ]; then
  if [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}${BOLD} Result: ✅ PASS — Brainstorm artifacts are complete${NC}"
  else
    echo -e "${GREEN}${BOLD} Result: ✅ PASS${NC} ${YELLOW}(${WARNINGS} warning(s))${NC}"
  fi
  echo -e "${BOLD}════════════════════════════════════════════${NC}"
  exit 0
else
  echo -e "${RED}${BOLD} Result: 🚫 BLOCK — ${BLOCKS} issue(s) found${NC}"
  echo ""
  echo -e "  Fix all BLOCK items before proceeding to planning."
  echo -e "  Rerun: bash .github/tao/scripts/validate-brainstorm.sh [phase-dir]"
  echo -e "${BOLD}════════════════════════════════════════════${NC}"
  exit 1
fi
