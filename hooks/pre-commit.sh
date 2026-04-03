#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# pre-commit.sh — TAO pre-commit pipeline orchestrator
# ═══════════════════════════════════════════════════════════════
# Modular pipeline: reads tao.config.json for lint commands,
# runs syntax check on staged files by extension.
# Enforces: LOCK 2 (branch), LOCK 3 (destructive), LOCK 5 (pause),
#           R4 (timestamp), R6 (context freshness), ABEX (security).
#
# Called by .git/hooks/pre-commit (installed by install-hooks.sh).
# Exit 0 = allow commit, Exit 1 = block commit.

set -e

CONFIG=".github/tao/tao.config.json"
WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
ERRORS=0

# ─── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
# T06 — Helper functions: extract active phase, count tasks, locate scripts
# ═══════════════════════════════════════════════════════════════

# Locate a TAO script by name — checks standard install paths
locate_script() {
  local script_name="$1"
  for candidate in \
    "$WORKSPACE_DIR/.github/tao/scripts/$script_name" \
    "$(dirname "$0")/../../scripts/$script_name" \
    ".github/tao/scripts/$script_name"; do
    if [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  echo ""
  return 1
}

# Get active phase directory from CONTEXT.md + tao.config.json
get_active_phase_dir() {
  local context_file="$WORKSPACE_DIR/.github/tao/CONTEXT.md"
  [ ! -f "$context_file" ] && echo "" && return

  local phases_dir="docs/phases"
  local phase_prefix="phase-"

  if [ -f "$CONFIG" ]; then
    local _cfg
    _cfg=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('paths',{}).get('phases','docs/phases'))
    print(c.get('paths',{}).get('phase_prefix','phase-'))
except:
    print('docs/phases')
    print('phase-')
" "$CONFIG" 2>/dev/null) || _cfg=""
    if [ -n "$_cfg" ]; then
      phases_dir=$(echo "$_cfg" | sed -n '1p')
      phases_dir="${phases_dir%/}"
      phase_prefix=$(echo "$_cfg" | sed -n '2p')
    fi
  fi

  local phase_num
  phase_num=$(grep -oE '(Phase|Fase):?[[:space:]]*[0-9]+' "$context_file" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "")
  if [ -z "$phase_num" ]; then
    phase_num=$(grep -oE "${phase_prefix}[0-9]+" "$context_file" 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo "")
  fi
  [ -z "$phase_num" ] && echo "" && return

  local phase_padded
  phase_padded=$(printf "%02d" "$phase_num" 2>/dev/null || echo "$phase_num")
  local dir="$WORKSPACE_DIR/$phases_dir/${phase_prefix}${phase_padded}"
  [ -d "$dir" ] && echo "$dir" || echo ""
}

# Count tasks in STATUS.md — sets TASKS_PENDING and TASKS_DONE
TASKS_PENDING=0
TASKS_DONE=0
count_tasks() {
  local phase_dir="$1"
  TASKS_PENDING=0
  TASKS_DONE=0
  local status_file="$phase_dir/STATUS.md"
  [ ! -f "$status_file" ] && return
  TASKS_PENDING=$(grep -c '⏳' "$status_file" 2>/dev/null || true)
  TASKS_PENDING=${TASKS_PENDING:-0}
  TASKS_DONE=$(grep -c '✅' "$status_file" 2>/dev/null || true)
  TASKS_DONE=${TASKS_DONE:-0}
}

# ─── LOCK 5: .tao-pause check ────────────────────────────────
if [ -f "$WORKSPACE_DIR/.tao-pause" ] || [ -f ".tao-pause" ]; then
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: .tao-pause existe — todas as operações pausadas (LOCK 5).${NC}"
  echo -e "${YELLOW}  Remova o arquivo .tao-pause para retomar. / Remove .tao-pause to resume.${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ─── Get staged files ────────────────────────────────────────
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

# ─── Read lint commands from config ───────────────────────────
get_lint_command() {
  local ext="$1"
  if [ -f "$CONFIG" ]; then
    python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    cmds = c.get('lint_commands', {})
    print(cmds.get(sys.argv[2], ''))
except:
    print('')
" "$CONFIG" "$ext" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# ─── Lint each staged file ───────────────────────────────────
while IFS= read -r file; do
  [ ! -f "$file" ] && continue

  # Extract extension
  ext=".${file##*.}"

  # Get lint command for this extension
  lint_cmd=$(get_lint_command "$ext")

  if [ -n "$lint_cmd" ]; then
    # T08 — Sanitize file path before shell substitution
    if [[ "$file" =~ [';|&`$(){}\\<>'] ]] || [[ "$file" == *$'\n'* ]] || [[ "$file" == *$'\r'* ]]; then
      echo -e "${YELLOW}⚠  Skipping lint for unsafe filename: ${file}${NC}"
      continue
    fi

    # Replace {file} placeholder with actual file path
    cmd="${lint_cmd//\{file\}/$file}"

    if ! bash -c "$cmd" > /dev/null 2>&1; then
      echo -e "${RED}✗ Lint failed: ${file}${NC}"
      bash -c "$cmd" 2>&1 | head -5
      ERRORS=$((ERRORS + 1))
    else
      echo -e "${GREEN}✓ ${file}${NC}"
    fi
  fi
done <<< "$STAGED_FILES"

# ─── Branch protection (LOCK 2) ──────────────────────────────
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || true)
if [ -n "$CURRENT_BRANCH" ]; then
  MAIN_BRANCH="main"
  if [ -f "$CONFIG" ]; then
    MAIN_BRANCH=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('git',{}).get('main_branch','main'))
except:
    print('main')
" "$CONFIG" 2>/dev/null) || MAIN_BRANCH="main"
  fi

  if [ "$CURRENT_BRANCH" = "$MAIN_BRANCH" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo -e "${RED}✗ BLOCKED: Direct commit to '${CURRENT_BRANCH}' is FORBIDDEN.${NC}"
    echo -e "${YELLOW}  Switch to dev branch: git checkout dev${NC}"
    ERRORS=$((ERRORS + 1))
  fi
fi

# ─── CONTEXT.md freshness check (R6) ─────────────────────────
CONTEXT_FILE=".github/tao/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  if echo "$STAGED_FILES" | grep -qE '\.py$|\.ts$|\.js$|\.php$|\.rb$|\.go$|\.rs$|\.vue$|\.jsx$|\.tsx$'; then
    if ! echo "$STAGED_FILES" | grep -q "$CONTEXT_FILE"; then
      echo -e "${YELLOW}⚠  Code files staged but CONTEXT.md not updated (R6 violation)${NC}"
      echo -e "${YELLOW}   Agent must update .github/tao/CONTEXT.md after every file edit.${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ─── LOCK 3: Destructive pattern scan ────────────────────────
DESTRUCTIVE=$(git diff --cached -U0 2>/dev/null | grep -E '^\+.*(DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE|DELETE\s+FROM\s+\S+\s*;|rm\s+-rf\s+/)' | grep -v '^+++' | head -5 || true)
if [ -n "$DESTRUCTIVE" ]; then
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: Padrão destrutivo no código (LOCK 3):${NC}"
  echo "$DESTRUCTIVE" | head -3
  echo -e "${YELLOW}  Remova comandos destrutivos antes de commitar.${NC}"
  ERRORS=$((ERRORS + 1))
fi

# ─── R4: Timestamp validation for CHANGELOG.md ───────────────
if echo "$STAGED_FILES" | grep -q "CHANGELOG.md"; then
  CHANGELOG_FILE=$(echo "$STAGED_FILES" | grep "CHANGELOG.md" | head -1)
  if [ -f "$CHANGELOG_FILE" ]; then
    LATEST_DATE=$(grep -oE '\[20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}\]' "$CHANGELOG_FILE" 2>/dev/null | head -1 || true)
    if [ -z "$LATEST_DATE" ]; then
      echo -e "${YELLOW}⚠  CHANGELOG.md staged sem timestamp [YYYY-MM-DD HH:MM] (R4)${NC}"
      echo -e "${YELLOW}   / CHANGELOG.md staged without [YYYY-MM-DD HH:MM] timestamp${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# ─── ABEX security scan (L0 enforcement) ─────────────────────
ABEX_ENABLED="true"
if [ -f "$CONFIG" ]; then
  ABEX_ENABLED=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    val = c.get('compliance', {}).get('abex_enabled', True)
    print('true' if val else 'false')
except:
    print('true')
" "$CONFIG" 2>/dev/null) || ABEX_ENABLED="true"
fi

# Locate abex-gate.sh relative to this script or installed location
ABEX_SCRIPT=""
for candidate in \
  "$WORKSPACE_DIR/.github/tao/scripts/abex-gate.sh" \
  "$(dirname "$0")/../../scripts/abex-gate.sh" \
  ".github/tao/scripts/abex-gate.sh"; do
  if [ -x "$candidate" ]; then
    ABEX_SCRIPT="$candidate"
    break
  fi
done

if [ "$ABEX_ENABLED" = "true" ] && [ -n "$ABEX_SCRIPT" ]; then
  while IFS= read -r staged_file; do
    [ ! -f "$staged_file" ] && continue
    case "$staged_file" in
      *.py|*.js|*.ts|*.jsx|*.tsx|*.php|*.rb|*.go|*.rs|*.java|*.c|*.cpp|*.cs)
        if ! bash "$ABEX_SCRIPT" "$staged_file" > /dev/null 2>&1; then
          echo -e "${RED}✗ ABEX: Problema de segurança / Security issue em: ${staged_file}${NC}"
          bash "$ABEX_SCRIPT" "$staged_file" 2>&1 | grep -E '^\[BLOCK\]' | head -3
          ERRORS=$((ERRORS + 1))
        fi
        ;;
    esac
  done <<< "$STAGED_FILES"
fi

# ═══════════════════════════════════════════════════════════════
# PHASE VALIDATION GATES (T01–T05) — L0 deterministic enforcement
# ═══════════════════════════════════════════════════════════════
PHASE_DIR=$(get_active_phase_dir)

if [ -n "$PHASE_DIR" ]; then
  count_tasks "$PHASE_DIR"

  # ─── T01: BRAINSTORM GATE ──────────────────────────────────
  # Blocks commit if BRIEF.md exists but is invalid (before first task completion)
  if [ "$TASKS_DONE" -eq 0 ] && [ -f "$PHASE_DIR/brainstorm/BRIEF.md" ]; then
    VB_SCRIPT=$(locate_script "validate-brainstorm.sh")
    if [ -n "$VB_SCRIPT" ]; then
      if ! bash "$VB_SCRIPT" "$PHASE_DIR" > /dev/null 2>&1; then
        echo -e "${RED}✗ BRAINSTORM GATE: BRIEF.md inválido / invalid BRIEF.md${NC}"
        bash "$VB_SCRIPT" "$PHASE_DIR" 2>&1 | grep -E '^\[BLOCK\]|^\[FAIL\]|MATURITY' | head -5
        echo -e "${YELLOW}  Corrija os artefatos de brainstorm antes de commitar. / Fix brainstorm artifacts before committing.${NC}"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  fi

  # ─── T02: PLAN GATE ────────────────────────────────────────
  # Blocks commit if PLAN.md/STATUS.md exist but are invalid (before first task completion)
  if [ "$TASKS_DONE" -eq 0 ] && [ -f "$PHASE_DIR/STATUS.md" ]; then
    VP_SCRIPT=$(locate_script "validate-plan.sh")
    if [ -n "$VP_SCRIPT" ]; then
      if ! bash "$VP_SCRIPT" "$PHASE_DIR" > /dev/null 2>&1; then
        echo -e "${RED}✗ PLAN GATE: PLAN.md/STATUS.md inválido / invalid plan${NC}"
        bash "$VP_SCRIPT" "$PHASE_DIR" 2>&1 | grep -E '^\[BLOCK\]|^\[FAIL\]' | head -5
        echo -e "${YELLOW}  Corrija o plano antes de commitar. / Fix the plan before committing.${NC}"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  fi

  # ─── T03/T04/T05: PHASE COMPLETION GATES ───────────────────
  # When ALL tasks are ✅ (phase complete), run full validation suite
  if [ "$TASKS_PENDING" -eq 0 ] && [ "$TASKS_DONE" -gt 0 ]; then

    # T03: Execution validation
    VE_SCRIPT=$(locate_script "validate-execution.sh")
    if [ -n "$VE_SCRIPT" ]; then
      if ! bash "$VE_SCRIPT" "$PHASE_DIR" > /dev/null 2>&1; then
        echo -e "${RED}✗ EXECUTION GATE: Validação de execução falhou / Execution validation failed${NC}"
        bash "$VE_SCRIPT" "$PHASE_DIR" 2>&1 | grep -E '^\[BLOCK\]|^\[FAIL\]' | head -5
        ERRORS=$((ERRORS + 1))
      fi
    fi

    # T04: Documentation validation
    DV_SCRIPT=$(locate_script "doc-validate.sh")
    if [ -n "$DV_SCRIPT" ]; then
      if ! bash "$DV_SCRIPT" "$PHASE_DIR" > /dev/null 2>&1; then
        echo -e "${RED}✗ DOC GATE: Documentação incompleta / Incomplete documentation${NC}"
        bash "$DV_SCRIPT" "$PHASE_DIR" 2>&1 | grep -E '^\[BLOCK\]|^\[FAIL\]' | head -5
        ERRORS=$((ERRORS + 1))
      fi
    fi

    # T05: Forensic audit (3-pass)
    FA_SCRIPT=$(locate_script "forensic-audit.sh")
    if [ -n "$FA_SCRIPT" ]; then
      if ! bash "$FA_SCRIPT" "$PHASE_DIR" > /dev/null 2>&1; then
        echo -e "${RED}✗ FORENSIC GATE: Auditoria forense falhou / Forensic audit failed${NC}"
        bash "$FA_SCRIPT" "$PHASE_DIR" 2>&1 | grep -E 'ROUND|FAIL|BLOCK' | head -5
        echo -e "${YELLOW}  Corrija os issues da auditoria forense. / Fix forensic audit issues.${NC}"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  fi
fi

# ─── Result ───────────────────────────────────────────────────
if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo -e "${RED}✗ Pre-commit blocked: ${ERRORS} file(s) with errors.${NC}"
  echo -e "${YELLOW}Fix the errors and try again.${NC}"
  exit 1
fi

exit 0
