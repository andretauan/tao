# Task T03 — install.sh: Create Phase 01 + .vscode + Simplify Output

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P0

---

## Objective

Make install.sh create the first phase directory (phase-01), auto-generate `.vscode/settings.json` with hook activation, and simplify the "Next steps" output to 3 clear actions.

## Context

Currently install.sh creates `.github/tao/` but leaves the user with an empty project and 8+ "next steps" instructions. A vibe coder won't know what to do. By creating phase 01 and activating hooks automatically, the user can start working immediately after install.

## Files to Read (BEFORE editing)

- `install.sh` — full file, especially the "create structure" section and "Next steps" output
- `phases/pt-br/PLAN.md.template` — to know what goes in a phase
- `phases/pt-br/STATUS.md.template`
- `phases/pt-br/progress.txt.template`
- `templates/pt-br/CONTEXT.md` — to see the phase reference format

## Files to Create/Edit

- `install.sh` — add phase 01 creation + .vscode/settings.json + simplify output

## Implementation Steps

1. Read install.sh completely
2. After the existing structure creation (`.github/tao/`, `.github/skills/`, etc.), add:
   ```bash
   # ===== Create Phase 01 =====
   PHASE_DIR="$TARGET_DIR/$PHASES_DIR/${PHASE_PREFIX}01"
   mkdir -p "$PHASE_DIR/brainstorm"
   mkdir -p "$PHASE_DIR/tasks"
   
   # Copy phase templates (use detected language)
   if [ -f "$SCRIPT_DIR/phases/$LANG/PLAN.md.template" ]; then
     cp "$SCRIPT_DIR/phases/$LANG/PLAN.md.template" "$PHASE_DIR/PLAN.md"
     cp "$SCRIPT_DIR/phases/$LANG/STATUS.md.template" "$PHASE_DIR/STATUS.md"
     cp "$SCRIPT_DIR/phases/$LANG/progress.txt.template" "$PHASE_DIR/progress.txt"
   fi
   
   echo -e "    ${GREEN}✓${NC} Phase 01 created at $PHASES_DIR/${PHASE_PREFIX}01/"
   ```

3. Add .vscode/settings.json creation:
   ```bash
   # ===== Auto-activate VS Code hooks =====
   VSCODE_DIR="$TARGET_DIR/.vscode"
   VSCODE_SETTINGS="$VSCODE_DIR/settings.json"
   
   if [ ! -f "$VSCODE_SETTINGS" ]; then
     mkdir -p "$VSCODE_DIR"
     cat > "$VSCODE_SETTINGS" << 'SETTINGS'
   {
     "chat.useCustomAgentHooks": true
   }
   SETTINGS
     echo -e "    ${GREEN}✓${NC} VS Code hooks activated (.vscode/settings.json)"
   else
     # Check if setting already exists
     if ! grep -q "chat.useCustomAgentHooks" "$VSCODE_SETTINGS"; then
       warn ".vscode/settings.json exists but missing chat.useCustomAgentHooks"
       echo -e "    Add manually: ${BOLD}\"chat.useCustomAgentHooks\": true${NC}"
     fi
   fi
   ```

4. Replace the "Next steps" section with:
   ```bash
   echo ""
   echo -e "${BOLD}${GREEN}✅ TAO installed!${NC}"
   echo ""
   echo -e "  ${BOLD}What to do now:${NC}"
   echo -e "  1. Open the project in VS Code"
   echo -e "  2. Open Copilot Chat → type: ${GREEN}@Executar-Tao${NC} (or ${GREEN}@Execute-Tao${NC})"
   echo -e "  3. Describe your project idea"
   echo ""
   echo -e "  ${DIM}TAO will guide you from there.${NC}"
   ```

5. Test: run install on a clean directory, verify phase-01/ exists with templates, .vscode/settings.json exists

## Acceptance Criteria

- [ ] install.sh creates `{phases_dir}/{phase_prefix}01/` with PLAN.md, STATUS.md, progress.txt
- [ ] install.sh creates `{phases_dir}/{phase_prefix}01/brainstorm/` and `tasks/` subdirectories
- [ ] Phase templates are copied in the correct language
- [ ] `.vscode/settings.json` is created with `chat.useCustomAgentHooks: true`
- [ ] If `.vscode/settings.json` already exists, it warns but doesn't overwrite
- [ ] "Next steps" output is ≤ 5 lines, actionable
- [ ] Fresh install ends with clear "what to do now" instructions

## Notes / Gotchas

- PHASES_DIR and PHASE_PREFIX variables come from tao.config.json values set earlier in install.sh
- Language detection (LANG variable) must be available at this point in the script
- Don't overwrite existing .vscode/settings.json — it may have user customizations
- The phase templates use the shared/ templates for language-agnostic files

---

**Expected commit:** `feat(phase-01): T03 — install.sh creates phase 01 + .vscode + simplified output`
