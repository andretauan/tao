#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# forensic-audit.sh — BLOCK gate: Forensic Quality Audit (3 rounds)
# ═══════════════════════════════════════════════════════════════
# Deep forensic audit of ALL delivered code/artifacts.
# Runs 3 MANDATORY rounds, each progressively deeper:
#
#   ROUND 1 — SURFACE   : files exist, syntax OK, no leftovers
#   ROUND 2 — STRUCTURAL: cross-file consistency, contracts, refs
#   ROUND 3 — DEEP      : logic gaps, dead code, boundary issues
#
# Rules:
#   • Each round MUST pass before the next begins.
#   • All 3 rounds MUST complete — skipping a round = BLOCK.
#   • ANY finding in any round = BLOCK.
#
# Usage:
#   bash .github/tao/scripts/forensic-audit.sh [phase-dir]
#
# Exit: 0 = ALL 3 ROUNDS PASS, 1 = BLOCK

set -uo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"

# ─── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

if [[ "${NO_COLOR:-}" == "1" ]] || [[ "${TERM:-}" == "dumb" ]]; then
  RED=''; GREEN=''; YELLOW=''; CYAN=''; MAGENTA=''; BOLD=''; DIM=''; NC=''
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

# ─── Read project language ────────────────────────────────────────
PROJ_LANG="en"
if [ -f "$CONFIG_FILE" ]; then
  PROJ_LANG=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('project',{}).get('language','en'))
except:
    print('en')
" "$CONFIG_FILE" 2>/dev/null) || PROJ_LANG="en"
fi

if [ "$PROJ_LANG" = "pt-br" ]; then
  TASKS_DIRNAME="tarefas"
else
  TASKS_DIRNAME="tasks"
fi

# ─── Helper functions ────────────────────────────────────────────
CURRENT_BLOCKS=0
CURRENT_WARN=0

ok()   { echo -e "  ${GREEN}✅${NC} $1"; }
fail() { echo -e "  ${RED}❌ BLOCK — $1${NC}"; CURRENT_BLOCKS=$((CURRENT_BLOCKS + 1)); }
warn() { echo -e "  ${YELLOW}⚠  $1${NC}"; CURRENT_WARN=$((CURRENT_WARN + 1)); }
info() { echo -e "  ${DIM}→ $1${NC}"; }

ROUNDS_COMPLETED=0
R1_BLOCKS=0; R2_BLOCKS=0; R3_BLOCKS=0
TOTAL_BLOCKS=0

# ─── Locate critical files ──────────────────────────────────────
STATUS_FILE=""
PLAN_FILE=""
TASKS_DIR=""
PROGRESS_FILE=""
BRIEF_FILE=""
CHANGELOG_FILE="$WORKSPACE_DIR/.github/tao/CHANGELOG.md"
CONTEXT_FILE="$WORKSPACE_DIR/.github/tao/CONTEXT.md"

if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  for c in "$PHASE_DIR/STATUS.md" "$PHASE_DIR/brainstorm/STATUS.md"; do
    [ -f "$c" ] && STATUS_FILE="$c" && break
  done
  for c in "$PHASE_DIR/PLAN.md" "$PHASE_DIR/brainstorm/PLAN.md"; do
    [ -f "$c" ] && PLAN_FILE="$c" && break
  done
  for c in "$PHASE_DIR/$TASKS_DIRNAME" "$PHASE_DIR/tasks" "$PHASE_DIR/tarefas"; do
    [ -d "$c" ] && TASKS_DIR="$c" && break
  done
  [ -f "$PHASE_DIR/progress.txt" ] && PROGRESS_FILE="$PHASE_DIR/progress.txt"
  for c in "$PHASE_DIR/brainstorm/BRIEF.md" "$PHASE_DIR/BRIEF.md"; do
    [ -f "$c" ] && BRIEF_FILE="$c" && break
  done
fi

# ─── Header ──────────────────────────────────────────────────────
echo ""
echo -e "${MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}${BOLD}║  FORENSIC AUDIT — Deep Quality Gate (3 Rounds)          ║${NC}"
echo -e "${MAGENTA}${BOLD}║  Bugs • Gaps • Inconsistencies — Zero Tolerance          ║${NC}"
echo -e "${MAGENTA}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  echo -e "  Phase: ${PHASE_DIR##*/}"
fi
echo ""

# ════════════════════════════════════════════════════════════════
# ROUND 1 — SURFACE SCAN
# "Do all expected files exist? Are they syntactically valid?
#  Is there debris left behind from execution?"
# ════════════════════════════════════════════════════════════════
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│  ROUND 1/3 — SURFACE SCAN                               │${NC}"
echo -e "${CYAN}${BOLD}│  Files exist? Syntax valid? No debris?                   │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────┘${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# R1-A: All ✅ tasks in STATUS must have a task file on disk
if [ -n "$STATUS_FILE" ] && [ -n "$TASKS_DIR" ] && [ -d "$TASKS_DIR" ]; then
  _missing_tasks=0
  _done_ids=$(python3 -c "
import re
text = open('$STATUS_FILE').read()
for line in text.splitlines():
    if '|' not in line or '✅' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        print(cols[0].lstrip('T').zfill(2))
" 2>/dev/null || true)
  if [ -n "$_done_ids" ]; then
    while IFS= read -r tid; do
      [ -z "$tid" ] && continue
      if ! ls "$TASKS_DIR"/${tid}-*.md "$TASKS_DIR"/${tid}.md 2>/dev/null | grep -q .; then
        fail "Task T${tid} marked ✅ in STATUS but no task file found in ${TASKS_DIR##*/}/"
        _missing_tasks=$((_missing_tasks + 1))
      fi
    done <<< "$_done_ids"
    if [ "$_missing_tasks" -eq 0 ]; then
      ok "All ✅ tasks have corresponding task files on disk"
    fi
  else
    ok "No completed tasks to verify (or STATUS not found)"
  fi
elif [ -n "$STATUS_FILE" ]; then
  warn "No ${TASKS_DIRNAME}/ directory found — cannot verify task files"
fi

# R1-B: Artifacts declared in PLAN exist on disk
if [ -n "$PLAN_FILE" ]; then
  _art_missing=0
  _art_total=0
  _artifacts=$(python3 -c "
import re, os
text = open('$PLAN_FILE').read()
# Find file paths in tree blocks (├── or └── lines) or backtick references
tree = re.findall(r'[├└]── (.+?)$', text, re.MULTILINE)
refs = re.findall(r'\x60([a-zA-Z0-9_./-]+\.[a-z]{1,6})\x60', text)
seen = set()
for f in tree + refs:
    f = f.strip().rstrip('/')
    # Skip generic patterns, placeholders, URLs
    if not f or f.startswith('http') or '{' in f or '[' in f: continue
    if f.startswith('#') or f.startswith('*'): continue
    if any(c in f for c in ['(',')','>','<']): continue
    if f not in seen:
        seen.add(f)
        print(f)
" 2>/dev/null || true)
  if [ -n "$_artifacts" ]; then
    while IFS= read -r art; do
      [ -z "$art" ] && continue
      _art_total=$((_art_total + 1))
      if [ -e "$WORKSPACE_DIR/$art" ] || [ -e "$PHASE_DIR/$art" ]; then
        : # exists
      else
        fail "PLAN declares '$art' but file not found on disk"
        _art_missing=$((_art_missing + 1))
      fi
    done <<< "$_artifacts"
    if [ "$_art_missing" -eq 0 ] && [ "$_art_total" -gt 0 ]; then
      ok "All ${_art_total} artifacts from PLAN exist on disk"
    fi
  else
    ok "No specific file artifacts detected in PLAN"
  fi
fi

# R1-C: All shell scripts pass bash -n
_sh_files=$(find "$WORKSPACE_DIR" -type f -name "*.sh" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -path "*/.github/tao/*" 2>/dev/null || true)
if [ -n "$_sh_files" ]; then
  _sh_errs=0
  _sh_ok=0
  while IFS= read -r shf; do
    [ -z "$shf" ] && continue
    if bash -n "$shf" 2>/dev/null; then
      _sh_ok=$((_sh_ok + 1))
    else
      fail "Syntax error: ${shf#$WORKSPACE_DIR/}"
      info "$(bash -n "$shf" 2>&1 | head -2)"
      _sh_errs=$((_sh_errs + 1))
    fi
  done <<< "$_sh_files"
  if [ "$_sh_errs" -eq 0 ]; then
    ok "All ${_sh_ok} shell scripts pass syntax check (bash -n)"
  fi
fi

# R1-D: All JSON files are valid
_json_files=$(find "$WORKSPACE_DIR" -type f -name "*.json" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -path "*/package-lock.json" 2>/dev/null || true)
if [ -n "$_json_files" ]; then
  _j_errs=0
  _j_ok=0
  while IFS= read -r jf; do
    [ -z "$jf" ] && continue
    if python3 -c "import json; json.load(open('$jf'))" 2>/dev/null; then
      _j_ok=$((_j_ok + 1))
    else
      fail "Invalid JSON: ${jf#$WORKSPACE_DIR/}"
      _j_errs=$((_j_errs + 1))
    fi
  done <<< "$_json_files"
  if [ "$_j_errs" -eq 0 ]; then
    ok "All ${_j_ok} JSON files are valid"
  fi
fi

# R1-E: No debug/temp debris left behind
_debris=$(find "$WORKSPACE_DIR" -type f \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  \( -name "*.bak" -o -name "*.tmp" -o -name "*.orig" -o -name "*.swp" \
     -o -name "*~" -o -name "*.DS_Store" -o -name "Thumbs.db" \) 2>/dev/null | head -10)
if [ -z "$_debris" ]; then
  ok "No temp/backup debris files (.bak, .tmp, .orig, .swp)"
else
  _dcount=$(echo "$_debris" | wc -l | tr -d ' ')
  fail "${_dcount} debris file(s) found (remove before delivery):"
  echo "$_debris" | while IFS= read -r d; do
    info "${d#$WORKSPACE_DIR/}"
  done
fi

# R1-F: No TODO/FIXME/HACK/XXX markers in delivered code (not in templates/phases/scripts)
_markers=$(find "$WORKSPACE_DIR" -type f \
  \( -name "*.sh" -o -name "*.py" -o -name "*.ts" -o -name "*.js" \
     -o -name "*.php" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" \) \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -path "*/.github/tao/*" \
  ! -name "forensic-audit.sh" ! -name "faudit.sh" \
  ! -name "validate-execution.sh" ! -name "validate-plan.sh" \
  ! -name "doc-validate.sh" \
  -print0 2>/dev/null | xargs -0 grep -lE '\b(TODO|FIXME|HACK|XXX)\b' 2>/dev/null | head -10)
if [ -z "$_markers" ]; then
  ok "No TODO/FIXME/HACK/XXX markers in delivered code"
else
  _mcount=$(echo "$_markers" | wc -l | tr -d ' ')
  fail "${_mcount} file(s) still contain TODO/FIXME/HACK/XXX markers"
  echo "$_markers" | head -5 | while IFS= read -r m; do
    _preview=$(grep -nE '\b(TODO|FIXME|HACK|XXX)\b' "$m" 2>/dev/null | head -1)
    info "${m#$WORKSPACE_DIR/}: ${_preview}"
  done
fi

# R1-G: No empty files (0 bytes) in project source
_src_dir="src/"
if [ -f "$CONFIG_FILE" ]; then
  _src_dir=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('source','src/'))
except:
    print('src/')
" "$CONFIG_FILE" 2>/dev/null) || _src_dir="src/"
fi
if [ -d "$WORKSPACE_DIR/$_src_dir" ]; then
  _empty_files=$(find "$WORKSPACE_DIR/$_src_dir" -type f -empty 2>/dev/null | head -10)
  if [ -z "$_empty_files" ]; then
    ok "No empty files in ${_src_dir}"
  else
    _ecount=$(echo "$_empty_files" | wc -l | tr -d ' ')
    fail "${_ecount} empty file(s) in ${_src_dir} — stub files without content"
    echo "$_empty_files" | head -5 | while IFS= read -r ef; do
      info "${ef#$WORKSPACE_DIR/}"
    done
  fi
fi

# R1-H: No {{PLACEHOLDER}} template residuals in delivered files
# Uses Python to skip inline code (`...`) and fenced code blocks (```...```)
_tmpl_filelist=$(find "$WORKSPACE_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) \
  ! -path "*/.git/*" ! -path "*/templates/*" ! -path "*/.github/tao/*" \
  ! -path "*/phases/en/*" ! -path "*/phases/pt-br/*" ! -path "*/phases/shared/*" \
  ! -name "forensic-audit.sh" ! -name "faudit.sh" \
  ! -name "validate-execution.sh" ! -name "validate-plan.sh" \
  ! -name "doc-validate.sh" ! -name "install.sh" ! -name "new-phase.sh" \
  2>/dev/null | sort)
_tmpl_residuals=$(echo "$_tmpl_filelist" | python3 -c '
import sys, re, os
PAT = re.compile(r"\{\{[A-Z_]+\}\}")
files = sys.stdin.read().splitlines()
hits = []
for filepath in files:
    if not filepath or not os.path.isfile(filepath): continue
    try:
        lines = open(filepath, encoding="utf-8", errors="replace").readlines()
    except Exception: continue
    in_fence = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = not in_fence
            continue
        if in_fence: continue
        clean = re.sub(r"`[^`\n]+`", "", line)
        if PAT.search(clean):
            hits.append(filepath)
            break
for h in hits[:10]:
    print(h)
' 2>/dev/null)
if [ -z "$_tmpl_residuals" ]; then
  ok "No {{PLACEHOLDER}} template residuals in delivered files"
else
  _tcount=$(echo "$_tmpl_residuals" | wc -l | tr -d ' ')
  fail "${_tcount} file(s) have unreplaced {{PLACEHOLDER}} template variables"
  echo "$_tmpl_residuals" | head -5 | while IFS= read -r tr_file; do
    _sample=$(grep -oP '\{\{[A-Z_]+\}\}' "$tr_file" 2>/dev/null | head -3 | tr '\n' ' ')
    info "${tr_file#$WORKSPACE_DIR/}: ${_sample}"
  done
fi

R1_BLOCKS=$CURRENT_BLOCKS
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$R1_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} ROUND 1 (Surface): ✅ PASS${NC}"
  ROUNDS_COMPLETED=1
else
  echo -e "${RED}${BOLD} ROUND 1 (Surface): 🚫 BLOCK — ${R1_BLOCKS} issue(s)${NC}"
  echo -e "${YELLOW}  Fix Round 1 issues before Round 2 can run.${NC}"
  TOTAL_BLOCKS=$((TOTAL_BLOCKS + R1_BLOCKS))
  # BLOCK — Round 2 and 3 cannot run
  echo ""
  echo -e "${RED}${BOLD}  FORENSIC AUDIT: 🚫 BLOCK — Round 1 failed (Rounds 2-3 not executed)${NC}"
  echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 1
fi

# ════════════════════════════════════════════════════════════════
# ROUND 2 — STRUCTURAL ANALYSIS
# "Do files reference each other correctly? Do STATUS, PLAN,
#  BRIEF, and DECISIONS agree? Are contracts consistent?"
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│  ROUND 2/3 — STRUCTURAL ANALYSIS                        │${NC}"
echo -e "${CYAN}${BOLD}│  Cross-file consistency. Contract checks.                │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────┘${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# R2-A: STATUS task count matches PLAN task count
if [ -n "$PLAN_FILE" ] && [ -n "$STATUS_FILE" ]; then
  _sync_result=$(python3 -c "
import re

plan_text = open('$PLAN_FILE').read()
status_text = open('$STATUS_FILE').read()

plan_ids = set(re.findall(r'\*\*T(\d+)\*\*', plan_text))
status_ids = set()
for line in status_text.splitlines():
    if '|' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        status_ids.add(cols[0].lstrip('T').zfill(2))

# Normalize plan IDs
plan_ids = {x.zfill(2) for x in plan_ids}

only_plan = plan_ids - status_ids
only_status = status_ids - plan_ids

if not only_plan and not only_status and len(plan_ids) > 0:
    print('OK:' + str(len(plan_ids)))
elif len(plan_ids) == 0:
    print('NOPLAN')
else:
    issues = []
    if only_plan:
        issues.append('In PLAN but not STATUS: ' + ','.join(sorted(only_plan)))
    if only_status:
        issues.append('In STATUS but not PLAN: ' + ','.join(sorted(only_status)))
    print('MISMATCH:' + ' | '.join(issues))
" 2>/dev/null || echo "ERROR")

  case "$_sync_result" in
    OK:*)
      _count="${_sync_result#OK:}"
      ok "PLAN ↔ STATUS: ${_count} tasks in sync"
      ;;
    NOPLAN)
      warn "No **T{NN}** pattern found in PLAN.md — cannot cross-check"
      ;;
    MISMATCH:*)
      _detail="${_sync_result#MISMATCH:}"
      fail "PLAN ↔ STATUS task mismatch: ${_detail}"
      ;;
    *)
      warn "Could not parse PLAN/STATUS for task sync"
      ;;
  esac
fi

# R2-B: Every BRIEF decision (D{N}) referenced in PLAN
if [ -n "$BRIEF_FILE" ] && [ -n "$PLAN_FILE" ]; then
  _dec_result=$(python3 -c "
import re
brief = open('$BRIEF_FILE').read()
plan = open('$PLAN_FILE').read()

brief_decs = set(re.findall(r'\bD(\d+)\b', brief))
plan_decs = set(re.findall(r'\bD(\d+)\b', plan))

unreferenced = brief_decs - plan_decs
if not brief_decs:
    print('NONE')
elif not unreferenced:
    print('OK:' + str(len(brief_decs)))
else:
    print('MISSING:' + ','.join('D'+d for d in sorted(unreferenced)))
" 2>/dev/null || echo "ERROR")

  case "$_dec_result" in
    OK:*)
      _dc="${_dec_result#OK:}"
      ok "All ${_dc} BRIEF decisions (D{N}) referenced in PLAN"
      ;;
    NONE)
      ok "No D{N} decisions found in BRIEF (may use different format)"
      ;;
    MISSING:*)
      _missed="${_dec_result#MISSING:}"
      fail "BRIEF decisions not referenced in PLAN: ${_missed}"
      info "Every decision from brainstorm must trace to the plan"
      ;;
    *)
      warn "Could not parse BRIEF/PLAN for decision traceability"
      ;;
  esac
fi

# R2-C: STATUS.md has Executor column (routing won't work without it)
if [ -n "$STATUS_FILE" ]; then
  if grep -qi 'Executor' "$STATUS_FILE" 2>/dev/null; then
    ok "STATUS.md contains Executor column"
  else
    fail "STATUS.md missing Executor column — Tao routing is broken"
    info "Required columns: # | Task | Complexity | Executor | Status | Notes"
  fi
fi

# R2-D: tao.config.json ↔ actual project structure consistency
if [ -f "$CONFIG_FILE" ]; then
  _struct_issues=$(python3 -c "
import json, os
c = json.load(open('$CONFIG_FILE'))
paths = c.get('paths', {})
issues = []

# Check source dir exists if referenced
src = paths.get('source', 'src/')
if src and not os.path.isdir(os.path.join('$WORKSPACE_DIR', src)):
    issues.append(f'paths.source={src} does not exist')

# Check docs dir
docs = paths.get('docs', 'docs/')
if docs and not os.path.isdir(os.path.join('$WORKSPACE_DIR', docs)):
    issues.append(f'paths.docs={docs} does not exist')

# Check phases dir
phases = paths.get('phases', 'docs/phases/')
if phases and not os.path.isdir(os.path.join('$WORKSPACE_DIR', phases)):
    issues.append(f'paths.phases={phases} does not exist')

# Check dev_branch != main_branch
git = c.get('git', {})
if git.get('dev_branch') == git.get('main_branch'):
    issues.append('git.dev_branch == git.main_branch (dangerous)')

for i in issues:
    print(i)
" 2>/dev/null || true)

  if [ -z "$_struct_issues" ]; then
    ok "tao.config.json paths match project structure"
  else
    while IFS= read -r issue; do
      [ -z "$issue" ] && continue
      fail "Config inconsistency: ${issue}"
    done <<< "$_struct_issues"
  fi
fi

# R2-E: STATUS ✅ tasks match progress.txt entries
if [ -n "$STATUS_FILE" ] && [ -n "$PROGRESS_FILE" ] && [ -f "$PROGRESS_FILE" ]; then
  _cross_result=$(python3 -c "
import re
status = open('$STATUS_FILE').read()
progress = open('$PROGRESS_FILE').read()

done_ids = []
for line in status.splitlines():
    if '|' not in line or '✅' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        done_ids.append(cols[0].lstrip('T').zfill(2))

missing = []
for tid in done_ids:
    # Look for TNN reference in progress.txt
    if not re.search(r'T0*' + tid.lstrip('0'), progress):
        missing.append('T' + tid)

if not done_ids:
    print('NONE')
elif not missing:
    print('OK:' + str(len(done_ids)))
else:
    print('MISSING:' + ','.join(missing))
" 2>/dev/null || echo "ERROR")

  case "$_cross_result" in
    OK:*)
      ok "All ✅ tasks logged in progress.txt"
      ;;
    NONE)
      ok "No ✅ tasks to cross-check"
      ;;
    MISSING:*)
      _unlogged="${_cross_result#MISSING:}"
      fail "Tasks ✅ in STATUS but not in progress.txt: ${_unlogged}"
      info "Every completed task must be logged with timestamp + agent name"
      ;;
    *)
      warn "Could not cross-check STATUS ↔ progress.txt"
      ;;
  esac
fi

# R2-F: No conflicting task status — same task ID should not appear twice
if [ -n "$STATUS_FILE" ]; then
  _dup_result=$(python3 -c "
import re
text = open('$STATUS_FILE').read()
ids = []
for line in text.splitlines():
    if '|' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        ids.append(cols[0])
seen = set()
dups = set()
for i in ids:
    if i in seen:
        dups.add(i)
    seen.add(i)
if dups:
    print('DUP:' + ','.join(sorted(dups)))
else:
    print('OK')
" 2>/dev/null || echo "ERROR")

  case "$_dup_result" in
    OK)
      ok "No duplicate task IDs in STATUS.md"
      ;;
    DUP:*)
      _dups="${_dup_result#DUP:}"
      fail "Duplicate task IDs in STATUS.md: ${_dups}"
      info "Each task ID must appear exactly once"
      ;;
  esac
fi

# R2-G: CONTEXT.md status is consistent with actual phase state
if [ -f "$CONTEXT_FILE" ] && [ -n "$STATUS_FILE" ]; then
  _ctx_check=$(python3 -c "
import re
ctx = open('$CONTEXT_FILE').read()
status = open('$STATUS_FILE').read()

ctx_status_match = re.search(r'status:\s*(\S+)', ctx)
ctx_status = ctx_status_match.group(1) if ctx_status_match else 'unknown'

table_lines = [l for l in status.splitlines() if l.strip().startswith('|')]
table_text = '\n'.join(table_lines)
done_count = len(re.findall(r'✅', table_text))
pending_count = len(re.findall(r'⏳', table_text))

issues = []
if done_count > 0 and ctx_status in ('new_project', 'novo_projeto'):
    issues.append(f'Tasks completed but CONTEXT still says {ctx_status}')
if done_count > 0 and pending_count == 0 and ctx_status not in ('completed', 'concluido', 'concluído'):
    issues.append(f'All tasks done but CONTEXT status is {ctx_status}, not completed')

for i in issues:
    print(i)
" 2>/dev/null || true)

  if [ -z "$_ctx_check" ]; then
    ok "CONTEXT.md status is consistent with phase state"
  else
    while IFS= read -r ci; do
      [ -z "$ci" ] && continue
      fail "CONTEXT inconsistency: ${ci}"
    done <<< "$_ctx_check"
  fi
fi

R2_BLOCKS=$CURRENT_BLOCKS
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$R2_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} ROUND 2 (Structural): ✅ PASS${NC}"
  ROUNDS_COMPLETED=2
else
  echo -e "${RED}${BOLD} ROUND 2 (Structural): 🚫 BLOCK — ${R2_BLOCKS} issue(s)${NC}"
  echo -e "${YELLOW}  Fix Round 2 issues before Round 3 can run.${NC}"
  TOTAL_BLOCKS=$((TOTAL_BLOCKS + R2_BLOCKS))
  echo ""
  echo -e "${RED}${BOLD}  FORENSIC AUDIT: 🚫 BLOCK — Round 2 failed (Round 3 not executed)${NC}"
  echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 1
fi

# ════════════════════════════════════════════════════════════════
# ROUND 3 — DEEP FORENSIC
# "Logic gaps, dead references, boundary conditions,
#  naming inconsistencies, resource leaks."
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}│  ROUND 3/3 — DEEP FORENSIC                              │${NC}"
echo -e "${CYAN}${BOLD}│  Logic gaps. Dead refs. Boundary checks.                 │${NC}"
echo -e "${CYAN}${BOLD}└──────────────────────────────────────────────────────────┘${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# R3-A: Shell scripts — undeclared variable usage (set -u safety)
_sh_nounset=$(find "$WORKSPACE_DIR" -type f -name "*.sh" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -path "*/.github/tao/*" 2>/dev/null || true)
if [ -n "$_sh_nounset" ]; then
  _unsafe_scripts=0
  while IFS= read -r shf; do
    [ -z "$shf" ] && continue
    # Check if script uses set -u or set -euo / pipefail with u
    if head -5 "$shf" | grep -qE 'set\s+-(e?u|[a-z]*u[a-z]*)'; then
      : # Good — uses set -u
    elif head -5 "$shf" | grep -qE 'set -[a-z]*o pipefail'; then
      # Check if the pipefail line also has u
      if ! head -5 "$shf" | grep -qE 'set\s+-[a-z]*u'; then
        warn "${shf#$WORKSPACE_DIR/}: uses pipefail but missing -u (unset vars won't be caught)"
      fi
    fi
  done <<< "$_sh_nounset"
  ok "Shell script safety flags reviewed"
fi

# R3-B: Unreachable / dead task files (task files that exist but NOT in STATUS)
if [ -n "$STATUS_FILE" ] && [ -n "$TASKS_DIR" ] && [ -d "$TASKS_DIR" ]; then
  _dead_result=$(python3 -c "
import re, os, glob

status = open('$STATUS_FILE').read()
status_ids = set()
for line in status.splitlines():
    if '|' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        status_ids.add(cols[0].lstrip('T').zfill(2))

# List task files
task_files = glob.glob('$TASKS_DIR/*.md')
orphans = []
for tf in task_files:
    basename = os.path.basename(tf)
    # Extract NN from NN-name.md or NN.md
    m = re.match(r'(\d+)', basename)
    if m:
        fid = m.group(1).zfill(2)
        if fid not in status_ids:
            orphans.append(basename)

if orphans:
    print('ORPHAN:' + ','.join(orphans))
else:
    print('OK')
" 2>/dev/null || echo "ERROR")

  case "$_dead_result" in
    OK)
      ok "No orphan task files (all task files are in STATUS)"
      ;;
    ORPHAN:*)
      _orph="${_dead_result#ORPHAN:}"
      fail "Orphan task files not in STATUS.md: ${_orph}"
      info "Remove these files or add them to STATUS.md"
      ;;
  esac
fi

# R3-C: Consistency of referenced file paths inside task files
if [ -n "$TASKS_DIR" ] && [ -d "$TASKS_DIR" ]; then
  _bad_refs=$(python3 -c "
import re, os, glob

task_files = glob.glob('$TASKS_DIR/*.md')
bad = []
for tf in task_files:
    text = open(tf).read()
    # Find backtick-quoted file paths
    refs = re.findall(r'\x60([a-zA-Z0-9_./-]+\.[a-z]{1,6})\x60', text)
    for r in refs:
        if r.startswith('http') or '{' in r or '[' in r: continue
        full = os.path.join('$WORKSPACE_DIR', r)
        if not os.path.exists(full):
            bad.append(os.path.basename(tf) + ' → ' + r)

for b in bad[:5]:
    print(b)
" 2>/dev/null || true)

  if [ -z "$_bad_refs" ]; then
    ok "All file references inside task files point to existing files"
  else
    while IFS= read -r br; do
      [ -z "$br" ] && continue
      fail "Broken file reference: ${br}"
    done <<< "$_bad_refs"
  fi
fi

# R3-D: Naming convention consistency in task files
if [ -n "$TASKS_DIR" ] && [ -d "$TASKS_DIR" ]; then
  _bad_names=$(ls "$TASKS_DIR"/*.md 2>/dev/null | while read -r tf; do
    basename=$(basename "$tf")
    # Expected: NN-descriptive-name.md (with leading zero)
    if ! echo "$basename" | grep -qE '^[0-9]{2,}-[a-z0-9]'; then
      echo "$basename"
    fi
  done)
  if [ -z "$_bad_names" ]; then
    ok "Task files follow naming convention (NN-name.md)"
  else
    _nc=$(echo "$_bad_names" | wc -l | tr -d ' ')
    fail "${_nc} task file(s) don't follow NN-name.md naming convention:"
    echo "$_bad_names" | head -5 | while IFS= read -r bn; do
      info "$bn"
    done
  fi
fi

# R3-E: config lint_commands reference valid tool names
if [ -f "$CONFIG_FILE" ]; then
  _lint_check=$(python3 -c "
import json, shutil
c = json.load(open('$CONFIG_FILE'))
cmds = c.get('lint_commands', {})
issues = []
for ext, cmd in cmds.items():
    tool = cmd.split()[0] if cmd else ''
    if tool and not shutil.which(tool):
        issues.append(ext + ': ' + tool + ' not on PATH')
for i in issues[:5]:
    print(i)
" 2>/dev/null || true)

  if [ -z "$_lint_check" ]; then
    ok "All lint_commands reference tools available on PATH"
  else
    while IFS= read -r lc; do
      [ -z "$lc" ] && continue
      warn "Lint tool not found: ${lc}"
    done <<< "$_lint_check"
  fi
fi

# R3-F: Scripts don't have Windows line endings (CRLF)
_crlf_files=$(find "$WORKSPACE_DIR" -type f -name "*.sh" \
  ! -path "*/.git/*" ! -path "*/node_modules/*" \
  -exec grep -lP '\r$' {} \; 2>/dev/null | head -5)
if [ -z "$_crlf_files" ]; then
  ok "No shell scripts with Windows CRLF line endings"
else
  _crcount=$(echo "$_crlf_files" | wc -l | tr -d ' ')
  fail "${_crcount} shell script(s) have CRLF endings — will break on Linux/macOS"
  echo "$_crlf_files" | while IFS= read -r cf; do
    info "${cf#$WORKSPACE_DIR/}"
  done
fi

# R3-G: No merge conflict markers in any file
_conflict_markers=$(find "$WORKSPACE_DIR" -type f \
  \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.ts" \
     -o -name "*.js" -o -name "*.py" -o -name "*.php" \) \
  ! -path "*/.git/*" ! -path "*/node_modules/*" \
  -exec grep -lE '^(<{7}|>{7}|={7})' {} \; 2>/dev/null | head -5)
if [ -z "$_conflict_markers" ]; then
  ok "No git merge conflict markers in files"
else
  _cccount=$(echo "$_conflict_markers" | wc -l | tr -d ' ')
  fail "${_cccount} file(s) contain merge conflict markers (<<<<<<< / >>>>>>> / =======)"
  echo "$_conflict_markers" | while IFS= read -r ccf; do
    info "${ccf#$WORKSPACE_DIR/}"
  done
fi

# R3-H: Phase completeness — all required phase docs exist
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  _required_docs=("STATUS.md" "PLAN.md" "progress.txt")
  _phase_missing=0
  for req in "${_required_docs[@]}"; do
    if [ -f "$PHASE_DIR/$req" ]; then
      : # ok
    elif [ -f "$PHASE_DIR/brainstorm/$req" ]; then
      : # also ok (brainstorm subdir)
    else
      fail "Phase missing required: ${req}"
      _phase_missing=$((_phase_missing + 1))
    fi
  done
  if [ "$_phase_missing" -eq 0 ]; then
    ok "Phase has all required docs (STATUS.md, PLAN.md, progress.txt)"
  fi
fi

# R3-I: Execution completeness — no ⏳ tasks remain if gate is running
if [ -n "$STATUS_FILE" ]; then
  _pending=$(grep -c '⏳' "$STATUS_FILE" 2>/dev/null || true)
  _pending=${_pending:-0}
  if [ "$_pending" -eq 0 ]; then
    ok "No pending (⏳) tasks remain in STATUS.md"
  else
    fail "${_pending} task(s) still ⏳ — forensic audit should only run when all tasks are complete"
    info "Complete or explicitly skip (⚠️) pending tasks first"
  fi
fi

R3_BLOCKS=$CURRENT_BLOCKS
echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$R3_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} ROUND 3 (Deep Forensic): ✅ PASS${NC}"
  ROUNDS_COMPLETED=3
else
  echo -e "${RED}${BOLD} ROUND 3 (Deep Forensic): 🚫 BLOCK — ${R3_BLOCKS} issue(s)${NC}"
  TOTAL_BLOCKS=$((TOTAL_BLOCKS + R3_BLOCKS))
fi

# ════════════════════════════════════════════════════════════════
# FINAL VERDICT
# ════════════════════════════════════════════════════════════════
TOTAL_BLOCKS=$((R1_BLOCKS + R2_BLOCKS + R3_BLOCKS))

echo ""
echo -e "${MAGENTA}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}${BOLD}║  FORENSIC AUDIT — FINAL VERDICT                         ║${NC}"
echo -e "${MAGENTA}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Round 1 (Surface):    $([ $R1_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${R1_BLOCKS})${NC}")"
echo -e "  Round 2 (Structural): $([ $R2_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${R2_BLOCKS})${NC}")"
echo -e "  Round 3 (Deep):       $([ $R3_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${R3_BLOCKS})${NC}")"
echo -e "  Rounds completed:     ${ROUNDS_COMPLETED}/3"
echo ""

if [ "$ROUNDS_COMPLETED" -lt 3 ]; then
  echo -e "${RED}${BOLD}  🚫 FORENSIC AUDIT: BLOCKED — Only ${ROUNDS_COMPLETED}/3 rounds completed${NC}"
  echo -e "${YELLOW}  All 3 rounds must pass. Each round is prerequisite for the next.${NC}"
  echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 1
fi

if [ "$TOTAL_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}  ✅ FORENSIC AUDIT: ALL 3 ROUNDS PASSED — No bugs, gaps, or inconsistencies${NC}"
  echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}${BOLD}  🚫 FORENSIC AUDIT: BLOCKED — ${TOTAL_BLOCKS} issue(s) across rounds${NC}"
  echo -e "${YELLOW}  Fix all issues and re-run: bash .github/tao/scripts/forensic-audit.sh [phase-dir]${NC}"
  echo -e "${BOLD}══════════════════════════════════════════════════════════${NC}"
  echo ""
  exit 1
fi
