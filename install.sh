#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# install.sh — TAO (道) Interactive Installer
# Trace · Align · Operate — AI-native development framework
# ═══════════════════════════════════════════════════════════════
#
# Usage: bash /path/to/TAO/install.sh [target_dir]
#   target_dir: project directory to install into (default: current directory)
#
# The script is run FROM the TAO repo directory, targeting a user's project.

set -e

# ─── Resolve paths ────────────────────────────────────────────
TAO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "${1:-.}" 2>/dev/null && pwd)" || {
  echo "Error: target directory '${1}' does not exist."
  exit 1
}

# ─── Colors ───────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Counters ─────────────────────────────────────────────────
INSTALLED=()
SKIPPED=()
STEP=0

step() {
  STEP=$((STEP + 1))
  echo ""
  echo -e "  ${BLUE}[$STEP]${NC} ${BOLD}$1${NC}"
}

installed() {
  echo -e "    ${GREEN}✅${NC} $1"
  INSTALLED+=("$1")
}

skipped() {
  echo -e "    ${YELLOW}⤳${NC}  $1 (already exists — skipped)"
  SKIPPED+=("$1")
}

warn() {
  echo -e "    ${YELLOW}⚠${NC}  $1"
}

# Copy file only if target does not exist (no-overwrite rule)
safe_copy() {
  local src="$1"
  local dst="$2"
  local label="${3:-$(basename "$dst")}"

  if [ ! -f "$src" ]; then
    warn "$label — source not found in TAO (populate templates first)"
    return 1
  fi

  mkdir -p "$(dirname "$dst")"

  if [ -f "$dst" ]; then
    skipped "$label"
    return 1
  fi

  cp "$src" "$dst"
  installed "$label"
  return 0
}

# Copy file and make executable
safe_copy_exec() {
  if safe_copy "$@"; then
    chmod +x "$2"
  fi
}

# ─── Banner ───────────────────────────────────────────────────
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ${BOLD}TAO (道)${NC}${BLUE} — Trace · Align · Operate                  ║${NC}"
echo -e "${BLUE}║   Interactive Installer                               ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Installing into: ${BOLD}$TARGET_DIR${NC}"
echo -e "  TAO source:      ${BOLD}$TAO_DIR${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1 — Interactive Questions
# ═══════════════════════════════════════════════════════════════
step "Configuration"

DEFAULT_NAME="$(basename "$TARGET_DIR")"

# Q1: Language
echo ""
echo -e "    ${BOLD}Language${NC} — template language for docs and agents"
echo -e "    Options: ${GREEN}en${NC} (English) | ${GREEN}pt-br${NC} (Português)"
read -r -p "    Language [en]: " INPUT_LANG
LANG_CHOICE="${INPUT_LANG:-en}"
if [[ "$LANG_CHOICE" != "en" && "$LANG_CHOICE" != "pt-br" ]]; then
  echo -e "    ${RED}Invalid choice. Using 'en'.${NC}"
  LANG_CHOICE="en"
fi
echo -e "    → ${GREEN}$LANG_CHOICE${NC}"

# Q2: Project name
echo ""
read -r -p "    Project name [$DEFAULT_NAME]: " INPUT_NAME
PROJECT_NAME="${INPUT_NAME:-$DEFAULT_NAME}"
echo -e "    → ${GREEN}$PROJECT_NAME${NC}"

# Q3: Description
echo ""
read -r -p "    Project description [My project]: " INPUT_DESC
PROJECT_DESC="${INPUT_DESC:-My project}"
echo -e "    → ${GREEN}$PROJECT_DESC${NC}"

# Q4: Dev branch
echo ""
read -r -p "    Dev branch name [dev]: " INPUT_BRANCH
DEV_BRANCH="${INPUT_BRANCH:-dev}"
echo -e "    → ${GREEN}$DEV_BRANCH${NC}"

# Q5: Lint stack
echo ""
echo -e "    ${BOLD}Primary stack for lint${NC} — file extension to enable in pre-commit hook"
echo -e "    Options: ${GREEN}.php${NC} | ${GREEN}.py${NC} | ${GREEN}.ts${NC} | ${GREEN}.js${NC} | ${GREEN}.rb${NC} | ${GREEN}.go${NC} | ${GREEN}.rs${NC} | ${GREEN}none${NC}"
read -r -p "    Primary stack [none]: " INPUT_LINT
LINT_STACK="${INPUT_LINT:-none}"
echo -e "    → ${GREEN}$LINT_STACK${NC}"

# ═══════════════════════════════════════════════════════════════
# STEP 2 — Generate tao.config.json
# ═══════════════════════════════════════════════════════════════
step "Generating tao.config.json"

CONFIG_FILE="$TARGET_DIR/tao.config.json"

if [ -f "$CONFIG_FILE" ]; then
  skipped "tao.config.json"
else
  # Build lint_commands based on user selection
  LINT_COMMANDS=""
  if [ "$LINT_STACK" != "none" ]; then
    case "$LINT_STACK" in
      .php) LINT_COMMANDS="\"$LINT_STACK\": \"php -l {file}\"" ;;
      .py)  LINT_COMMANDS="\"$LINT_STACK\": \"python3 -m py_compile {file}\"" ;;
      .ts)  LINT_COMMANDS="\"$LINT_STACK\": \"npx tsc --noEmit\"" ;;
      .js)  LINT_COMMANDS="\"$LINT_STACK\": \"node --check {file}\"" ;;
      .rb)  LINT_COMMANDS="\"$LINT_STACK\": \"ruby -c {file}\"" ;;
      .go)  LINT_COMMANDS="\"$LINT_STACK\": \"go vet {file}\"" ;;
      .rs)  LINT_COMMANDS="\"$LINT_STACK\": \"cargo check\"" ;;
      *)    warn "Unknown stack '$LINT_STACK' — lint_commands left empty"
            LINT_STACK="none" ;;
    esac
  fi

  # Determine phase prefix based on language
  if [ "$LANG_CHOICE" = "pt-br" ]; then
    PHASE_PREFIX="fase-"
  else
    PHASE_PREFIX="phase-"
  fi

  # Write config
  cat > "$CONFIG_FILE" <<JSONEOF
{
  "project": {
    "name": "$PROJECT_NAME",
    "description": "$PROJECT_DESC",
    "language": "$LANG_CHOICE"
  },
  "models": {
    "orchestrator": "Claude Sonnet 4.6 (copilot)",
    "complex_worker": "Claude Opus 4.6 (copilot)",
    "free_tier": "GPT-4.1 (copilot)"
  },
  "git": {
    "dev_branch": "$DEV_BRANCH",
    "main_branch": "main",
    "auto_push": true
  },
  "paths": {
    "source": "src/",
    "docs": "docs/",
    "phases": "docs/phases/",
    "phase_prefix": "$PHASE_PREFIX"
  },
  "lint_commands": {
$(if [ "$LINT_STACK" != "none" ]; then echo "    $LINT_COMMANDS"; fi)
  },
  "compliance": {
    "require_skill_check": true,
    "require_context_read": true,
    "require_changelog": true,
    "abex_enabled": true
  },
  "doc_sync": {
    "enabled": false,
    "script": "scripts/doc-sync.sh"
  }
}
JSONEOF
  installed "tao.config.json"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 3 — Copy templates (language-specific)
# ═══════════════════════════════════════════════════════════════
step "Copying templates ($LANG_CHOICE)"

TMPL_DIR="$TAO_DIR/templates/$LANG_CHOICE"

safe_copy "$TMPL_DIR/CLAUDE.md"    "$TARGET_DIR/CLAUDE.md"    "CLAUDE.md"
safe_copy "$TMPL_DIR/CONTEXT.md"   "$TARGET_DIR/CONTEXT.md"   "CONTEXT.md"
safe_copy "$TMPL_DIR/CHANGELOG.md" "$TARGET_DIR/CHANGELOG.md" "CHANGELOG.md"

mkdir -p "$TARGET_DIR/.github"
safe_copy "$TMPL_DIR/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md" ".github/copilot-instructions.md"

# ═══════════════════════════════════════════════════════════════
# STEP 4 — Copy agents (language-specific)
# ═══════════════════════════════════════════════════════════════
step "Copying agents ($LANG_CHOICE)"

AGENTS_DIR="$TAO_DIR/agents/$LANG_CHOICE"
mkdir -p "$TARGET_DIR/.github/agents"

if [ -d "$AGENTS_DIR" ] && compgen -G "$AGENTS_DIR/*.agent.md" > /dev/null 2>&1; then
  for agent_file in "$AGENTS_DIR/"*.agent.md; do
    AGENT_NAME="$(basename "$agent_file")"
    safe_copy "$agent_file" "$TARGET_DIR/.github/agents/$AGENT_NAME" ".github/agents/$AGENT_NAME"
  done
else
  warn "No agents found in agents/$LANG_CHOICE/ — populate TAO templates first"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 5 — Copy shared files (language-neutral)
# ═══════════════════════════════════════════════════════════════
step "Copying shared files"

mkdir -p "$TARGET_DIR/.github/hooks"
safe_copy "$TAO_DIR/templates/shared/hooks.json" "$TARGET_DIR/.github/hooks/hooks.json" ".github/hooks/hooks.json"

# ═══════════════════════════════════════════════════════════════
# STEP 6 — Copy hooks & scripts
# ═══════════════════════════════════════════════════════════════
step "Copying hooks & scripts"

mkdir -p "$TARGET_DIR/scripts"

safe_copy_exec "$TAO_DIR/hooks/lint-hook.sh"      "$TARGET_DIR/scripts/lint-hook.sh"      "scripts/lint-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/context-hook.sh"    "$TARGET_DIR/scripts/context-hook.sh"    "scripts/context-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/install-hooks.sh"   "$TARGET_DIR/scripts/install-hooks.sh"   "scripts/install-hooks.sh"
safe_copy_exec "$TAO_DIR/hooks/pre-commit.sh"      "$TARGET_DIR/scripts/pre-commit.sh"      "scripts/pre-commit.sh"

# ═══════════════════════════════════════════════════════════════
# STEP 7 — Install git hooks
# ═══════════════════════════════════════════════════════════════
step "Installing git hooks"

if [ -d "$TARGET_DIR/.git" ]; then
  if [ -x "$TARGET_DIR/scripts/install-hooks.sh" ]; then
    echo -e "    Running ${BOLD}scripts/install-hooks.sh${NC}..."
    (cd "$TARGET_DIR" && bash scripts/install-hooks.sh) && {
      echo -e "    ${GREEN}✅${NC} Git hooks installed"
    } || {
      warn "install-hooks.sh exited with error — configure hooks manually"
    }
  else
    warn "scripts/install-hooks.sh not found or not executable — skipping hook installation"
  fi
else
  warn "Not a git repository — skipping hook installation"
  echo -e "    Run ${BOLD}git init && bash scripts/install-hooks.sh${NC} later"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 8 — Set onboarding mode in CONTEXT.md (D14)
# ═══════════════════════════════════════════════════════════════
step "Setting onboarding mode"

CONTEXT_FILE="$TARGET_DIR/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  # If CONTEXT.md has a status placeholder, replace it; otherwise note it
  if grep -q 'status:' "$CONTEXT_FILE" 2>/dev/null; then
    sed -i 's/status:.*/status: new_project/' "$CONTEXT_FILE"
    echo -e "    ${GREEN}✅${NC} CONTEXT.md → status: new_project"
  else
    # Append status line at top after first heading
    sed -i '1,/^#/{/^#/a\status: new_project
    }' "$CONTEXT_FILE" 2>/dev/null || true
    echo -e "    ${GREEN}✅${NC} CONTEXT.md → status: new_project (appended)"
  fi
else
  warn "CONTEXT.md not found — onboarding status not set"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 8b — Substitute placeholders in all installed files
# ═══════════════════════════════════════════════════════════════
step "Substituting placeholders"

# Replace {{PROJECT_NAME}} and {{PROJECT_DESCRIPTION}} in all text files
PLACEHOLDER_COUNT=0
while IFS= read -r tgt_file; do
  if grep -q '{{PROJECT_NAME}}\|{{PROJECT_DESCRIPTION}}' "$tgt_file" 2>/dev/null; then
    sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$tgt_file"
    sed -i "s/{{PROJECT_DESCRIPTION}}/$PROJECT_DESC/g" "$tgt_file"
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
  fi
done < <(find "$TARGET_DIR" -maxdepth 3 -type f \( -name '*.md' -o -name '*.json' \) -not -path '*/.git/*' 2>/dev/null)
echo -e "    ${GREEN}✅${NC} Substituted placeholders in $PLACEHOLDER_COUNT files"

# ═══════════════════════════════════════════════════════════════
# STEP 9 — Summary
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ${BOLD}TAO (道) installed successfully!${NC}${GREEN}                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

if [ ${#INSTALLED[@]} -gt 0 ]; then
  echo -e "  ${GREEN}${BOLD}Installed (${#INSTALLED[@]}):${NC}"
  for item in "${INSTALLED[@]}"; do
    echo -e "    ${GREEN}✅${NC} $item"
  done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo ""
  echo -e "  ${YELLOW}${BOLD}Skipped (${#SKIPPED[@]}):${NC}"
  for item in "${SKIPPED[@]}"; do
    echo -e "    ${YELLOW}⤳${NC}  $item"
  done
fi

echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo ""
echo -e "  1. Review ${BOLD}tao.config.json${NC} — customize models, paths, lint commands"
echo -e "  2. Edit ${BOLD}CLAUDE.md${NC} — add project-specific rules and stack info"
echo -e "  3. Edit ${BOLD}CONTEXT.md${NC} — set your first active phase"
echo -e "  4. In VS Code: enable ${BOLD}chat.useCustomAgentHooks${NC} in Settings"
echo -e "  5. In Copilot Chat: select ${BOLD}@Tao${NC} and say ${BOLD}\"execute\"${NC}"
echo ""
echo -e "  ${BLUE}📖${NC} Read ${BOLD}TAO/README.md${NC} for full documentation"
echo ""
