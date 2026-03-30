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

# ─── Prerequisites ────────────────────────────────────────────
command -v python3 >/dev/null 2>&1 || {
  echo "Error: python3 is required but not installed."
  echo "Install Python 3.8+ and try again."
  exit 1
}

command -v git >/dev/null 2>&1 || {
  echo "Error: git is required but not installed."
  exit 1
}

# ─── Portable sed -i (macOS + Linux) ─────────────────────────
sed_i() {
  local file="$1"
  shift
  local tmpfile
  tmpfile=$(mktemp "${file}.XXXXXX")
  if sed "$@" "$file" > "$tmpfile"; then
    mv "$tmpfile" "$file"
  else
    rm -f "$tmpfile" 2>/dev/null
    return 1
  fi
}

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
    return 0
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

# Q5: Lint stack — auto-detect from project files
echo ""
echo -e "    ${BOLD}Detecting lint stack...${NC}"
LINT_CMDS_JSON="{}"

_detect_lint() {
  local -a _pairs=()
  # PHP
  if [ -f "${TARGET_DIR}/vendor/bin/phpstan" ]; then
    _pairs+=(".php|./vendor/bin/phpstan analyse {file}")
  elif [ -f "${TARGET_DIR}/vendor/bin/phpcs" ]; then
    _pairs+=(".php|vendor/bin/phpcs --standard=PSR12 {file}")
  elif [ -f "${TARGET_DIR}/vendor/bin/pint" ]; then
    _pairs+=(".php|./vendor/bin/pint --test {file}")
  fi
  # JavaScript/TypeScript
  if [ -f "${TARGET_DIR}/node_modules/.bin/eslint" ]; then
    _pairs+=(".js|npx eslint {file}")
    _pairs+=(".ts|npx eslint {file}")
  fi
  if [ -f "${TARGET_DIR}/node_modules/.bin/tsc" ] || [ -f "${TARGET_DIR}/tsconfig.json" ]; then
    _pairs+=(".ts|npx tsc --noEmit")
  fi
  # Python
  if command -v ruff &>/dev/null && ([ -f "${TARGET_DIR}/pyproject.toml" ] || [ -f "${TARGET_DIR}/setup.cfg" ]); then
    _pairs+=(".py|ruff check {file}")
  elif command -v flake8 &>/dev/null && ([ -f "${TARGET_DIR}/.flake8" ] || [ -f "${TARGET_DIR}/setup.cfg" ]); then
    _pairs+=(".py|flake8 {file}")
  elif [ -f "${TARGET_DIR}/requirements.txt" ] || [ -f "${TARGET_DIR}/pyproject.toml" ]; then
    _pairs+=(".py|python3 -m py_compile {file}")
  fi
  # Go
  if [ -f "${TARGET_DIR}/go.mod" ]; then
    _pairs+=(".go|go vet ./...")
  fi
  # Rust
  if [ -f "${TARGET_DIR}/Cargo.toml" ]; then
    _pairs+=(".rs|cargo check")
  fi
  # Ruby
  if [ -f "${TARGET_DIR}/Gemfile" ]; then
    _pairs+=(".rb|ruby -c {file}")
  fi

  if [ ${#_pairs[@]} -eq 0 ]; then
    echo -e "    ${YELLOW}⚠️  No lint tools detected automatically.${NC}"
    echo -e "    Enter lint extension=command pairs (e.g. .py=python3 -m py_compile {file}) or press Enter to skip:"
    read -r -p "    Lint commands [skip]: " _manual_input
    if [ -n "$_manual_input" ]; then
      # Build simple single-entry from manual input
      _ext="${_manual_input%%=*}"
      _cmd="${_manual_input#*=}"
      LINT_CMDS_JSON=$(python3 -c "import json; print(json.dumps({'$_ext': '$_cmd'}))" 2>/dev/null || echo "{}")
    fi
  else
    echo -e "    ${GREEN}✅ Detected lint tools:${NC}"
    for _p in "${_pairs[@]}"; do
      echo -e "    ${GREEN}   - ${_p%%|*}: ${_p##*|}${NC}"
    done
    echo ""
    read -r -p "    Accept detected configuration? [Y/n]: " _confirm
    if [[ "$_confirm" =~ ^[Nn]$ ]]; then
      echo -e "    Enter lint extension=command pairs or press Enter for detected:"
      read -r -p "    [keep detected]: " _override
      if [ -n "$_override" ]; then
        _ext="${_override%%=*}"
        _cmd="${_override#*=}"
        LINT_CMDS_JSON=$(python3 -c "import json; print(json.dumps({'$_ext': '$_cmd'}))" 2>/dev/null || echo "{}")
      fi
    fi
    if [ "$LINT_CMDS_JSON" = "{}" ] && [ ${#_pairs[@]} -gt 0 ]; then
      # Build JSON from detected pairs
      LINT_CMDS_JSON=$(python3 -c "
import json
pairs = [p.split('|',1) for p in $(printf '%s\n' "${_pairs[@]}" | python3 -c "import sys,json; print(json.dumps([l.rstrip() for l in sys.stdin]))" 2>/dev/null || echo "[]")]
print(json.dumps(dict(pairs)))
" 2>/dev/null)
      [ -z "$LINT_CMDS_JSON" ] || [ "$LINT_CMDS_JSON" = "null" ] && LINT_CMDS_JSON="{}"
    fi
  fi
  unset _pairs
}
_detect_lint
echo -e "    → ${GREEN}lint_commands: $LINT_CMDS_JSON${NC}"

# ═══════════════════════════════════════════════════════════════
# STEP 2 — Generate tao.config.json
# ═══════════════════════════════════════════════════════════════
step "Generating tao.config.json"

mkdir -p "$TARGET_DIR/.github/tao"
CONFIG_FILE="$TARGET_DIR/.github/tao/tao.config.json"

if [ -f "$CONFIG_FILE" ]; then
  skipped "tao.config.json"
else
  # Determine phase prefix based on language
  if [ "$LANG_CHOICE" = "pt-br" ]; then
    PHASE_PREFIX="fase-"
  else
    PHASE_PREFIX="phase-"
  fi

  # Write config using python3 for proper JSON escaping
  python3 -c "
import json, sys
config = {
    'project': {
        'name': sys.argv[1],
        'description': sys.argv[2],
        'language': sys.argv[3]
    },
    'models': {
        'orchestrator': 'Claude Sonnet 4.6 (copilot)',
        'complex_worker': 'Claude Opus 4.6 (copilot)',
        'free_tier': 'GPT-4.1 (copilot)'
    },
    'git': {
        'dev_branch': sys.argv[4],
        'main_branch': 'main',
        'auto_push': False
    },
    'paths': {
        'source': 'src/',
        'docs': 'docs/',
        'phases': 'docs/phases/',
        'phase_prefix': sys.argv[5]
    },
    'lint_commands': json.loads(sys.argv[6]),
    'commit_scopes': [],
    'compliance': {
        'require_skill_check': True,
        'require_context_read': True,
        'require_changelog': True,
        'abex_enabled': True
    },
    'doc_sync': {
        'enabled': False,
        'script': '.github/tao/scripts/doc-sync.sh'
    }
}
with open(sys.argv[7], 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write('\n')
" "$PROJECT_NAME" "$PROJECT_DESC" "$LANG_CHOICE" "$DEV_BRANCH" "$PHASE_PREFIX" "${LINT_CMDS_JSON:-{}}" "$CONFIG_FILE"
  if [ -f "$CONFIG_FILE" ]; then
    installed ".github/tao/tao.config.json"
  else
    warn "Failed to generate tao.config.json — python3 error"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# STEP 3 — Copy templates (language-specific)
# ═══════════════════════════════════════════════════════════════
step "Copying templates ($LANG_CHOICE)"

TMPL_DIR="$TAO_DIR/templates/$LANG_CHOICE"

safe_copy "$TMPL_DIR/CLAUDE.md"    "$TARGET_DIR/CLAUDE.md"    "CLAUDE.md"

mkdir -p "$TARGET_DIR/.github/tao"
safe_copy "$TMPL_DIR/CONTEXT.md"   "$TARGET_DIR/.github/tao/CONTEXT.md"   ".github/tao/CONTEXT.md"
safe_copy "$TMPL_DIR/CHANGELOG.md" "$TARGET_DIR/.github/tao/CHANGELOG.md" ".github/tao/CHANGELOG.md"

# TAO-managed files — always overwrite (no safe_copy)
mkdir -p "$TARGET_DIR/.github/tao"
cp "$TMPL_DIR/RULES.md" "$TARGET_DIR/.github/tao/RULES.md"
installed ".github/tao/RULES.md"

mkdir -p "$TARGET_DIR/.github/instructions"
cp "$TAO_DIR/templates/shared/tao.instructions.md" "$TARGET_DIR/.github/instructions/tao.instructions.md"
installed ".github/instructions/tao.instructions.md"

# Context-triggered instruction files — always overwrite (TAO-managed)
for instr_file in "$TAO_DIR/templates/shared/"tao-*.instructions.md; do
  [ -f "$instr_file" ] || continue
  INSTR_NAME="$(basename "$instr_file")"
  cp "$instr_file" "$TARGET_DIR/.github/instructions/$INSTR_NAME"
  installed ".github/instructions/$INSTR_NAME"
done

# copilot-instructions.md — only if user doesn't already have one (non-invasive)
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
# STEP 4b — Copy skills (language-specific)
# ═══════════════════════════════════════════════════════════════
step "Copying skills ($LANG_CHOICE)"

SKILLS_DIR="$TAO_DIR/skills/$LANG_CHOICE"
mkdir -p "$TARGET_DIR/.github/skills"

# Copy INDEX.md
safe_copy "$TAO_DIR/templates/$LANG_CHOICE/INDEX.md" "$TARGET_DIR/.github/skills/INDEX.md" ".github/skills/INDEX.md"

# Copy each skill directory
if [ -d "$SKILLS_DIR" ]; then
  for skill_dir in "$SKILLS_DIR/"*/; do
    [ -d "$skill_dir" ] || continue
    SKILL_NAME="$(basename "$skill_dir")"
    mkdir -p "$TARGET_DIR/.github/skills/$SKILL_NAME"
    safe_copy "$skill_dir/SKILL.md" "$TARGET_DIR/.github/skills/$SKILL_NAME/SKILL.md" ".github/skills/$SKILL_NAME/SKILL.md"
  done
else
  warn "No skills found in skills/$LANG_CHOICE/ — check TAO installation"
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

mkdir -p "$TARGET_DIR/.github/tao/scripts"

safe_copy_exec "$TAO_DIR/hooks/lint-hook.sh"      "$TARGET_DIR/.github/tao/scripts/lint-hook.sh"      ".github/tao/scripts/lint-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/context-hook.sh"    "$TARGET_DIR/.github/tao/scripts/context-hook.sh"    ".github/tao/scripts/context-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/enforcement-hook.sh" "$TARGET_DIR/.github/tao/scripts/enforcement-hook.sh" ".github/tao/scripts/enforcement-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/install-hooks.sh"   "$TARGET_DIR/.github/tao/scripts/install-hooks.sh"   ".github/tao/scripts/install-hooks.sh"
safe_copy_exec "$TAO_DIR/hooks/pre-commit.sh"      "$TARGET_DIR/.github/tao/scripts/pre-commit.sh"      ".github/tao/scripts/pre-commit.sh"
safe_copy_exec "$TAO_DIR/hooks/abex-hook.sh"       "$TARGET_DIR/.github/tao/scripts/abex-hook.sh"       ".github/tao/scripts/abex-hook.sh"
safe_copy_exec "$TAO_DIR/hooks/commit-msg.sh"      "$TARGET_DIR/.github/tao/scripts/commit-msg.sh"      ".github/tao/scripts/commit-msg.sh"
safe_copy_exec "$TAO_DIR/hooks/pre-push.sh"        "$TARGET_DIR/.github/tao/scripts/pre-push.sh"        ".github/tao/scripts/pre-push.sh"
safe_copy_exec "$TAO_DIR/scripts/abex-gate.sh"     "$TARGET_DIR/.github/tao/scripts/abex-gate.sh"       ".github/tao/scripts/abex-gate.sh"
safe_copy_exec "$TAO_DIR/scripts/validate-plan.sh"      "$TARGET_DIR/.github/tao/scripts/validate-plan.sh"      ".github/tao/scripts/validate-plan.sh"
safe_copy_exec "$TAO_DIR/scripts/validate-execution.sh"  "$TARGET_DIR/.github/tao/scripts/validate-execution.sh"  ".github/tao/scripts/validate-execution.sh"
safe_copy_exec "$TAO_DIR/scripts/new-phase.sh"           "$TARGET_DIR/.github/tao/scripts/new-phase.sh"           ".github/tao/scripts/new-phase.sh"
safe_copy_exec "$TAO_DIR/scripts/validate-brainstorm.sh"  "$TARGET_DIR/.github/tao/scripts/validate-brainstorm.sh"  ".github/tao/scripts/validate-brainstorm.sh"
safe_copy_exec "$TAO_DIR/scripts/faudit.sh"              "$TARGET_DIR/.github/tao/scripts/faudit.sh"              ".github/tao/scripts/faudit.sh"
safe_copy_exec "$TAO_DIR/scripts/forensic-audit.sh"      "$TARGET_DIR/.github/tao/scripts/forensic-audit.sh"      ".github/tao/scripts/forensic-audit.sh"
safe_copy_exec "$TAO_DIR/scripts/doc-validate.sh"        "$TARGET_DIR/.github/tao/scripts/doc-validate.sh"        ".github/tao/scripts/doc-validate.sh"

# ═══════════════════════════════════════════════════════════════
# STEP 6b — Copy phase templates
# ═══════════════════════════════════════════════════════════════
step "Copying phase templates"

PHASE_TMPL_LANG="$TAO_DIR/phases/$LANG_CHOICE"
PHASE_TMPL_SHARED="$TAO_DIR/phases/shared"
PHASE_TARGET="$TARGET_DIR/.github/tao/phases"

mkdir -p "$PHASE_TARGET/$LANG_CHOICE"
mkdir -p "$PHASE_TARGET/shared"

if [ -d "$PHASE_TMPL_LANG" ]; then
  for tmpl in "$PHASE_TMPL_LANG/"*; do
    [ -f "$tmpl" ] && safe_copy "$tmpl" "$PHASE_TARGET/$LANG_CHOICE/$(basename "$tmpl")" ".github/tao/phases/$LANG_CHOICE/$(basename "$tmpl")"
  done
fi

if [ -d "$PHASE_TMPL_SHARED" ]; then
  for tmpl in "$PHASE_TMPL_SHARED/"*; do
    [ -f "$tmpl" ] && safe_copy "$tmpl" "$PHASE_TARGET/shared/$(basename "$tmpl")" ".github/tao/phases/shared/$(basename "$tmpl")"
  done
fi

# ═══════════════════════════════════════════════════════════════
# STEP 6c — Create initial phase directory (phase-01 / fase-01)
# ═══════════════════════════════════════════════════════════════
step "Creating initial phase directory"

_phases_sub="docs/phases"
_p_prefix="phase-"
if [ "$LANG_CHOICE" = "pt-br" ]; then
  _phases_sub="docs/phases"
  _p_prefix="fase-"
fi
INITIAL_PHASE_DIR="$TARGET_DIR/$_phases_sub/${_p_prefix}01"

if [ -d "$INITIAL_PHASE_DIR" ]; then
  skipped "$_phases_sub/${_p_prefix}01/"
else
  mkdir -p "$INITIAL_PHASE_DIR/brainstorm" "$INITIAL_PHASE_DIR/tasks"
  # Copy language-specific phase templates
  for tmpl in "$TAO_DIR/phases/$LANG_CHOICE"/*.template; do
    [ -f "$tmpl" ] || continue
    _dest="$INITIAL_PHASE_DIR/$(basename "${tmpl%.template}")"
    [ ! -f "$_dest" ] && cp "$tmpl" "$_dest"
  done
  # progress.txt
  [ ! -f "$INITIAL_PHASE_DIR/progress.txt" ] && touch "$INITIAL_PHASE_DIR/progress.txt"
  installed "$_phases_sub/${_p_prefix}01/"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 6d — Create .vscode/settings.json (enable agent hooks)
# ═══════════════════════════════════════════════════════════════
step "Configuring VS Code settings"

VSCODE_DIR="$TARGET_DIR/.vscode"
VSCODE_SETTINGS="$VSCODE_DIR/settings.json"

mkdir -p "$VSCODE_DIR"
if [ ! -f "$VSCODE_SETTINGS" ]; then
  cat > "$VSCODE_SETTINGS" << 'VSSETTINGS'
{
  "chat.useCustomAgentHooks": true
}
VSSETTINGS
  installed ".vscode/settings.json"
elif grep -q '"chat.useCustomAgentHooks"' "$VSCODE_SETTINGS" 2>/dev/null; then
  skipped ".vscode/settings.json (already configured)"
else
  echo -e "    ${YELLOW}⚠️${NC}  .vscode/settings.json exists — add ${BOLD}\"chat.useCustomAgentHooks\": true${NC} manually"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 6e — Update .gitignore with TAO entries
# ═══════════════════════════════════════════════════════════════
step "Updating .gitignore"

GITIGNORE_FILE="$TARGET_DIR/.gitignore"
TAO_GITIGNORE_MARKER="# TAO Framework"

if [ -f "$GITIGNORE_FILE" ] && grep -q "$TAO_GITIGNORE_MARKER" "$GITIGNORE_FILE" 2>/dev/null; then
  skipped ".gitignore (TAO entries already present)"
else
  {
    echo ""
    echo "# TAO Framework"
    echo ".tao-pause"
    echo ".gsd-pause"
    echo ".tao-session/"
    echo "*.tao.local"
  } >> "$GITIGNORE_FILE"
  installed ".gitignore (TAO entries added)"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 7 — Install git hooks
# ═══════════════════════════════════════════════════════════════
step "Installing git hooks"

if [ -d "$TARGET_DIR/.git" ]; then
  if [ -x "$TARGET_DIR/.github/tao/scripts/install-hooks.sh" ]; then
    echo -e "    Running ${BOLD}.github/tao/scripts/install-hooks.sh${NC}..."
    (cd "$TARGET_DIR" && bash .github/tao/scripts/install-hooks.sh) && {
      echo -e "    ${GREEN}✅${NC} Git hooks installed"
    } || {
      warn "install-hooks.sh exited with error — configure hooks manually"
    }
  else
    warn ".github/tao/scripts/install-hooks.sh not found or not executable — skipping hook installation"
  fi
else
  warn "Not a git repository — skipping hook installation"
  echo -e "    Run ${BOLD}git init && bash .github/tao/scripts/install-hooks.sh${NC} later"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 8 — Set onboarding mode in CONTEXT.md (D14)
# ═══════════════════════════════════════════════════════════════
step "Setting onboarding mode"

CONTEXT_FILE="$TARGET_DIR/.github/tao/CONTEXT.md"
if [ -f "$CONTEXT_FILE" ]; then
  # If CONTEXT.md has a status placeholder, replace it; otherwise note it
  # Use language-appropriate status value
  if [ "$LANG_CHOICE" = "pt-br" ]; then
    ONBOARD_STATUS="novo_projeto"
  else
    ONBOARD_STATUS="new_project"
  fi

  if grep -q '^\*\*Status:' "$CONTEXT_FILE" 2>/dev/null; then
    sed_i "$CONTEXT_FILE" "s|^\*\*Status:\*\*.*|**Status:** $ONBOARD_STATUS|"
    echo -e "    ${GREEN}✅${NC} CONTEXT.md → status: $ONBOARD_STATUS"
  else
    # Append status line at top after first heading
    sed_i "$CONTEXT_FILE" "1,/^#/{/^#/a\\status: $ONBOARD_STATUS
    }" 2>/dev/null || true
    echo -e "    ${GREEN}✅${NC} CONTEXT.md → status: $ONBOARD_STATUS (appended)"
  fi
else
  warn "CONTEXT.md not found — onboarding status not set"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 8b — Substitute placeholders in all installed files
# ═══════════════════════════════════════════════════════════════
step "Substituting placeholders"

# Replace {{PROJECT_NAME}} and {{PROJECT_DESCRIPTION}} in all text files
# Escape special sed characters in user input
SAFE_NAME=$(printf '%s' "$PROJECT_NAME" | sed 's/[&/\\]/\\&/g')
SAFE_DESC=$(printf '%s' "$PROJECT_DESC" | sed 's/[&/\\]/\\&/g')

PLACEHOLDER_COUNT=0
while IFS= read -r tgt_file; do
  if grep -q '{{PROJECT_NAME}}\|{{PROJECT_DESCRIPTION}}' "$tgt_file" 2>/dev/null; then
    sed_i "$tgt_file" "s|{{PROJECT_NAME}}|$SAFE_NAME|g"
    sed_i "$tgt_file" "s|{{PROJECT_DESCRIPTION}}|$SAFE_DESC|g"
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
if [ "$LANG_CHOICE" = "pt-br" ]; then
  echo -e "  ${BOLD}Próximos passos:${NC}"
  echo ""
  echo -e "  1. Revise ${BOLD}.github/tao/tao.config.json${NC} — personalize modelos, caminhos, comandos de lint"
  echo -e "  2. Edite ${BOLD}CLAUDE.md${NC} — adicione regras e padrões de código do projeto"
  echo -e "  3. Abra o VS Code: ${BOLD}chat.useCustomAgentHooks${NC} está habilitado em .vscode/settings.json"
  echo -e "  4. No Copilot Chat: selecione ${BOLD}@Executar-Tao${NC} e diga ${BOLD}\"executar\"${NC}"
  echo -e "  5. O agente vai ler STATUS.md e iniciar a primeira tarefa automaticamente"
  echo ""
  echo -e "  ${BLUE}📖${NC} Leia ${BOLD}TAO/README.pt-br.md${NC} para documentação completa"
else
  echo -e "  ${BOLD}Next steps:${NC}"
  echo ""
  echo -e "  1. Review ${BOLD}.github/tao/tao.config.json${NC} — customize models, paths, lint commands"
  echo -e "  2. Edit ${BOLD}CLAUDE.md${NC} — add project-specific rules and code patterns"
  echo -e "  3. Open VS Code: ${BOLD}chat.useCustomAgentHooks${NC} is enabled via .vscode/settings.json"
  echo -e "  4. In Copilot Chat: select ${BOLD}@Execute-Tao${NC} and say ${BOLD}\"execute\"${NC}"
  echo -e "  5. The agent will read STATUS.md and start the first task automatically"
  echo ""
  echo -e "  ${BLUE}📖${NC} Read ${BOLD}TAO/README.md${NC} for full documentation"
fi
echo ""
