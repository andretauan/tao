#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# tao.sh — TAO (道) Monitor
# Trace · Align · Operate — AI-native development framework
# ═══════════════════════════════════════════════════════════════
#
# Execution is done by VS Code Copilot Agent Mode (fully autonomous).
# This script is ONLY for MONITORING progress and controlling the loop.
#
# USAGE:
#   ./tao.sh                     → show help
#   ./tao.sh status              → state of all phases
#   ./tao.sh report 01           → detailed report for phase
#   ./tao.sh dry-run 01          → simulate what agents would do
#   ./tao.sh pause               → create kill switch
#   ./tao.sh unpause             → remove kill switch
#
# HOW TO RUN TASKS:
#   Open VS Code Copilot Chat, select @Tao, and say: "execute"
#   The agent does EVERYTHING: reads tasks, implements, tests, commits.
#   Use this script only to monitor or pause.

set -e

# ─── Load Config ──────────────────────────────────────────────
CONFIG_FILE="tao.config.json"

read_config() {
  local key="$1"
  local default="$2"
  if [ -f "$CONFIG_FILE" ]; then
    local val
    val=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG_FILE'))
    keys = '$key'.split('.')
    v = c
    for k in keys:
        v = v[k]
    print(v)
except:
    print('$default')
" 2>/dev/null) || val="$default"
    echo "$val"
  else
    echo "$default"
  fi
}

PHASES_DIR=$(read_config "paths.phases" "docs/phases")
PHASE_PREFIX=$(read_config "paths.phase_prefix" "phase-")
LANG=$(read_config "project.language" "en")
PROJECT_NAME=$(read_config "project.name" "Project")
PAUSE_FILE=".tao-pause"

# ─── Colors ───────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ─── i18n ─────────────────────────────────────────────────────
if [[ "$LANG" == "pt-br" ]]; then
  MSG_TITLE="TAO — Estado das Fases"
  MSG_PAUSED="PAUSADO — .tao-pause detectado. Rode ./tao.sh unpause para continuar."
  MSG_UNPAUSED="DESPAUSADO — .tao-pause removido. Diga 'executar' no Copilot."
  MSG_COMPLETED="concluída"
  MSG_EMPTY="vazia"
  MSG_NO_STATUS="sem STATUS.md"
  MSG_NEXT="próxima"
  MSG_DONE="Concluídas"
  MSG_PENDING="Pendentes"
  MSG_REPORT="Relatório — Fase"
  MSG_DRY_RUN="DRY-RUN — Simulação da Fase"
  MSG_ALL_DONE="todas as tarefas seriam concluídas!"
  MSG_NOT_FOUND="não encontrado"
  MSG_DEFERRED="Itens Adiados"
  MSG_PATTERNS="Codebase Patterns"
  MSG_SKIPPED="pulada"
  MSG_SUMMARY="Resumo"
  MSG_TASKS="Tarefas"
  MSG_TOTAL="Total"
  MSG_OPUS_SKIPPED="Opus puladas"
  MSG_NONE="nenhuma"
  MSG_HELP_MONITOR="Monitoramento"
  MSG_HELP_CONTROL="Controle"
  MSG_HELP_EXEC="Execução (no Copilot Chat)"
  MSG_HELP_STATUS="Estado de todas as fases"
  MSG_HELP_REPORT="Relatório detalhado da fase"
  MSG_HELP_DRY="Simula o que os agentes fariam"
  MSG_HELP_PAUSE="Ativa kill switch (para os agentes)"
  MSG_HELP_UNPAUSE="Remove kill switch"
  MSG_HELP_EXECUTE="Auto-loop: tarefas em loop contínuo"
  MSG_HELP_CONTINUE="Continua de onde parou"
  MSG_HELP_NEXT="Executa 1 tarefa e para"
  MSG_HELP_TASK="Executa tarefa específica"
  MSG_NO_PHASES="Nenhuma fase encontrada"
  MSG_NO_DIR="Pasta não encontrada"
  MSG_DEFERRED_COUNT="itens adiados"
  MSG_HINT="Para executar tarefas: abra o Copilot Chat, selecione @Tao e diga \"executar\""
else
  MSG_TITLE="TAO — Phase Status"
  MSG_PAUSED="PAUSED — .tao-pause detected. Run ./tao.sh unpause to continue."
  MSG_UNPAUSED="UNPAUSED — .tao-pause removed. Say 'execute' in Copilot."
  MSG_COMPLETED="completed"
  MSG_EMPTY="empty"
  MSG_NO_STATUS="no STATUS.md"
  MSG_NEXT="next"
  MSG_DONE="Done"
  MSG_PENDING="Pending"
  MSG_REPORT="Report — Phase"
  MSG_DRY_RUN="DRY-RUN — Phase Simulation"
  MSG_ALL_DONE="all tasks would be completed!"
  MSG_NOT_FOUND="not found"
  MSG_DEFERRED="Deferred Items"
  MSG_PATTERNS="Codebase Patterns"
  MSG_SKIPPED="skipped"
  MSG_SUMMARY="Summary"
  MSG_TASKS="Tasks"
  MSG_TOTAL="Total"
  MSG_OPUS_SKIPPED="Opus skipped"
  MSG_NONE="none"
  MSG_HELP_MONITOR="Monitoring"
  MSG_HELP_CONTROL="Control"
  MSG_HELP_EXEC="Execution (in Copilot Chat)"
  MSG_HELP_STATUS="State of all phases"
  MSG_HELP_REPORT="Detailed phase report"
  MSG_HELP_DRY="Simulate what agents would do"
  MSG_HELP_PAUSE="Activate kill switch (stops agents)"
  MSG_HELP_UNPAUSE="Remove kill switch"
  MSG_HELP_EXECUTE="Auto-loop: continuous task execution"
  MSG_HELP_CONTINUE="Continue where it stopped"
  MSG_HELP_NEXT="Run 1 task and stop"
  MSG_HELP_TASK="Run specific task"
  MSG_NO_PHASES="No phases found"
  MSG_NO_DIR="Directory not found"
  MSG_DEFERRED_COUNT="deferred items"
  MSG_HINT="To run tasks: open Copilot Chat, select @Tao and say \"execute\""
fi

# ─── Helper functions ─────────────────────────────────────────

check_pause() {
  if [ -f "$PAUSE_FILE" ]; then
    echo -e "${RED}⏸  ${MSG_PAUSED}${NC}"
    return 1
  fi
  return 0
}

count_pending() {
  local file="$1"
  local c
  c=$(grep -cE '^\|[[:space:]]*[0-9T]+[[:space:]]*\|.*⏳' "$file" 2>/dev/null) || c=0
  echo "$c"
}

count_done() {
  local file="$1"
  local c
  c=$(grep -cE '^\|[[:space:]]*[0-9T]+[[:space:]]*\|.*✅' "$file" 2>/dev/null) || c=0
  echo "$c"
}

get_next_task() {
  local status_file="$1"
  grep '⏳' "$status_file" 2>/dev/null | grep -oP '^\|\s*T?\K\d+' | head -1
}

# ═══════════════════════════════════════════════════════════════
# COMMAND: pause / unpause
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "pause" ]]; then
  touch "$PAUSE_FILE"
  echo -e "${RED}⏸  ${MSG_PAUSED}${NC}"
  exit 0
fi

if [[ "${1:-}" == "unpause" ]]; then
  rm -f "$PAUSE_FILE"
  echo -e "${GREEN}▶  ${MSG_UNPAUSED}${NC}"
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# COMMAND: status
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "status" ]]; then
  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║     ${MSG_TITLE}                    ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
  echo ""

  if [ ! -d "$PHASES_DIR" ]; then
    echo -e "  ${RED}❌ ${MSG_NO_DIR}: '$PHASES_DIR'${NC}"
    echo ""
    exit 1
  fi

  found_any=0
  for fase_dir in "$PHASES_DIR"/${PHASE_PREFIX}*/; do
    [ ! -d "$fase_dir" ] && continue
    found_any=1
    fase=$(basename "$fase_dir")
    status_file="$fase_dir/STATUS.md"
    if [ -f "$status_file" ]; then
      done_count=$(count_done "$status_file")
      pending=$(count_pending "$status_file")
      total=$((done_count + pending))
      if [ "$pending" -eq 0 ] && [ "$total" -gt 0 ]; then
        echo -e "  ${GREEN}✅ $fase${NC} — ${MSG_COMPLETED} (${done_count} ${MSG_TASKS,,})"
      elif [ "$total" -eq 0 ]; then
        echo -e "  ${DIM}○  $fase${NC} — ${MSG_EMPTY}"
      else
        next_num=$(get_next_task "$status_file")
        next_padded=$(printf "%02d" "$next_num" 2>/dev/null || echo "??")
        echo -e "  ${YELLOW}🔄 $fase${NC} — ${GREEN}${done_count}✅${NC} ${YELLOW}${pending}⏳${NC} | ${MSG_NEXT}: T${next_padded}"
      fi
    else
      echo -e "  ${DIM}○  $fase${NC} — ${MSG_NO_STATUS}"
    fi
  done

  if [ "$found_any" -eq 0 ]; then
    echo -e "  ${DIM}${MSG_NO_PHASES} in $PHASES_DIR${NC}"
  fi

  if [ -f "$PAUSE_FILE" ]; then
    echo ""
    echo -e "  ${RED}⏸  LOOP ${MSG_PAUSED}${NC}"
  fi

  for fase_dir in "$PHASES_DIR"/${PHASE_PREFIX}*/; do
    deferred="$fase_dir/deferred-items.md"
    if [ -f "$deferred" ]; then
      count=$(grep -c '^-' "$deferred" 2>/dev/null || echo 0)
      if [ "$count" -gt 0 ]; then
        echo -e "  ${RED}⚠  $(basename "$fase_dir"): ${count} ${MSG_DEFERRED_COUNT} (deferred-items.md)${NC}"
      fi
    fi
  done
  echo ""
  echo -e "  ${DIM}${MSG_HINT}${NC}"
  echo ""
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# COMMAND: report
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "report" ]]; then
  PHASE="${2:-}"
  if [ -z "$PHASE" ]; then
    echo "Usage: ./tao.sh report 01"
    exit 1
  fi
  PHASE_DIR="$PHASES_DIR/${PHASE_PREFIX}${PHASE}"
  STATUS_FILE="$PHASE_DIR/STATUS.md"
  PROGRESS_FILE="$PHASE_DIR/progress.txt"
  DEFERRED_FILE="$PHASE_DIR/deferred-items.md"

  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║     ${MSG_REPORT} $PHASE                       ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"

  if [ -f "$STATUS_FILE" ]; then
    echo ""
    echo -e "${CYAN}── STATUS ──${NC}"
    done_count=$(count_done "$STATUS_FILE")
    pending=$(count_pending "$STATUS_FILE")
    echo -e "  ${MSG_DONE}: ${GREEN}${done_count}${NC}"
    echo -e "  ${MSG_PENDING}:  ${YELLOW}${pending}${NC}"
    echo ""
    echo -e "${CYAN}── ${MSG_DONE} ──${NC}"
    grep '✅' "$STATUS_FILE" | grep -E '^\|' | sed 's/|/ /g' | awk '{$1=$1};1' | while read -r line; do
      echo -e "  ${GREEN}✅${NC} $line"
    done
    echo ""
    echo -e "${CYAN}── ${MSG_PENDING} ──${NC}"
    grep '⏳' "$STATUS_FILE" | grep -E '^\|' | sed 's/|/ /g' | awk '{$1=$1};1' | while read -r line; do
      echo -e "  ${YELLOW}⏳${NC} $line"
    done
  else
    echo -e "  ${RED}❌ STATUS.md ${MSG_NOT_FOUND}: $STATUS_FILE${NC}"
  fi

  if [ -f "$DEFERRED_FILE" ]; then
    echo ""
    echo -e "${RED}── ${MSG_DEFERRED} ──${NC}"
    cat "$DEFERRED_FILE"
  fi

  if [ -f "$PROGRESS_FILE" ]; then
    echo ""
    echo -e "${CYAN}── ${MSG_PATTERNS} ──${NC}"
    sed -n '/^## Codebase Patterns/,/^---/p' "$PROGRESS_FILE" 2>/dev/null | head -20
  fi
  echo ""
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# COMMAND: dry-run
# ═══════════════════════════════════════════════════════════════
if [[ "${1:-}" == "dry-run" ]]; then
  PHASE="${2:-}"
  if [ -z "$PHASE" ]; then
    echo "Usage: ./tao.sh dry-run 01"
    exit 1
  fi

  PHASE_DIR="$PHASES_DIR/${PHASE_PREFIX}${PHASE}"
  STATUS_FILE="$PHASE_DIR/STATUS.md"

  if [ ! -f "$STATUS_FILE" ]; then
    echo -e "${RED}❌ STATUS.md ${MSG_NOT_FOUND}: $STATUS_FILE${NC}"
    exit 1
  fi

  echo ""
  echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║  ${MSG_DRY_RUN} $PHASE                                       ║${NC}"
  echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""

  TASKS_DONE=0
  TASKS_LIST=""
  OPUS_LIST=""

  while IFS= read -r line; do
    num=$(echo "$line" | grep -oP '^\|\s*T?\K\d+')
    [ -z "$num" ] && continue
    padded=$(printf "%02d" "$num")

    if echo "$line" | grep -qi "opus"; then
      echo -e "  ${RED}⚠  T${padded}${NC} — ${DIM}Opus (${MSG_SKIPPED})${NC}"
      OPUS_LIST="${OPUS_LIST}T${padded} "
    else
      echo -e "  ${GREEN}→  T${padded}${NC} ${DIM}[Sonnet]${NC}"
      TASKS_DONE=$((TASKS_DONE + 1))
      TASKS_LIST="${TASKS_LIST}T${padded} "
    fi
  done < <(grep '⏳' "$STATUS_FILE" | grep -E '^\|')

  echo ""
  echo -e "${CYAN}── ${MSG_SUMMARY} ──${NC}"
  echo -e "  ${MSG_TASKS}:        ${TASKS_LIST:-${MSG_NONE}}"
  echo -e "  ${MSG_TOTAL}:          ${TASKS_DONE}"
  echo -e "  ${MSG_OPUS_SKIPPED}:   ${OPUS_LIST:-${MSG_NONE}}"
  echo ""
  exit 0
fi

# ═══════════════════════════════════════════════════════════════
# DEFAULT: Help
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}TAO (道) — Trace · Align · Operate${NC} ${DIM}(monitor)${NC}"
echo ""
echo -e "${CYAN}${MSG_HELP_MONITOR}:${NC}"
echo "  ./tao.sh status              ${MSG_HELP_STATUS}"
echo "  ./tao.sh report 01           ${MSG_HELP_REPORT}"
echo "  ./tao.sh dry-run 01          ${MSG_HELP_DRY}"
echo ""
echo -e "${CYAN}${MSG_HELP_CONTROL}:${NC}"
echo "  ./tao.sh pause               ${MSG_HELP_PAUSE}"
echo "  ./tao.sh unpause             ${MSG_HELP_UNPAUSE}"
echo ""
echo -e "${CYAN}${MSG_HELP_EXEC}:${NC}"
echo -e "  ${GREEN}\"execute\"${NC}                    ${MSG_HELP_EXECUTE}"
echo -e "  ${GREEN}\"continue\"${NC}                   ${MSG_HELP_CONTINUE}"
echo -e "  ${GREEN}\"next task\"${NC}                  ${MSG_HELP_NEXT}"
echo -e "  ${GREEN}\"task 05\"${NC}                    ${MSG_HELP_TASK}"
echo ""
