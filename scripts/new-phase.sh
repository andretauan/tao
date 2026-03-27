#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# new-phase.sh — Create a new phase directory with templates
# ═══════════════════════════════════════════════════════════════
# Reads tao.config.json for language, paths, and phase_prefix.
# Copies correct language templates into the new phase directory.
# Usage: ./new-phase.sh <phase-number> <phase-name>
# Example: ./new-phase.sh 03 "Authentication System"

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"
CONFIG_FILE="$WORKSPACE_DIR/tao.config.json"

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ── Validate args ──
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <phase-number> <phase-name>"
  echo "Example: $0 03 \"Authentication System\""
  exit 1
fi

PHASE_NUM="$1"
PHASE_NAME="$2"

# ── Validate config ──
if [ ! -f "$CONFIG_FILE" ]; then
  echo -e "${RED}ERROR: tao.config.json not found at $CONFIG_FILE${NC}"
  echo "Run install.sh first to generate your config."
  exit 1
fi

# ── Read config via python3 (single call, no eval) ──
_cfg=$(python3 -c "
import json, sys
try:
    c = json.load(open(sys.argv[1]))
    print(c.get('project',{}).get('language','en'))
    print(c.get('paths',{}).get('phases','docs/phases/'))
    print(c.get('paths',{}).get('phase_prefix','phase-'))
    print(c.get('project',{}).get('name','Project'))
except:
    print('en')
    print('docs/phases/')
    print('phase-')
    print('Project')
" "$CONFIG_FILE" 2>/dev/null) || _cfg=""
if [ -n "$_cfg" ]; then
  LANG=$(echo "$_cfg" | sed -n '1p')
  PHASES_DIR=$(echo "$_cfg" | sed -n '2p')
  PHASES_DIR="${PHASES_DIR%/}"
  PHASE_PREFIX=$(echo "$_cfg" | sed -n '3p')
  PROJECT_NAME=$(echo "$_cfg" | sed -n '4p')
else
  LANG="en"
  PHASES_DIR="docs/phases/"
  PHASE_PREFIX="phase-"
  PROJECT_NAME="Project"
fi

# ── Determine TAO install dir (where templates live) ──
# If running from TAO repo itself, templates are local.
# If installed in a project, templates were copied to .github/tao/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAO_DIR="$(dirname "$SCRIPT_DIR")"

# Look for templates in order: .github/tao/phases/, TAO repo phases/
TEMPLATE_DIR=""
if [ -d "$WORKSPACE_DIR/.github/tao/phases/$LANG" ]; then
  TEMPLATE_DIR="$WORKSPACE_DIR/.github/tao/phases/$LANG"
elif [ -d "$WORKSPACE_DIR/.github/tao/phases/en" ]; then
  TEMPLATE_DIR="$WORKSPACE_DIR/.github/tao/phases/en"
elif [ -d "$TAO_DIR/phases/$LANG" ]; then
  TEMPLATE_DIR="$TAO_DIR/phases/$LANG"
elif [ -d "$TAO_DIR/phases/en" ]; then
  TEMPLATE_DIR="$TAO_DIR/phases/en"
fi

BRAINSTORM_TEMPLATE_DIR=""
if [ -d "$WORKSPACE_DIR/.github/tao/phases/shared" ]; then
  BRAINSTORM_TEMPLATE_DIR="$WORKSPACE_DIR/.github/tao/phases/shared"
elif [ -d "$TAO_DIR/phases/shared" ]; then
  BRAINSTORM_TEMPLATE_DIR="$TAO_DIR/phases/shared"
fi

if [ -z "$TEMPLATE_DIR" ]; then
  echo -e "${RED}ERROR: Phase templates not found for language '$LANG'${NC}"
  echo "Searched: .github/tao/phases/$LANG, $TAO_DIR/phases/$LANG"
  exit 1
fi

# ── Build phase directory path ──
PHASE_DIR="$WORKSPACE_DIR/$PHASES_DIR/${PHASE_PREFIX}${PHASE_NUM}"

if [ -d "$PHASE_DIR" ]; then
  echo -e "${YELLOW}WARNING: Phase directory already exists: $PHASE_DIR${NC}"
  echo "Skipping creation to avoid overwriting existing work."
  exit 1
fi

echo -e "${GREEN}Creating phase ${PHASE_PREFIX}${PHASE_NUM}: $PHASE_NAME${NC}"
echo "  Language:  $LANG"
echo "  Templates: $TEMPLATE_DIR"
echo "  Target:    $PHASE_DIR"
echo ""

# ── Create directories ──
mkdir -p "$PHASE_DIR/brainstorm"

# Determine task dir name based on language
TASKS_DIR_NAME="tasks"
if [ "$LANG" = "pt-br" ]; then
  TASKS_DIR_NAME="tarefas"
fi
mkdir -p "$PHASE_DIR/$TASKS_DIR_NAME"

# ── Copy and substitute templates ──
DATE_NOW=$(date '+%Y-%m-%d %H:%M')

# Escape sed special chars in user-provided values (& / \ are special in sed replacements)
SAFE_PHASE_NAME=$(printf '%s' "$PHASE_NAME" | sed 's/[&/\]/\\&/g')
SAFE_PROJECT_NAME=$(printf '%s' "$PROJECT_NAME" | sed 's/[&/\]/\\&/g')

for template in "$TEMPLATE_DIR"/*; do
  if [ -f "$template" ]; then
    filename=$(basename "$template")
    # Remove .template suffix if present
    target_name="${filename%.template}"
    target_file="$PHASE_DIR/$target_name"

    # Substitute placeholders (using | delimiter to avoid / conflicts)
    sed \
      -e "s|{{PHASE_NUMBER}}|$PHASE_NUM|g" \
      -e "s|{{PHASE_NAME}}|$SAFE_PHASE_NAME|g" \
      -e "s|{{PROJECT_NAME}}|$SAFE_PROJECT_NAME|g" \
      -e "s|{{DATE}}|$DATE_NOW|g" \
      "$template" > "$target_file"

    echo -e "  ${GREEN}✓${NC} $target_name"
  fi
done

# ── Copy brainstorm templates ──
if [ -n "$BRAINSTORM_TEMPLATE_DIR" ]; then
  for template in "$BRAINSTORM_TEMPLATE_DIR"/*; do
    if [ -f "$template" ]; then
      filename=$(basename "$template")
      target_name="${filename%.template}"
      target_file="$PHASE_DIR/brainstorm/$target_name"

      sed \
        -e "s|{{PHASE_NUMBER}}|$PHASE_NUM|g" \
        -e "s|{{PHASE_NAME}}|$SAFE_PHASE_NAME|g" \
        -e "s|{{PROJECT_NAME}}|$SAFE_PROJECT_NAME|g" \
        -e "s|{{DATE}}|$DATE_NOW|g" \
        "$template" > "$target_file"

      echo -e "  ${GREEN}✓${NC} brainstorm/$target_name"
    fi
  done
fi

echo ""
echo -e "${GREEN}Phase ${PHASE_PREFIX}${PHASE_NUM} created successfully.${NC}"
echo ""
echo "Next steps:"
echo "  1. Start brainstorm: use @Wu (or @Brainstorm) agent"
echo "  2. Fill brainstorm/BRIEF.md until maturity ≥ 5/7"
echo "  3. Create PLAN.md + STATUS.md from the BRIEF"
echo "  4. Run: tao.sh status"
