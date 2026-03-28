#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# validate-execution.sh — BLOCK gate: PLAN → EXECUTION fidelity
# ═══════════════════════════════════════════════════════════════
# Ensures everything in the PLAN was actually executed:
# all tasks ✅ in STATUS, expected artifacts exist on disk,
# no placeholder residuals, shell scripts syntax-valid.
#
# Usage:
#   bash .github/tao/scripts/validate-execution.sh [phase-dir]
#   bash .github/tao/scripts/validate-execution.sh docs/phases/phase-01
#   bash .github/tao/scripts/validate-execution.sh docs/brainstorm
#
# If phase-dir is omitted, auto-detects from tao.config.json.
# Reads: PLAN.md and STATUS.md from the given directory.
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
  PHASE_DIR=$(ls -d "${PHASES_DIR}"/phase-* 2>/dev/null | sort -V | tail -1 || true)

  if [ -z "$PHASE_DIR" ] && [ -d "$WORKSPACE_DIR/docs/brainstorm" ]; then
    PHASE_DIR="$WORKSPACE_DIR/docs/brainstorm"
  fi
fi

if [ -n "$PHASE_DIR" ] && [[ "$PHASE_DIR" != /* ]]; then
  PHASE_DIR="$WORKSPACE_DIR/$PHASE_DIR"
fi

if [ -z "$PHASE_DIR" ] || [ ! -d "$PHASE_DIR" ]; then
  echo -e "${RED}ERROR: Could not find phase directory.${NC}"
  echo "Usage: $0 [phase-dir]"
  exit 1
fi

# ─── Locate PLAN.md and STATUS.md ───────────────────────────────
find_file() {
  local name="$1"
  local dir="$2"
  for candidate in "$dir/$name" "$dir/brainstorm/$name"; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

PLAN_FILE=$(find_file "PLAN.md" "$PHASE_DIR")
STATUS_FILE=$(find_file "STATUS.md" "$PHASE_DIR")

# ─── Header ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  TAO — Execution Validator                ${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════${NC}"
echo ""

BLOCKS=0
WARNINGS=0

# ─── E1: PLAN exists ────────────────────────────────────────────
if [ -z "$PLAN_FILE" ]; then
  echo -e "${RED}✗ CRITICAL — PLAN.md not found in: $PHASE_DIR${NC}"
  BLOCKS=$((BLOCKS + 1))
  echo -e "${RED}${BOLD}🚫 BLOCK — Cannot validate execution without a plan${NC}"
  exit 1
fi

# ─── E2: STATUS exists ──────────────────────────────────────────
if [ -z "$STATUS_FILE" ]; then
  echo -e "${RED}✗ CRITICAL — STATUS.md not found in: $PHASE_DIR${NC}"
  echo -e "  STATUS.md tracks task completion (⏳/✅/❌)."
  BLOCKS=$((BLOCKS + 1))
  echo -e "${RED}${BOLD}🚫 BLOCK — Cannot validate execution without STATUS.md${NC}"
  exit 1
fi

echo -e "PLAN:   ${PLAN_FILE#$WORKSPACE_DIR/}"
echo -e "STATUS: ${STATUS_FILE#$WORKSPACE_DIR/}"
echo ""

# ─── Extract tasks from PLAN ────────────────────────────────────
PLAN_TASKS=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Tasks: **T{NN}** or T{NN} in table rows
task_matches = re.findall(r'\bT(\d+)\b', text)
task_ids = sorted(set(int(t) for t in task_matches))

for tid in task_ids:
    # Extract description — try bold format first, then table format
    match = re.search(
        r'\*\*T' + str(tid) + r'\*\*\s*[-—–]?\s*([^\n]{0,80})',
        text
    )
    if not match:
        match = re.search(
            r'\|\s*T0*' + str(tid) + r'\s*\|\s*([^|\n]{0,80})',
            text
        )
    desc = match.group(1).strip() if match else ''
    # Clean markdown formatting
    desc = re.sub(r'\*\*([^*]+)\*\*', r'\1', desc)
    desc = re.sub(r'\*([^*]+)\*', r'\1', desc)
    print(f'T{tid:02d}:{desc[:60]}')
" "$PLAN_FILE" 2>/dev/null) || PLAN_TASKS=""

PLAN_TASK_COUNT=0
if [ -n "$PLAN_TASKS" ]; then
  PLAN_TASK_COUNT=$(echo "$PLAN_TASKS" | wc -l | tr -d ' ')
fi
echo -e "PLAN tasks:   ${PLAN_TASK_COUNT}"

# ─── Extract statuses from STATUS ───────────────────────────────
STATUS_DATA=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Match table rows with T{NN} or bare number and status emoji
# Handles: | T08 | name | ✅ | and | 08 | name | ✅ |
status_map = {}
for line in text.splitlines():
    # Look for table rows
    if '|' not in line:
        continue
    cols = [c.strip() for c in line.split('|')]
    cols = [c for c in cols if c]  # remove empty
    if len(cols) < 3:
        continue
    # First col: T{NN} or {NN}
    id_match = re.match(r'^T?(\d+)$', cols[0])
    if not id_match:
        continue
    task_num = int(id_match.group(1))
    # Find status emoji in any column
    status = 'unknown'
    for col in cols:
        if '✅' in col:
            status = 'done'
            break
        elif '⏳' in col:
            status = 'pending'
            break
        elif '❌' in col:
            status = 'blocked'
            break
    status_map[task_num] = status

for k, v in sorted(status_map.items()):
    print(f'T{k:02d}:{v}')
" "$STATUS_FILE" 2>/dev/null) || STATUS_DATA=""

STATUS_TASK_COUNT=0
if [ -n "$STATUS_DATA" ]; then
  STATUS_TASK_COUNT=$(echo "$STATUS_DATA" | wc -l | tr -d ' ')
fi
echo -e "STATUS tasks: ${STATUS_TASK_COUNT}"

# ─── E3 + E4: Task completion check ─────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Task Completion (${PLAN_TASK_COUNT} tasks in PLAN)${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

TASKS_DONE=0
TASKS_PENDING=0
TASKS_MISSING=0

if [ -z "$PLAN_TASKS" ]; then
  echo -e "${YELLOW}  ⚠  No tasks found in PLAN.md (check **T{NN}** or | T{NN} | table format)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  while IFS=: read -r task_id task_desc; do
    [ -z "$task_id" ] && continue
    # Get numeric ID: T08 → 8
    task_num=$(echo "$task_id" | sed 's/T0*\([0-9][0-9]*\)/\1/')
    task_num_padded=$(printf 'T%02d' "$task_num")

    # Find in STATUS_DATA
    task_status=$(echo "$STATUS_DATA" | grep -E "^${task_num_padded}:" | head -1 | cut -d: -f2 || true)

    if [ -z "$task_status" ]; then
      echo -e "  ${RED}❌ ${task_id} — MISSING from STATUS.md${NC}"
      TASKS_MISSING=$((TASKS_MISSING + 1))
      BLOCKS=$((BLOCKS + 1))
    elif [ "$task_status" = "done" ]; then
      echo -e "  ${GREEN}✅ ${task_id}${NC}" "${task_desc:+— $task_desc}"
      TASKS_DONE=$((TASKS_DONE + 1))
    elif [ "$task_status" = "pending" ]; then
      echo -e "  ${YELLOW}⏳ ${task_id} — PENDING (not completed)${NC}"
      TASKS_PENDING=$((TASKS_PENDING + 1))
      BLOCKS=$((BLOCKS + 1))
    elif [ "$task_status" = "blocked" ]; then
      echo -e "  ${RED}❌ ${task_id} — BLOCKED${NC}"
      TASKS_PENDING=$((TASKS_PENDING + 1))
      BLOCKS=$((BLOCKS + 1))
    fi
  done <<< "$PLAN_TASKS"

  echo ""
  INCOMPLETE=$((TASKS_PENDING + TASKS_MISSING))
  if [ "$INCOMPLETE" -eq 0 ]; then
    echo -e "  ${GREEN}${TASKS_DONE}/${PLAN_TASK_COUNT} tasks completed ✅${NC}"
  else
    echo -e "  ${RED}${TASKS_DONE}/${PLAN_TASK_COUNT} completed — ${INCOMPLETE} INCOMPLETE${NC}"
  fi
fi

# ─── E5: Expected artifact existence ────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Artifact Existence${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

EXPECTED_FILES=$(python3 -c "
import re, sys

text = open(sys.argv[1]).read()

# Find file tree section (Repository Structure / Estrutura Final)
tree_match = re.search(
    r'(?:Repository Structure|Estrutura Final|File Structure|Structure)[^\n]*\n[^\n]*\n?\x60{3}[^\n]*\n(.*?)\x60{3}',
    text, re.DOTALL | re.IGNORECASE
)
if not tree_match:
    sys.exit()

tree = tree_match.group(1)

# Extract filenames from tree lines: ├──, └──, │   etc.
# Match: optional whitespace + box-drawing chars + space + filename
files = []
for line in tree.splitlines():
    m = re.search(r'[├└│]?[─\s]*──\s+(\S+)', line)
    if not m:
        # fallback: line ending with filename.ext after spaces
        m = re.search(r'^\s*(\S+\.\w+)\s*(?:#.*)?$', line)
    if m:
        name = m.group(1).rstrip('/')
        # Skip dirs (no extension) and comments
        if '.' in name and not name.startswith('#'):
            files.append(name)

for f in files:
    print(f)
" "$PLAN_FILE" 2>/dev/null) || EXPECTED_FILES=""

if [ -z "$EXPECTED_FILES" ]; then
  echo -e "${YELLOW}  ⚠  No file tree found in PLAN.md — skipping artifact check${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  FILE_COUNT=$(echo "$EXPECTED_FILES" | wc -l | tr -d ' ')
  FILES_FOUND=0
  FILES_MISSING=0

  while IFS= read -r fname; do
    [ -z "$fname" ] && continue
    # Search in workspace
    if find "$WORKSPACE_DIR" -name "$fname" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
      echo -e "  ${GREEN}✅${NC} \`${fname}\`"
      FILES_FOUND=$((FILES_FOUND + 1))
    else
      echo -e "  ${RED}❌${NC} \`${fname}\` — NOT FOUND on disk"
      FILES_MISSING=$((FILES_MISSING + 1))
      BLOCKS=$((BLOCKS + 1))
    fi
  done <<< "$EXPECTED_FILES"

  echo ""
  if [ "$FILES_MISSING" -eq 0 ]; then
    echo -e "  ${GREEN}${FILES_FOUND}/${FILE_COUNT} artifacts present ✅${NC}"
  else
    echo -e "  ${RED}${FILES_FOUND}/${FILE_COUNT} present — ${FILES_MISSING} MISSING${NC}"
  fi
fi

# ─── E6: Placeholder residuals ──────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Placeholder Residuals${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

# Collect file list first, then run Python3 scanner.
# Python3 scanner skips: lines inside fenced code blocks (```/~~~),
# inline code spans (`...`), and the validator scripts themselves.
PLACEHOLDER_FILELIST=$(find "$WORKSPACE_DIR" \
  -type f \
  ! -path "*/.git/*" \
  ! -path "*/templates/*" \
  ! -path "*/brainstorm/*" \
  ! -path "*/vendor/*" \
  ! -path "*/node_modules/*" \
  ! -path "*/.github/*" \
  ! -name "validate-plan.sh" \
  ! -name "validate-execution.sh" \
  \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.txt" \) 2>/dev/null | sort)

PLACEHOLDER_RAW=$(echo "$PLACEHOLDER_FILELIST" | python3 -c '
import sys, os, re

patterns = [
    r"\[SUBSTITUIR\b", r"\[REPLACE\b", r"\[TODO\b",
    r"\[YYYY-MM-DD\]", r"\[XX\]", r"\[Phase Name\]",
    r"\[Your Project\]", r"\[PLACEHOLDER\b",
    r"\{\{PROJECT_NAME\}\}", r"\{\{PROJECT_DESCRIPTION\}\}",
    r"\{\{PHASE_NAME\}\}", r"\{\{PHASE_NUMBER\}\}",
]
PAT = re.compile("|".join(patterns))

files = sys.stdin.read().splitlines()
for filepath in files:
    if not filepath or not os.path.isfile(filepath):
        continue
    try:
        with open(filepath, encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
    except Exception:
        continue
    in_fence = False
    real_matches = []
    for lineno, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        # Strip inline code spans before checking
        clean = re.sub(r"`[^`\n]+`", "", line)
        if PAT.search(clean):
            real_matches.append((lineno, line.rstrip()))
    if real_matches:
        print("FILE:" + filepath)
        for lineno, text in real_matches[:3]:
            print("LINE:" + str(lineno) + ":" + text)
')

if [ -z "$PLACEHOLDER_RAW" ]; then
  echo -e "  ${GREEN}✅ No placeholders found in delivered files${NC}"
else
  echo -e "  ${RED}❌ Placeholder residuals found:${NC}"
  PLACEHOLDER_FILE_COUNT=0
  while IFS= read -r entry; do
    if [[ "$entry" == FILE:* ]]; then
      CURRENT_FILE="${entry#FILE:}"
      PLACEHOLDER_FILE_COUNT=$((PLACEHOLDER_FILE_COUNT + 1))
      echo -e "     ${CURRENT_FILE#$WORKSPACE_DIR/}"
    elif [[ "$entry" == LINE:* ]]; then
      REST="${entry#LINE:}"
      LINENO="${REST%%:*}"
      TEXT="${REST#*:}"
      echo -e "       ${YELLOW}${LINENO}:${TEXT}${NC}"
    fi
  done <<< "$PLACEHOLDER_RAW"
  BLOCKS=$((BLOCKS + PLACEHOLDER_FILE_COUNT))
fi

# ─── E7: CHANGELOG.md — at least one entry after execution ─────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} CHANGELOG.md Update${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

CHANGELOG_FILE="$WORKSPACE_DIR/.github/tao/CHANGELOG.md"
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo -e "  ${RED}❌ CHANGELOG.md missing — execution is undocumented${NC}"
  BLOCKS=$((BLOCKS + 1))
else
  _CLOG_ENTRIES=$(grep -cE '^### |^## \[' "$CHANGELOG_FILE" 2>/dev/null || true)
  _CLOG_ENTRIES=${_CLOG_ENTRIES:-0}
  _CLOG_DATED=$(grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$CHANGELOG_FILE" 2>/dev/null || true)
  _CLOG_DATED=${_CLOG_DATED:-0}
  if [ "$_CLOG_DATED" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠  CHANGELOG.md has no dated entries — add at least one entry after execution${NC}"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "  ${GREEN}✅ CHANGELOG.md has ${_CLOG_DATED} dated entries${NC}"
  fi
fi

# ─── E8: Shell script syntax validation (WARNING) ───────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
echo -e "${BOLD} Shell Script Syntax${NC}"
echo -e "${BOLD}────────────────────────────────────────────${NC}"

SH_FILES=$(find "$WORKSPACE_DIR" \
  -type f \
  -name "*.sh" \
  ! -path "*/.git/*" \
  ! -path "*/templates/*" \
  ! -path "*/vendor/*" \
  ! -path "*/node_modules/*" 2>/dev/null || true)

if [ -z "$SH_FILES" ]; then
  echo -e "  ${YELLOW}⚠  No .sh files found${NC}"
else
  SH_OK=0
  SH_ERR=0
  while IFS= read -r shfile; do
    [ -z "$shfile" ] && continue
    if bash -n "$shfile" 2>/dev/null; then
      echo -e "  ${GREEN}✅${NC} ${shfile#$WORKSPACE_DIR/}"
      SH_OK=$((SH_OK + 1))
    else
      ERR_MSG=$(bash -n "$shfile" 2>&1 || true)
      echo -e "  ${YELLOW}⚠  ${shfile#$WORKSPACE_DIR/} — syntax issue${NC}"
      echo -e "     ${YELLOW}${ERR_MSG}${NC}"
      SH_ERR=$((SH_ERR + 1))
      WARNINGS=$((WARNINGS + 1))
    fi
  done <<< "$SH_FILES"

  SH_TOTAL=$((SH_OK + SH_ERR))
  echo ""
  if [ "$SH_ERR" -eq 0 ]; then
    echo -e "  ${GREEN}${SH_OK}/${SH_TOTAL} scripts valid ✅${NC}"
  else
    echo -e "  ${YELLOW}${SH_OK}/${SH_TOTAL} valid — ${SH_ERR} warning(s)${NC}"
  fi
fi

# ─── Final result ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"

if [ "$BLOCKS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS — Execution matches plan${NC}"
elif [ "$BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} Result: ✅ PASS${NC} ${YELLOW}(${WARNINGS} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} Result: 🚫 BLOCK — ${BLOCKS} issue(s) found${NC}"
  echo ""
  echo -e "${YELLOW}  Fix all BLOCK items before declaring the phase complete.${NC}"
fi

echo -e "${BOLD}════════════════════════════════════════════${NC}"
echo ""

if [ "$BLOCKS" -gt 0 ]; then
  exit 1
fi
exit 0
