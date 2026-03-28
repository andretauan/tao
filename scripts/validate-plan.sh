#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# validate-plan.sh — BLOCK gate: BRIEF → PLAN coverage
# ═══════════════════════════════════════════════════════════════
# Ensures everything decided in the brainstorm is reflected
# in the execution plan. Hard blocker: exit 1 if any gap found.
#
# Usage:
#   bash .github/tao/scripts/validate-plan.sh [phase-dir]
#   bash .github/tao/scripts/validate-plan.sh docs/phases/phase-01
#   bash .github/tao/scripts/validate-plan.sh docs/brainstorm
#
# If phase-dir is omitted, auto-detects from tao.config.json.
# Reads: BRIEF.md and PLAN.md from the given directory.
#   - Looks for BRIEF.md and PLAN.md directly inside phase-dir
#   - Also looks inside phase-dir/brainstorm/
#
# Exit: 0 = PASS, 1 = BLOCK

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"

# ─── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Auto-detect phase directory ────────────────────────────────
if [ -n "${1:-}" ]; then
  PHASE_DIR="$1"
else
  # Try tao.config.json first
  if [ -f "$CONFIG_FILE" ]; then
    _phases_dir=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('phases','docs/phases').rstrip('/'))
except:
    print('docs/phases')
" "$CONFIG_FILE" 2>/dev/null) || _phases_dir="docs/phases"
  else
    _phases_dir="docs/phases"
  fi

  PHASES_DIR="$WORKSPACE_DIR/$_phases_dir"

  # Latest phase dir
  PHASE_DIR=$(ls -d "${PHASES_DIR}"/phase-* 2>/dev/null | sort -V | tail -1 || true)

  # Fallback: standalone brainstorm
  if [ -z "$PHASE_DIR" ] && [ -d "$WORKSPACE_DIR/docs/brainstorm" ]; then
    PHASE_DIR="$WORKSPACE_DIR/docs/brainstorm"
  fi
fi

# Make absolute
if [ -n "$PHASE_DIR" ] && [[ "$PHASE_DIR" != /* ]]; then
  PHASE_DIR="$WORKSPACE_DIR/$PHASE_DIR"
fi

if [ -z "$PHASE_DIR" ] || [ ! -d "$PHASE_DIR" ]; then
  echo -e "${RED}ERROR: Could not find phase directory.${NC}"
  echo "Usage: $0 [phase-dir]"
  exit 1
fi

# ─── Locate BRIEF.md and PLAN.md ────────────────────────────────
find_file() {
  local name="$1"
  local dir="$2"
  # Check: dir/name, dir/brainstorm/name
  for candidate in "$dir/$name" "$dir/brainstorm/$name"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

BRIEF_FILE=$(find_file "BRIEF.md" "$PHASE_DIR")
PLAN_FILE=$(find_file "PLAN.md" "$PHASE_DIR")

# ─── Header ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  TAO — Plan Validator                     ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo ""

BLOCKS=0
WARNINGS=0

# ─── V1: BRIEF exists ───────────────────────────────────────────
if [ -z "$BRIEF_FILE" ]; then
  echo -e "${RED}✗ CRITICAL — BRIEF.md not found in: $PHASE_DIR${NC}"
  echo -e "  Create a BRIEF.md first (use @Brainstorm-Wu for brainstorm)."
  echo ""
  echo -e "${RED}${BOLD}🚫 BLOCK — Phase cannot be planned without BRIEF${NC}"
  exit 1
fi

# ─── V2: BRIEF maturity ≥ 5/7 ───────────────────────────────────
MATURITY_RESULT=$(python3 -c "
import re, sys

brief = open(sys.argv[1]).read()

# Find maturity section — between 'Maturity' header and next ---
mat_match = re.search(
    r'(?:Maturity|Maturidade)[^\n]*\n(.*?)(?=\n---|\n##)',
    brief, re.DOTALL | re.IGNORECASE
)

if not mat_match:
    print('0/7:NOT_FOUND')
    sys.exit()

section = mat_match.group(1)
checked   = len(re.findall(r'- \[x\]', section, re.IGNORECASE))
unchecked = len(re.findall(r'- \[ \]', section))
total     = checked + unchecked
if total == 0:
    total = 7  # fallback

print(f'{checked}/{total}:OK' if checked >= 5 else f'{checked}/{total}:LOW')
" "$BRIEF_FILE" 2>/dev/null) || MATURITY_RESULT="0/7:ERROR"

MAT_SCORE="${MATURITY_RESULT%%:*}"
MAT_STATUS="${MATURITY_RESULT##*:}"
MAT_NUM="${MAT_SCORE%%/*}"
MAT_DEN="${MAT_SCORE##*/}"

echo -e "BRIEF: ${BRIEF_FILE#$WORKSPACE_DIR/}"
if [ "$MAT_STATUS" = "OK" ]; then
  echo -e "  Maturity: ${GREEN}${MAT_SCORE} ✅${NC}"
elif [ "$MAT_STATUS" = "NOT_FOUND" ]; then
  echo -e "  Maturity: ${YELLOW}⚠  Checklist not found (assuming OK)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "  Maturity: ${RED}${MAT_SCORE} — BELOW THRESHOLD (need ≥5/7)${NC}"
  BLOCKS=$((BLOCKS + 1))
fi

# ─── Extract active decisions from BRIEF ────────────────────────
DECISIONS_RESULT=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Find all D\d+ references
all_refs = re.findall(r'\bD(\d+)\b', text)
all_ids  = sorted(set(int(x) for x in all_refs))

# Targeted superseded detection — 3 specific patterns (no blanket-line approach)
superseded = set()

# Pattern 1: ~~D{N}~~ strikethrough
for m in re.finditer(r'~~D(\d+)', text):
    superseded.add(int(m.group(1)))

# Pattern 2: 'supersede[sd]? D{N}' — D{N} is explicitly being superseded
for m in re.finditer(r'supersede[sd]?\s+D(\d+)', text, re.IGNORECASE):
    superseded.add(int(m.group(1)))

# Pattern 3: 'D{N}[short delimiter]SUPERSEDED' — header pattern
for m in re.finditer(r'\bD(\d+)\b\s*[-—,()\s]{0,5}SUPERSEDED', text, re.IGNORECASE):
    superseded.add(int(m.group(1)))

active = [d for d in all_ids if d not in superseded]
sup_list = sorted(superseded)

print(','.join(str(d) for d in active))
print(','.join(str(d) for d in sup_list))
" "$BRIEF_FILE" 2>/dev/null) || DECISIONS_RESULT=","

ACTIVE_DECISIONS="${DECISIONS_RESULT%%$'\n'*}"
SUPERSEDED_DECISIONS="${DECISIONS_RESULT##*$'\n'}"

ACTIVE_COUNT=0
if [ -n "$ACTIVE_DECISIONS" ]; then
  ACTIVE_COUNT=$(echo "$ACTIVE_DECISIONS" | tr ',' '\n' | wc -l | tr -d ' ')
fi

echo -e "  Active decisions: ${ACTIVE_COUNT}"
if [ -n "$SUPERSEDED_DECISIONS" ]; then
  echo -e "  Superseded (excluded): D${SUPERSEDED_DECISIONS//,/ D}"
fi

# ─── Extract must-have artifacts from BRIEF ─────────────────────
ARTIFACTS_RESULT=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Find must_haves / Artefatos section
section_match = re.search(
    r'(?:must.haves?|Artefatos obrigat|Mandatory Artifacts?)[^\n]*\n(.*?)(?=\n---|\n## [^#]|\Z)',
    text, re.DOTALL | re.IGNORECASE
)

if not section_match:
    sys.exit()

section = section_match.group(1)

# Two extraction strategies (BRIEFs may or may not use backtick formatting):
# 1. Backtick-wrapped names
backtick_items = re.findall(r'\x60([^\x60]+)\x60', section)
# 2. Plain filenames: Letter + name + .ext (handles items without backticks)
plain_items = re.findall(r'\b([A-Za-z][\w.-]*\.\w{2,10})\b', section)

# Combine, deduplicate (preserve order), filter to valid filenames
seen = set()
artifacts = []
for r in backtick_items + plain_items:
    r = r.strip()
    if r and r not in seen and ('.' in r or '/' in r) and len(r) >= 3:
        seen.add(r)
        artifacts.append(r)

print('\n'.join(artifacts))
" "$BRIEF_FILE" 2>/dev/null) || ARTIFACTS_RESULT=""

ARTIFACT_COUNT=0
if [ -n "$ARTIFACTS_RESULT" ]; then
  ARTIFACT_COUNT=$(echo "$ARTIFACTS_RESULT" | wc -l | tr -d ' ')
fi

echo -e "  Must-have artifacts: ${ARTIFACT_COUNT}"

# ─── V3: PLAN exists ────────────────────────────────────────────
echo ""
if [ -z "$PLAN_FILE" ]; then
  echo -e "${RED}✗ CRITICAL — PLAN.md not found in: $PHASE_DIR${NC}"
  echo -e "  Create a PLAN.md from the BRIEF (use @Brainstorm-Wu plan phase)."
  BLOCKS=$((BLOCKS + 1))
  # Cannot continue without PLAN
  echo ""
  echo -e "${RED}${BOLD}🚫 BLOCK — ${BLOCKS} critical issue(s) found${NC}"
  exit 1
fi

echo -e "PLAN: ${PLAN_FILE#$WORKSPACE_DIR/}"

# ─── V4: PLAN references BRIEF ──────────────────────────────────
HAS_SOURCE=$(python3 -c "
import sys
text = open(sys.argv[1]).read()
import re
found = re.search(r'(?:Source:|Provenance:|Fonte:|Source BRIEF)', text, re.IGNORECASE)
print('YES' if found else 'NO')
" "$PLAN_FILE" 2>/dev/null) || HAS_SOURCE="NO"

if [ "$HAS_SOURCE" = "YES" ]; then
  echo -e "  References BRIEF: ${GREEN}✅${NC}"
else
  echo -e "  References BRIEF: ${YELLOW}⚠  No 'Source:' line found — provenance unclear${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# ─── Extract tasks from PLAN ────────────────────────────────────
PLAN_DATA=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Tasks: **T{NN}** or **T{N}**
task_matches = re.findall(r'\*\*T(\d+)\*\*', text)
task_ids = sorted(set(int(t) for t in task_matches))

# Decision refs in task lines (D{N} patterns)
decisions_covered = set()
for line in text.splitlines():
    if re.search(r'\*\*T\d+\*\*', line) or re.search(r'D\d+', line):
        refs = re.findall(r'\bD(\d+)\b', line)
        for r in refs:
            decisions_covered.add(int(r))

# Also scan full text for decision references
all_d_refs = re.findall(r'\bD(\d+)\b', text)
for r in all_d_refs:
    decisions_covered.add(int(r))

print(','.join(str(t) for t in task_ids))
print(','.join(str(d) for d in sorted(decisions_covered)))
" "$PLAN_FILE" 2>/dev/null) || PLAN_DATA=","

PLAN_TASK_IDS="${PLAN_DATA%%$'\n'*}"
PLAN_DECISION_REFS="${PLAN_DATA##*$'\n'}"

TASK_COUNT=0
if [ -n "$PLAN_TASK_IDS" ]; then
  TASK_COUNT=$(echo "$PLAN_TASK_IDS" | tr ',' '\n' | wc -l | tr -d ' ')
fi

echo -e "  Tasks: ${TASK_COUNT}"

# ─── Decision → Task line in STATUS header ──────────────────────
echo ""

# ─── V5: Decision coverage ──────────────────────────────────────
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Decision Coverage${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

if [ -z "$ACTIVE_DECISIONS" ]; then
  echo -e "${YELLOW}  ⚠  No decisions found in BRIEF (check format)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  # Convert comma-separated to array for iteration
  IFS=',' read -ra DEC_ARRAY <<< "$ACTIVE_DECISIONS"
  COVERED=0
  MISSING=0
  MISSING_LIST=""

  for d in "${DEC_ARRAY[@]}"; do
    [ -z "$d" ] && continue
    # Check if D{d} appears in PLAN decision refs
    if echo ",$PLAN_DECISION_REFS," | grep -qE ",${d},"; then
      echo -e "  ${GREEN}✅ D${d}${NC}"
      COVERED=$((COVERED + 1))
    else
      echo -e "  ${RED}❌ D${d} — NOT FOUND in any task${NC}"
      MISSING=$((MISSING + 1))
      MISSING_LIST="${MISSING_LIST} D${d}"
      BLOCKS=$((BLOCKS + 1))
    fi
  done

  echo ""
  if [ "$MISSING" -eq 0 ]; then
    echo -e "  ${GREEN}${COVERED}/${ACTIVE_COUNT} decisions covered ✅${NC}"
  else
    echo -e "  ${RED}${COVERED}/${ACTIVE_COUNT} covered — ${MISSING} MISSING:${MISSING_LIST}${NC}"
  fi
fi

# ─── V6: Must-have artifact coverage ────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Must-Have Artifact Coverage${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

if [ -z "$ARTIFACTS_RESULT" ]; then
  echo -e "${YELLOW}  ⚠  No must-have artifacts found in BRIEF §7${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  ART_COVERED=0
  ART_MISSING=0

  while IFS= read -r artifact; do
    [ -z "$artifact" ] && continue
    # Get just the filename for matching (strip path components)
    basename_art=$(basename "$artifact")
    # Search for this artifact directly in PLAN file (more reliable than echo|grep)
    if grep -qF "$basename_art" "$PLAN_FILE" 2>/dev/null; then
      echo -e "  ${GREEN}✅${NC} \`${artifact}\`"
      ART_COVERED=$((ART_COVERED + 1))
    else
      echo -e "  ${RED}❌${NC} \`${artifact}\` — NOT FOUND in any task"
      ART_MISSING=$((ART_MISSING + 1))
      BLOCKS=$((BLOCKS + 1))
    fi
  done <<< "$ARTIFACTS_RESULT"

  echo ""
  if [ "$ART_MISSING" -eq 0 ]; then
    echo -e "  ${GREEN}${ART_COVERED}/${ARTIFACT_COUNT} artifacts covered ✅${NC}"
  else
    echo -e "  ${RED}${ART_COVERED}/${ARTIFACT_COUNT} covered — ${ART_MISSING} MISSING${NC}"
  fi
fi

# ─── V7: Scope-out overlap check (WARNING only) ─────────────────
SCOPE_OUT=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Find out-of-scope section
match = re.search(
    r'(?:Out of Scope|NÃO Implementar|Not in Scope|Scope Out)[^\n]*\n(.*?)(?=\n###|\n##|\n---|\Z)',
    text, re.DOTALL | re.IGNORECASE
)
if not match:
    sys.exit()

section = match.group(1)
# Extract bullet items
items = re.findall(r'^[-*]\s+(.+)$', section, re.MULTILINE)
for item in items[:10]:  # limit to 10
    print(item.strip())
" "$BRIEF_FILE" 2>/dev/null) || SCOPE_OUT=""

if [ -n "$SCOPE_OUT" ]; then
  PLAN_TEXT_LOWER=$(cat "$PLAN_FILE" | tr '[:upper:]' '[:lower:]')
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    # Take first 3+ words as search key
    KEY=$(echo "$item" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | awk '{print $1" "$2" "$3}')
    if [ -n "$KEY" ] && echo "$PLAN_TEXT_LOWER" | grep -qF "$KEY" 2>/dev/null; then
      echo -e "${YELLOW}  ⚠  Scope-OUT item may appear in PLAN: \"${item}\"${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  done <<< "$SCOPE_OUT"
fi

# ─── Final result ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"

if [ "$BLOCKS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS — Plan covers all brainstorm items${NC}"
elif [ "$BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS${NC} ${YELLOW}(${WARNINGS} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} Result: 🚫 BLOCK — ${BLOCKS} decision(s)/artifact(s) not covered${NC}"
  echo ""
  echo -e "${YELLOW}  Fix: ensure every active decision (D{N}) from the BRIEF${NC}"
  echo -e "${YELLOW}  is referenced in at least one task in PLAN.md${NC}"
fi

echo -e "${BOLD}════════════════════════════════════════════${NC}"
echo ""

if [ "$BLOCKS" -gt 0 ]; then
  exit 1
fi
exit 0
