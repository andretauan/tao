# Task T02 — install.sh: Auto-Detect Lint Stack

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P0

---

## Objective

Replace the confusing Q5 lint stack question in install.sh with auto-detection from project files. Keep a confirmation prompt so users can override.

## Context

The current Q5 asks: "Primary stack for lint: .php | .py | .ts | .js | .rb | .go | .rs | none". A vibe coder doesn't know which language their project uses. Most will press Enter → `none` → ALL lint quality gates disabled. Auto-detection from project files (package.json → .ts/.js, requirements.txt → .py, etc.) eliminates this problem.

## Files to Read (BEFORE editing)

- `install.sh` — full file, especially Q5 section (lines ~127-148) and lint command generation

## Files to Create/Edit

- `install.sh` — replace Q5 with auto-detection logic

## Implementation Steps

1. Read install.sh completely
2. Replace the Q5 block (between `# Q5: Lint stack` and the next section) with:
   ```bash
   # Q5: Lint stack — auto-detect
   echo ""
   echo -e "    ${BOLD}Detecting primary stack...${NC}"
   DETECTED="none"
   
   # Detection order: most specific first
   if [ -f "$TARGET_DIR/tsconfig.json" ]; then
     DETECTED=".ts"
   elif [ -f "$TARGET_DIR/package.json" ] && grep -q '"typescript"' "$TARGET_DIR/package.json" 2>/dev/null; then
     DETECTED=".ts"
   elif [ -f "$TARGET_DIR/package.json" ]; then
     DETECTED=".js"
   elif [ -f "$TARGET_DIR/requirements.txt" ] || [ -f "$TARGET_DIR/pyproject.toml" ] || [ -f "$TARGET_DIR/setup.py" ]; then
     DETECTED=".py"
   elif [ -f "$TARGET_DIR/composer.json" ]; then
     DETECTED=".php"
   elif [ -f "$TARGET_DIR/go.mod" ]; then
     DETECTED=".go"
   elif [ -f "$TARGET_DIR/Gemfile" ]; then
     DETECTED=".rb"
   elif [ -f "$TARGET_DIR/Cargo.toml" ]; then
     DETECTED=".rs"
   fi
   
   if [ "$DETECTED" != "none" ]; then
     echo -e "    Detected: ${GREEN}${DETECTED}${NC}"
     read -r -p "    Confirm or change [$DETECTED]: " INPUT_LINT
     LINT_STACK="${INPUT_LINT:-$DETECTED}"
   else
     echo -e "    ${YELLOW}No stack detected.${NC} You can set one manually."
     echo -e "    Options: ${GREEN}.php${NC} | ${GREEN}.py${NC} | ${GREEN}.ts${NC} | ${GREEN}.js${NC} | ${GREEN}.rb${NC} | ${GREEN}.go${NC} | ${GREEN}.rs${NC} | ${GREEN}none${NC}"
     read -r -p "    Primary stack [none]: " INPUT_LINT
     LINT_STACK="${INPUT_LINT:-none}"
   fi
   
   if [ "$LINT_STACK" = "none" ]; then
     warn "No lint configured. TAO won't verify syntax errors automatically."
     echo -e "    To add later: edit .github/tao/tao.config.json → lint_commands"
   fi
   
   echo -e "    → ${GREEN}$LINT_STACK${NC}"
   ```
3. Keep the existing lint command mapping (`case` statement) unchanged
4. Test: run install.sh on a directory with package.json, verify `.ts` is detected

## Acceptance Criteria

- [ ] Q5 auto-detects from: tsconfig.json, package.json, requirements.txt, pyproject.toml, setup.py, composer.json, go.mod, Gemfile, Cargo.toml
- [ ] User can override the detection
- [ ] `none` shows a clear warning about disabled quality gates
- [ ] Empty project falls back to manual selection with `none` default
- [ ] Existing lint command mapping (`case` statement) still works
- [ ] Install completes successfully with detected and manual stacks

## Notes / Gotchas

- Detection checks TARGET_DIR, not current dir
- Order matters: tsconfig.json before package.json (more specific wins)
- Don't break the LINT_STACK variable name — it's used downstream

---

**Expected commit:** `feat(phase-01): T02 — auto-detect lint stack in install.sh`
