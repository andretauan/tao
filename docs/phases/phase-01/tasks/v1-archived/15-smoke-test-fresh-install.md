# Task T15 — Bilingual Smoke Test: Fresh Install

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** High
**Executor:** Architect (Opus)
**Priority:** P4

---

## Objective

Perform a full end-to-end smoke test of TAO installation in both English and Portuguese on fresh directories, verifying every promise made by the README.

## Context

After all fixes (T01-T14) are applied, we need to verify the complete user journey works from install to first agent interaction. This test uses fresh temporary directories to simulate a vibe coder's first experience.

## Files to Read (BEFORE testing)

- `install.sh` — to understand expected behavior
- `README.md` — to verify promises match reality
- `README.pt-br.md` — same
- All modified files from T01-T14

## Test Plan

### Test A: English Install (Empty Project)

```bash
# Setup
mkdir -p /tmp/tao-smoke-en && cd /tmp/tao-smoke-en
git init

# Install
bash /path/to/TAO/install.sh /tmp/tao-smoke-en

# Verify
# 1. .github/tao/ exists with all expected files
# 2. .github/tao/tao.config.json is valid JSON
# 3. Phase 01 directory exists with templates
# 4. .vscode/settings.json exists with hooks enabled
# 5. lint_commands reflects auto-detected stack (should be "none" for empty project)
# 6. Install output shows ≤ 5 "next steps"
# 7. CONTEXT.md shows "01 — Awaiting Definition"
# 8. Agent files are present in .github/agents/
# 9. Hook files are present and executable
# 10. RULES.md references config for auto_push
# 11. RULES.md has novo_projeto exception
```

### Test B: Portuguese Install (Node.js Project)

```bash
# Setup
mkdir -p /tmp/tao-smoke-ptbr && cd /tmp/tao-smoke-ptbr
git init
echo '{"name": "test", "dependencies": {"typescript": "^5.0"}}' > package.json
echo '{}' > tsconfig.json

# Install (select pt-br)
bash /path/to/TAO/install.sh /tmp/tao-smoke-ptbr

# Verify
# 1. All files in Portuguese
# 2. Lint auto-detected as .ts
# 3. lint_commands has appropriate eslint/tsc command
# 4. Phase 01 exists with PT-BR templates
# 5. CONTEXT.md shows "01 — Aguardando Definição"
# 6. All verification points from Test A
```

### Test C: Hook Verification

```bash
# In the installed project directory
# 1. context-hook.sh runs without error
# 2. context-hook.sh shows dashboard with correct phase
# 3. lint-hook.sh with missing tool → shows warning (not error)
# 4. enforcement-hook.sh R5 message is strong
# 5. abex-gate.sh runs on the project → PASS (no code to scan)
```

### Test D: Script Verification

```bash
# Verify all scripts are functional
# 1. validate-plan.sh on phase 01 → appropriate output
# 2. validate-execution.sh → appropriate output
# 3. abex-gate.sh on clean project → exit 0
# 4. abex-gate.sh on deliberately insecure file → exit 1
```

## Acceptance Criteria

- [ ] English install completes without errors
- [ ] Portuguese install completes without errors
- [ ] Auto-detection works (empty dir → none, tsc project → .ts)
- [ ] Phase 01 created with correct templates in both languages
- [ ] .vscode/settings.json created with hooks enabled
- [ ] Dashboard shows correct information
- [ ] Lint hook handles missing tools gracefully
- [ ] ABEX gate passes on clean project, fails on insecure code
- [ ] All paths in tao.config.json resolve correctly
- [ ] CONTEXT.md has useful defaults (not [XX] placeholders)
- [ ] README claims match actual behavior
- [ ] No orphaned files or broken references

## Cleanup

```bash
rm -rf /tmp/tao-smoke-en /tmp/tao-smoke-ptbr
```

## Notes / Gotchas

- Run tests on BOTH macOS and Linux if possible (grep differences)
- The smoke test should be run AFTER all T01-T14 changes are committed to dev
- Document any issues found as new tasks if needed
- This is a MANUAL test — no automated test framework required

---

**Expected commit:** `test(phase-01): T15 — bilingual smoke test passes`
