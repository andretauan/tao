#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# update-models.sh — Update model declarations in .agent.md files
# ═══════════════════════════════════════════════════════════════
# Reads tao.config.json → models, updates YAML frontmatter in agents.
# Usage: ./update-models.sh [--dry-run]

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/.github/tao/tao.config.json"
AGENTS_DIR="$WORKSPACE_DIR/.github/agents"

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# ── Validate config ──
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}ERROR: tao.config.json not found at $CONFIG_FILE${NC}"
  exit 1
fi

if [ ! -d "$AGENTS_DIR" ]; then
  echo -e "${RED}ERROR: Agents directory not found at $AGENTS_DIR${NC}"
  exit 1
fi

# ── Read models from config (single call, no eval) ──
_models=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    m = c.get('models',{})
    print(m.get('orchestrator',''))
    print(m.get('complex_worker',''))
    print(m.get('free_tier',''))
except:
    print('')
    print('')
    print('')
" "$CONFIG_FILE" 2>/dev/null) || _models=""
if [ -n "$_models" ]; then
  MODEL_ORCHESTRATOR=$(echo "$_models" | sed -n '1p')
  MODEL_COMPLEX=$(echo "$_models" | sed -n '2p')
  MODEL_FREE=$(echo "$_models" | sed -n '3p')
else
  MODEL_ORCHESTRATOR=""
  MODEL_COMPLEX=""
  MODEL_FREE=""
fi

echo "Models from tao.config.json:"
echo "  orchestrator:     $MODEL_ORCHESTRATOR"
echo "  complex_worker:   $MODEL_COMPLEX"
echo "  free_tier:        $MODEL_FREE"
echo ""

# ── Agent → model mapping (by role) ──
# Execute-Tao = orchestrator (multi-model: orchestrator + free)
# Shen, Investigate-Shen, Brainstorm-Wu = complex_worker
# Di, Qi = free_tier

UPDATED=0
SKIPPED=0

update_agent() {
  local file="$1"
  local role="$2"
  local new_model="$3"
  local agent_name
  agent_name=$(basename "$file" .agent.md)

  if [ ! -f "$file" ]; then
    return
  fi

  # Read current model line
  local current_model
  current_model=$(grep -m1 '^model:' "$file" 2>/dev/null || echo "")

  if [ -z "$current_model" ]; then
    echo -e "  ${YELLOW}SKIP${NC} $agent_name — no model: line found"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  if [[ "$role" == "orchestrator" ]]; then
    # Execute-Tao has multi-model: orchestrator + free
    local expected="model:
  - ${new_model}
  - ${MODEL_FREE}"
    # Check if already has multi-model format
    if grep -q "  - ${new_model}" "$file" && grep -q "  - ${MODEL_FREE}" "$file"; then
      echo -e "  ${GREEN}OK${NC}   $agent_name — already up to date"
      return
    fi
  else
    local expected="model: ${new_model}"
    if [[ "$current_model" == "$expected" ]]; then
      echo -e "  ${GREEN}OK${NC}   $agent_name — already up to date"
      return
    fi
  fi

  if $DRY_RUN; then
    echo -e "  ${YELLOW}WOULD UPDATE${NC} $agent_name → $new_model"
  else
    if [[ "$role" == "orchestrator" ]]; then
      # Replace multi-model block (model: + next 2 lines starting with -)
      python3 -c "
import re, sys
filepath, model_orch, model_free = sys.argv[1], sys.argv[2], sys.argv[3]
with open(filepath, 'r') as f:
    content = f.read()
pattern = r'model:.*?(?=\n[a-z]|\n---)'
replacement = 'model:\n  - ' + model_orch + '\n  - ' + model_free
new_content = re.sub(pattern, replacement, content, count=1, flags=re.DOTALL)
with open(filepath, 'w') as f:
    f.write(new_content)
" "$file" "$new_model" "$MODEL_FREE" 2>/dev/null
    else
      # Replace single model line
      python3 -c "
import sys
filepath, new_model = sys.argv[1], sys.argv[2]
with open(filepath, 'r') as f:
    lines = f.readlines()
with open(filepath, 'w') as f:
    for line in lines:
        if line.startswith('model:') and not line.strip().startswith('model:'):
            f.write(line)
        elif line.startswith('model:'):
            f.write('model: ' + new_model + '\n')
        else:
            f.write(line)
" "$file" "$new_model" 2>/dev/null
    fi
    echo -e "  ${GREEN}UPDATED${NC} $agent_name → $new_model"
  fi
  UPDATED=$((UPDATED + 1))
}

echo "Scanning agents in $AGENTS_DIR..."

# Find all .agent.md files
while IFS= read -r agent_file; do
  name=$(basename "$agent_file" .agent.md)
  name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')

  case "$name_lower" in
    execute-tao|executar-tao)
      update_agent "$agent_file" "orchestrator" "$MODEL_ORCHESTRATOR"
      ;;
    shen|investigate-shen|investigar-shen|brainstorm-wu)
      update_agent "$agent_file" "complex" "$MODEL_COMPLEX"
      ;;
    di|qi)
      update_agent "$agent_file" "free" "$MODEL_FREE"
      ;;
    *)
      echo -e "  ${YELLOW}SKIP${NC} $name — unknown role (not in TAO mapping)"
      SKIPPED=$((SKIPPED + 1))
      ;;
  esac
done < <(find "$AGENTS_DIR" -name "*.agent.md" -type f 2>/dev/null | sort)

echo ""
if $DRY_RUN; then
  echo -e "${YELLOW}DRY RUN:${NC} $UPDATED would be updated, $SKIPPED skipped"
else
  echo -e "${GREEN}Done:${NC} $UPDATED updated, $SKIPPED skipped"
fi
