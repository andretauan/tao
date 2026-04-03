#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# faudit.sh — FAUDIT: Quality Audit Gate (3 Mentalities)
# ═══════════════════════════════════════════════════════════════
# Runs 3 mandatory audit passes with different lenses:
#
#   PASS 1 — LEIGO   : usability, clarity, "does it just work?"
#                       (vibe coder, no experience, first time)
#   PASS 2 — COMUM   : consistency, completeness, traceability
#                       (developer with some experience)
#   PASS 3 — HACKER  : security, injection, integrity
#                       (malicious advanced user attacking the system)
#
# Each pass is INDEPENDENT. All 3 must PASS.
# Any BLOCK → exit 1. All PASS → exit 0.
#
# Usage:
#   bash .github/tao/scripts/faudit.sh [phase-dir]
#   bash .github/tao/scripts/faudit.sh docs/phases/phase-01
#
# Exit: 0 = ALL PASS, 1 = BLOCK

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

# Respect NO_COLOR and dumb terminals
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

# ─── Global counters ─────────────────────────────────────────────
P1_BLOCKS=0; P1_WARN=0
P2_BLOCKS=0; P2_WARN=0
P3_BLOCKS=0; P3_WARN=0
TOTAL_BLOCKS=0

ok()   { echo -e "  ${GREEN}✅${NC} $1"; }
fail() { echo -e "  ${RED}❌ BLOCK — $1${NC}"; CURRENT_BLOCKS=$((CURRENT_BLOCKS + 1)); }
warn() { echo -e "  ${YELLOW}⚠  $1${NC}"; CURRENT_WARN=$((CURRENT_WARN + 1)); }
info() { echo -e "  ${DIM}→ $1${NC}"; }

# ════════════════════════════════════════════════════════════════
# PASS 1 — LEIGO
# Mentality: "Sou um vibe coder, nunca vi isso before"
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║  FAUDIT — PASS 1: LEIGO (Vibe Coder)             ║${NC}"
echo -e "${CYAN}${BOLD}║  Mentality: Total beginner. No experience.        ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# P1-A: python3 disponível?
if command -v python3 >/dev/null 2>&1; then
  _pyver=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  ok "python3 available (${_pyver})"
else
  fail "python3 not found on PATH. TAO requires Python 3.8+."
  info "Install: https://python.org/downloads (or use Homebrew/apt)"
fi

# P1-B: git disponível?
if command -v git >/dev/null 2>&1; then
  _gitver=$(git --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
  ok "git available (${_gitver})"
else
  warn "git not found. Commit gates won't work. Install git or ignore if intentional."
fi

# P1-C: tao.config.json existe e é JSON válido?
if [ -f "$CONFIG_FILE" ]; then
  if python3 -c "import json; json.load(open('$CONFIG_FILE'))" 2>/dev/null; then
    ok "tao.config.json exists and is valid JSON"
  else
    fail "tao.config.json exists but is INVALID JSON — agents cannot read config"
    info "Validate with: python3 -c \"import json; json.load(open('tao.config.json'))\""
  fi
else
  fail "tao.config.json not found. Run install.sh first."
  info "Usage: bash ~/TAO/install.sh ."
fi

# P1-D: CLAUDE.md existe na raiz?
if [ -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
  ok "CLAUDE.md exists at project root"
else
  fail "CLAUDE.md missing. Agents have no rules to follow."
  info "Run install.sh to generate."
fi

# P1-E: CONTEXT.md existe?
if [ -f "$WORKSPACE_DIR/.github/tao/CONTEXT.md" ]; then
  ok "CONTEXT.md exists"
else
  fail "CONTEXT.md missing. Agents cannot track state."
fi

# P1-F: Agentes instalados?
AGENTS_DIR="$WORKSPACE_DIR/.github/agents"
if [ -d "$AGENTS_DIR" ] && compgen -G "$AGENTS_DIR/*.agent.md" > /dev/null 2>&1; then
  _agent_count=$(ls "$AGENTS_DIR"/*.agent.md 2>/dev/null | wc -l | tr -d ' ')
  ok "Agents installed: ${_agent_count} .agent.md files in .github/agents/"
else
  fail ".github/agents/ missing or empty. No agents will be available in VS Code."
  info "Run install.sh to copy agents."
fi

# P1-G: Copilot base instructions installed?
# TAO installs tao.instructions.md (non-invasive) and optionally copilot-instructions.md
if [ -f "$WORKSPACE_DIR/.github/instructions/tao.instructions.md" ]; then
  ok ".github/instructions/tao.instructions.md exists"
  if [ -f "$WORKSPACE_DIR/.github/copilot-instructions.md" ]; then
    ok ".github/copilot-instructions.md also present"
  fi
elif [ -f "$WORKSPACE_DIR/.github/copilot-instructions.md" ]; then
  ok ".github/copilot-instructions.md exists (no tao.instructions.md — OK)"
else
  fail "No Copilot instructions found. Missing both .github/instructions/tao.instructions.md and .github/copilot-instructions.md"
  info "Run install.sh to generate."
fi

# P1-H: Scripts de validação existem?
for req_script in validate-plan.sh validate-execution.sh new-phase.sh forensic-audit.sh faudit.sh doc-validate.sh; do
  script_path="$WORKSPACE_DIR/.github/tao/scripts/$req_script"
  if [ -f "$script_path" ]; then
    ok ".github/tao/scripts/${req_script} present"
  else
    fail ".github/tao/scripts/${req_script} MISSING — quality gate unavailable"
  fi
done

# P1-I: Hooks instalados (pre-commit)?
if [ -f "$WORKSPACE_DIR/.git/hooks/pre-commit" ]; then
  ok ".git/hooks/pre-commit installed"
elif [ -d "$WORKSPACE_DIR/.git" ]; then
  warn ".git/hooks/pre-commit not installed. Run: bash scripts/install-hooks.sh"
else
  warn "Not a git repository. Git hooks unavailable (not necessarily an error)."
fi

# P1-J: Phase templates instalados?
if [ -d "$WORKSPACE_DIR/.github/tao/phases" ]; then
  ok "Phase templates installed at .github/tao/phases/"
else
  warn ".github/tao/phases/ not found. new-phase.sh will fall back to TAO repo templates."
fi

P1_BLOCKS=$CURRENT_BLOCKS
P1_WARN=$CURRENT_WARN

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$P1_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} PASS 1 (Leigo): ✅ PASS${NC} ${YELLOW}(${P1_WARN} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} PASS 1 (Leigo): 🚫 BLOCK — ${P1_BLOCKS} issue(s) stop a beginner${NC}"
fi

# ════════════════════════════════════════════════════════════════
# PASS 2 — USUÁRIO COMUM (Common User)
# Mentality: "Conheço o básico. Quero saber se está consistente."
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║  FAUDIT — PASS 2: USUÁRIO COMUM                  ║${NC}"
echo -e "${CYAN}${BOLD}║  Mentality: Some experience. Wants consistency.   ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# P2-A: STATUS.md tem coluna Executor? (crítico para roteamento do Tao)
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  STATUS_FILE=""
  for candidate in "$PHASE_DIR/STATUS.md" "$PHASE_DIR/brainstorm/STATUS.md"; do
    [ -f "$candidate" ] && STATUS_FILE="$candidate" && break
  done
  PLAN_FILE=""
  for candidate in "$PHASE_DIR/PLAN.md" "$PHASE_DIR/brainstorm/PLAN.md"; do
    [ -f "$candidate" ] && PLAN_FILE="$candidate" && break
  done

  if [ -n "$STATUS_FILE" ]; then
    if grep -qi "Executor" "$STATUS_FILE" 2>/dev/null; then
      ok "STATUS.md has Executor column (Tao routing will work)"
    else
      fail "STATUS.md has NO Executor column — Tao ALWAYS routes to Sonnet (no Opus/DBA routing)"
      info "Add 'Executor' column: Sonnet | Architect | DBA"
    fi

    # P2-B: STATUS.md tarefas vs tasks (PT-BR consistency)
    if [ -f "$CONFIG_FILE" ]; then
      _lang=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('project',{}).get('language','en'))
except:
    print('en')
" "$CONFIG_FILE" 2>/dev/null) || _lang="en"

      if [ "$_lang" = "pt-br" ]; then
        if [ -d "$PHASE_DIR/tarefas" ] || compgen -G "$PHASE_DIR/tarefas" > /dev/null 2>&1; then
          ok "PT-BR project: tarefas/ directory present"
        elif [ -d "$PHASE_DIR/tasks" ]; then
          fail "PT-BR project: found tasks/ but expected tarefas/ — agents created wrong dir"
          info "Rename: mv $PHASE_DIR/tasks $PHASE_DIR/tarefas"
        fi
        TASKS_DIR="$PHASE_DIR/tarefas"
      else
        TASKS_DIR="$PHASE_DIR/tasks"
        ok "EN project: tasks/ directory expected"
      fi

      # P2-C: Task files existem para cada tarefa no STATUS?
      if [ -n "$STATUS_FILE" ] && [ -d "$TASKS_DIR" ]; then
        _task_count=$(ls "$TASKS_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
        ok "Task files in ${TASKS_DIR##*/}/: ${_task_count} file(s)"
      elif [ -n "$STATUS_FILE" ]; then
        warn "Task directory (${TASKS_DIR##*/}/) not found or empty"
      fi
    fi

    # P2-D: PLAN e STATUS têm o mesmo número de tasks?
    if [ -n "$PLAN_FILE" ]; then
      _plan_count=$(python3 -c "
import re
text = open('$PLAN_FILE').read()
print(len(set(re.findall(r'\bT(\d+)\b', text))))
" 2>/dev/null || echo "0")
      _status_count=$(python3 -c "
import re
text = open('$STATUS_FILE').read()
ids = set()
for line in text.splitlines():
    if '|' not in line: continue
    cols = [c.strip() for c in line.split('|') if c.strip()]
    if cols and re.match(r'^T?\d+$', cols[0]):
        ids.add(cols[0])
print(len(ids))
" 2>/dev/null || echo "0")
      if [ "$_plan_count" = "$_status_count" ] && [ "$_plan_count" != "0" ]; then
        ok "PLAN tasks (${_plan_count}) == STATUS tasks (${_status_count})"
      elif [ "$_plan_count" = "0" ]; then
        warn "No tasks found in PLAN.md (check **T{NN}** or | T{NN} | table format)"
      else
        fail "Task count mismatch: PLAN has ${_plan_count}, STATUS has ${_status_count}"
        info "Add missing tasks to STATUS.md or remove extra ones"
      fi
    fi
  else
    warn "No STATUS.md found in ${PHASE_DIR##*/} — skipping phase consistency checks"
  fi

  # P2-E: BRIEF maturity ≥ 5/7?
  BRIEF_FILE=""
  for candidate in "$PHASE_DIR/brainstorm/BRIEF.md" "$PHASE_DIR/BRIEF.md"; do
    [ -f "$candidate" ] && BRIEF_FILE="$candidate" && break
  done
  if [ -n "$BRIEF_FILE" ]; then
    _mat=$(python3 -c "
import re
text = open('$BRIEF_FILE').read()
mat = re.search(r'(?:Maturity|Maturidade)[^\n]*\n(.*?)(?=\n---|\n## |\Z)', text, re.DOTALL|re.IGNORECASE)
if mat:
    checked = len(re.findall(r'- \[x\]', mat.group(1), re.IGNORECASE))
    print(checked)
else:
    print(-1)
" 2>/dev/null || echo "-1")
    if [ "$_mat" = "-1" ]; then
      warn "BRIEF.md has no maturity checklist"
    elif [ "$_mat" -ge 5 ]; then
      ok "BRIEF maturity: ${_mat}/7 ✅"
    else
      fail "BRIEF maturity: ${_mat}/7 — below gate (need ≥ 5/7)"
      info "Continue brainstorming until maturity ≥ 5/7"
    fi
  else
    warn "No BRIEF.md found — brainstorm not completed or not required"
  fi

  # P2-F: Brainstorm artifacts substantive? (DISCOVERY + DECISIONS)
  if [ -d "$PHASE_DIR/brainstorm" ]; then
    _disc_file="$PHASE_DIR/brainstorm/DISCOVERY.md"
    _decs_file="$PHASE_DIR/brainstorm/DECISIONS.md"

    if [ ! -f "$_disc_file" ]; then
      fail "DISCOVERY.md missing from brainstorm/ — exploration not persisted"
      info "Wu must save ALL exploration, reasoning chains, and dead ends to DISCOVERY.md"
    else
      _disc_content=$(grep -cvE '^\s*$|^\s*#|^\s*>|^\s*<!--|^\s*---' "$_disc_file" 2>/dev/null || echo "0")
      if [ "$_disc_content" -lt 10 ]; then
        fail "DISCOVERY.md has only ${_disc_content} content lines (minimum: 10)"
        info "Wu must persist complete exploration — not just headers"
      else
        ok "DISCOVERY.md has ${_disc_content} content lines"
      fi
    fi

    if [ ! -f "$_decs_file" ]; then
      fail "DECISIONS.md missing from brainstorm/ — decisions not persisted"
      info "Wu must save IBIS decisions (D1, D2, ...) with positions and arguments"
    else
      _decs_count=$(python3 -c "
import re
text = open('$_decs_file').read()
print(len(set(re.findall(r'\bD(\d+)\b', text))))
" 2>/dev/null || echo "0")
      if [ "$_decs_count" = "0" ]; then
        fail "DECISIONS.md has no D{N} entries — decisions not recorded"
      else
        ok "DECISIONS.md has ${_decs_count} decision(s)"
      fi
    fi
  fi

else
  warn "No phase directory found — skipping phase-specific checks"
fi

# P2-F: CHANGELOG.md existe e tem pelo menos uma entrada com data?
CHANGELOG_FILE="$WORKSPACE_DIR/.github/tao/CHANGELOG.md"
if [ -f "$CHANGELOG_FILE" ]; then
  _date_count=$(grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$CHANGELOG_FILE" 2>/dev/null || true)
  _date_count=${_date_count:-0}
  if [ "$_date_count" -gt 0 ]; then
    ok "CHANGELOG.md has ${_date_count} dated entries"
  else
    warn "CHANGELOG.md exists but has no dated entries yet"
  fi
else
  fail "CHANGELOG.md missing — execution history is untracked"
fi

# P2-G: CONTEXT.md não está em estado padrão vazio?
CONTEXT_FILE="$WORKSPACE_DIR/.github/tao/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  if grep -qE '\[YYYY-MM-DD' "$CONTEXT_FILE" 2>/dev/null; then
    warn "CONTEXT.md still has [YYYY-MM-DD HH:MM] placeholder — not updated by agent"
  else
    ok "CONTEXT.md updated (no date placeholder residual)"
  fi
fi

# P2-H: Sem {{PLACEHOLDER}} residuais nos arquivos entregues
# Uses Python to skip inline code (`...`) and fenced code blocks
_ph_filelist=$(find "$WORKSPACE_DIR" -type f \( -name "*.md" -o -name "*.json" \) \
  ! -path "*/.git/*" ! -path "*/templates/*" ! -path "*/phases/*" \
  ! -path "*/.github/tao/*" ! -path "*/brainstorm/*" \
  2>/dev/null | sort)
_ph_count=$(echo "$_ph_filelist" | python3 -c '
import sys, re, os
PAT = re.compile(r"\{\{[A-Z_]+\}\}")
files = sys.stdin.read().splitlines()
count = 0
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
            count += 1
            break
print(count)
' 2>/dev/null)
_ph_count="${_ph_count:-0}"
if [ "$_ph_count" = "0" ]; then
  ok "No {{PLACEHOLDER}} residuals in delivered files"
else
  fail "{{PLACEHOLDER}} residuals found in ${_ph_count} file(s) — install.sh substitution failed"
  info "Check: grep -rl '{{' . --include='*.md'"
fi

# P2-I: progress.txt tem entradas com timestamp?
PROGRESS_FILE=""
if [ -n "$PHASE_DIR" ] && [ -d "$PHASE_DIR" ]; then
  [ -f "$PHASE_DIR/progress.txt" ] && PROGRESS_FILE="$PHASE_DIR/progress.txt"
fi
if [ -n "$PROGRESS_FILE" ]; then
  _prog_count=$(grep -cE '^\[20[0-9]{2}-' "$PROGRESS_FILE" 2>/dev/null || true)
  _prog_count=${_prog_count:-0}
  if [ "$_prog_count" -gt 0 ]; then
    ok "progress.txt has ${_prog_count} timestamped entries"
  else
    warn "progress.txt exists but has no [YYYY-MM-DD HH:MM] entries — agents not logging"
  fi
else
  warn "progress.txt not found in phase directory"
fi

P2_BLOCKS=$CURRENT_BLOCKS
P2_WARN=$CURRENT_WARN

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$P2_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} PASS 2 (Comum): ✅ PASS${NC} ${YELLOW}(${P2_WARN} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} PASS 2 (Comum): 🚫 BLOCK — ${P2_BLOCKS} consistency issue(s)${NC}"
fi

# ════════════════════════════════════════════════════════════════
# PASS 3 — HACKER (Malicious Advanced User)
# Mentality: "Procuro vetores de ataque e brechas de segurança"
# ════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║  FAUDIT — PASS 3: HACKER (Malicious User)        ║${NC}"
echo -e "${CYAN}${BOLD}║  Mentality: Attacker looking for exploits.        ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
CURRENT_BLOCKS=0; CURRENT_WARN=0

# P3-A: Sem secrets hardcoded nos arquivos do projeto
_secret_hits=$(find "$WORKSPACE_DIR" -type f \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -name "*.example" \
  \( -name "*.json" -o -name "*.md" -o -name "*.sh" -o -name "*.env" \
     -o -name "*.yml" -o -name "*.yaml" \) \
  -exec python3 -c "
import sys, re, os
PAT = re.compile(
    r'(?:password|passwd|api_key|secret|token|private_key|access_key|auth_token)'
    r'\s*[=:]\s*[\"\'']?[A-Za-z0-9+/]{8,}',
    re.IGNORECASE
)
for f in sys.argv[1:]:
    if not os.path.isfile(f): continue
    try:
        for i, line in enumerate(open(f, errors='replace'), 1):
            # Skip if it's just a placeholder or example
            if re.search(r'ENV|environ|os\.getenv|\\\$\{|your_|my_|placeholder|changeme|example', line, re.IGNORECASE):
                continue
            if PAT.search(line):
                print(f+':'+str(i)+':'+line.rstrip()[:80])
    except: pass
" {} + 2>/dev/null | head -5)

if [ -z "$_secret_hits" ]; then
  ok "No hardcoded secrets detected"
else
  fail "Potential hardcoded secrets found:"
  echo "$_secret_hits" | while IFS= read -r line; do
    echo -e "     ${RED}$line${NC}"
  done
fi

# P3-B: Nenhum eval/exec em scripts shell
_eval_hits=$(find "$WORKSPACE_DIR/scripts" "$WORKSPACE_DIR/hooks" -name "*.sh" ! -name "faudit.sh" -type f 2>/dev/null | \
  xargs grep -n '\beval\b' 2>/dev/null | grep -v ':[[:space:]]*#' || true)
if [ -z "$_eval_hits" ]; then
  ok "No eval in shell scripts"
else
  fail "eval found in shell scripts — potential command injection:"
  echo "$_eval_hits" | head -3 | while IFS= read -r line; do
    echo -e "     ${RED}$line${NC}"
  done
fi

# P3-C: Nenhum rm -rf sem salvaguarda
_rm_hits=$(find "$WORKSPACE_DIR/scripts" "$WORKSPACE_DIR/hooks" -name "*.sh" ! -name "faudit.sh" -type f 2>/dev/null | \
  xargs grep -n 'rm -rf' 2>/dev/null | grep -v ':[[:space:]]*#' || true)
if [ -z "$_rm_hits" ]; then
  ok "No unguarded rm -rf in scripts"
else
  warn "rm -rf found in scripts — verify it's guarded:"
  echo "$_rm_hits" | head -3 | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

# P3-D: auto_push não empurra para main
if [ -f "$CONFIG_FILE" ]; then
  _auto_push=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG_FILE'))
    print(str(c.get('git',{}).get('auto_push', False)).lower())
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
  _main_branch=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c.get('git',{}).get('main_branch','main'))
except:
    print('main')
" 2>/dev/null || echo "main")
  _dev_branch=$(python3 -c "
import json
try:
    c = json.load(open('$CONFIG_FILE'))
    print(c.get('git',{}).get('dev_branch','dev'))
except:
    print('dev')
" 2>/dev/null || echo "dev")

  if [ "$_auto_push" = "true" ] && [ "$_dev_branch" = "$_main_branch" ]; then
    fail "auto_push=true AND dev_branch==main_branch — agents will auto-push to main"
    info "Set dev_branch to 'dev' or set auto_push to false"
  elif [ "$_auto_push" = "true" ]; then
    warn "auto_push=true — every commit pushes to ${_dev_branch} automatically (intentional?)"
  else
    ok "auto_push=false — no automatic push to remote"
  fi
fi

# P3-E: Nenhum --no-verify em scripts
_noverify=$(find "$WORKSPACE_DIR/scripts" "$WORKSPACE_DIR/hooks" -name "*.sh" ! -name "faudit.sh" -type f 2>/dev/null | \
  xargs grep -n '\-\-no-verify' 2>/dev/null | grep -v ':[[:space:]]*#' || true)
if [ -z "$_noverify" ]; then
  ok "No --no-verify in scripts"
else
  fail "--no-verify found in scripts — quality gates can be bypassed:"
  echo "$_noverify" | head -3 | while IFS= read -r line; do
    echo -e "     ${RED}$line${NC}"
  done
fi

# P3-F: Sem HTTP calls externas em scripts
_http_hits=$(find "$WORKSPACE_DIR/scripts" "$WORKSPACE_DIR/hooks" -name "*.sh" ! -name "faudit.sh" -type f 2>/dev/null | \
  xargs grep -nE '\bcurl\b|\bwget\b' 2>/dev/null | grep -v ':[[:space:]]*#' || true)
if [ -z "$_http_hits" ]; then
  ok "No external HTTP calls (curl/wget) in scripts"
else
  warn "External HTTP calls found in scripts — verify they are intentional:"
  echo "$_http_hits" | head -3 | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

# P3-G: Injeção via FILE_PATH em lint-hook / pre-commit
# Check that bash -c "$cmd" receives properly quoted {file} substitution
_injection_risk=$(find "$WORKSPACE_DIR/scripts" "$WORKSPACE_DIR/hooks" -name "*.sh" ! -name "faudit.sh" -type f 2>/dev/null | \
  xargs grep -n 'bash -c "\$' 2>/dev/null | grep -v ':[[:space:]]*#' || true)
if [ -z "$_injection_risk" ]; then
  ok "No unsafe 'bash -c \"\$cmd\"' with unquoted variable in scripts"
else
  warn "Potential injection: 'bash -c \"\$cmd\"' detected — verify file path is sanitized:"
  echo "$_injection_risk" | head -3 | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

# P3-H: .env nunca commitado
if [ -d "$WORKSPACE_DIR/.git" ]; then
  _env_tracked=$(git -C "$WORKSPACE_DIR" ls-files ".env" 2>/dev/null || true)
  if [ -n "$_env_tracked" ]; then
    fail ".env is tracked by git — will expose secrets on push"
    info "Run: echo '.env' >> .gitignore && git rm --cached .env"
  else
    ok ".env is NOT tracked by git"
  fi
fi

# P3-I: .tao-pause nunca commitado
if [ -d "$WORKSPACE_DIR/.git" ]; then
  _pause_tracked=$(git -C "$WORKSPACE_DIR" ls-files ".tao-pause" 2>/dev/null || true)
  if [ -n "$_pause_tracked" ]; then
    fail ".tao-pause is tracked by git — kill switch would be permanent for all users"
    info "Run: git rm --cached .tao-pause"
  else
    ok ".tao-pause is NOT tracked by git"
  fi
fi

# P3-J: DEBUG=True/true in config or source files
_debug_hits=$(find "$WORKSPACE_DIR" -type f \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -name "faudit.sh" \
  \( -name "*.py" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" \
     -o -name "*.env" -o -name "*.cfg" -o -name "*.ini" -o -name "*.toml" \) \
  -exec grep -lE '^\s*DEBUG\s*[=:]\s*(True|true|1)\b' {} + 2>/dev/null | head -5)
if [ -z "$_debug_hits" ]; then
  ok "No DEBUG=True/true found in config files"
else
  warn "DEBUG=True/true found in config files — verify not intended for production:"
  echo "$_debug_hits" | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

# P3-K: console.log/print of sensitive data patterns
_log_secret=$(find "$WORKSPACE_DIR" -type f \
  ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/vendor/*" \
  ! -path "*/templates/*" ! -name "faudit.sh" \
  \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) \
  -exec grep -lE '(console\.log|print)\s*\(.*\b(password|secret|token|api_key|private_key)\b' {} + 2>/dev/null | head -5)
if [ -z "$_log_secret" ]; then
  ok "No console.log/print of sensitive variable names detected"
else
  warn "Potential sensitive data in log output:"
  echo "$_log_secret" | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

# P3-L: Files with overly permissive permissions (777)
_perm_hits=$(find "$WORKSPACE_DIR" -maxdepth 3 -type f -perm -o+w \
  ! -path "*/.git/*" ! -path "*/node_modules/*" \
  \( -name "*.sh" -o -name "*.env" -o -name "*.key" -o -name "*.pem" \) 2>/dev/null | head -5)
if [ -z "$_perm_hits" ]; then
  ok "No world-writable sensitive files (.sh, .env, .key, .pem)"
else
  warn "World-writable sensitive files found — tighten permissions:"
  echo "$_perm_hits" | while IFS= read -r line; do
    echo -e "     ${YELLOW}$line${NC}"
  done
fi

P3_BLOCKS=$CURRENT_BLOCKS
P3_WARN=$CURRENT_WARN

echo ""
echo -e "${BOLD}────────────────────────────────────────────${NC}"
if [ "$P3_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD} PASS 3 (Hacker): ✅ PASS${NC} ${YELLOW}(${P3_WARN} warning(s))${NC}"
else
  echo -e "${RED}${BOLD} PASS 3 (Hacker): 🚫 BLOCK — ${P3_BLOCKS} security issue(s)${NC}"
fi

# ════════════════════════════════════════════════════════════════
# FINAL VERDICT
# ════════════════════════════════════════════════════════════════
TOTAL_BLOCKS=$((P1_BLOCKS + P2_BLOCKS + P3_BLOCKS))
TOTAL_WARN=$((P1_WARN + P2_WARN + P3_WARN))

echo ""
echo -e "${BOLD}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  FAUDIT — FINAL VERDICT                           ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Pass 1 (Leigo):  $([ $P1_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${P1_BLOCKS})${NC}")"
echo -e "  Pass 2 (Comum):  $([ $P2_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${P2_BLOCKS})${NC}")"
echo -e "  Pass 3 (Hacker): $([ $P3_BLOCKS -eq 0 ] && echo "${GREEN}✅ PASS${NC}" || echo "${RED}🚫 BLOCK (${P3_BLOCKS})${NC}")"
echo ""

if [ "$TOTAL_BLOCKS" -eq 0 ] && [ "$TOTAL_WARN" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}  ✅ FAUDIT: ALL 3 PASSES — APPROVED for delivery${NC}"
elif [ "$TOTAL_BLOCKS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}  ✅ FAUDIT: ALL 3 PASSES${NC} ${YELLOW}(${TOTAL_WARN} warning(s))${NC}"
else
  echo -e "${RED}${BOLD}  🚫 FAUDIT: BLOCKED — ${TOTAL_BLOCKS} issue(s) across ${TOTAL_BLOCKS} pass(es)${NC}"
  echo ""
  echo -e "  ${YELLOW}Fix all BLOCK items before proceeding to documentation validation.${NC}"
  echo -e "  ${YELLOW}Rerun: bash .github/tao/scripts/faudit.sh [phase-dir]${NC}"
fi

echo ""
echo -e "${BOLD}════════════════════════════════════════════════════${NC}"
echo ""

[ "$TOTAL_BLOCKS" -gt 0 ] && exit 1
exit 0
