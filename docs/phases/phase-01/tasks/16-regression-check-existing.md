# Task T16 — Regression Check: Existing Project (tao-test)

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P4

---

## Objective

Verify that the TAO changes don't break an existing installation by re-installing on the tao-test project and checking that all existing functionality still works.

## Context

tao-test at `/home/tauan/Apps/tao-test` is an existing TAO installation. After all changes to the TAO framework (T01-T14), we need to verify that re-installing doesn't break anything and that existing projects can benefit from the improvements.

## Files to Read (BEFORE testing)

- `/home/tauan/Apps/tao-test/.github/tao/tao.config.json` — current config
- `/home/tauan/Apps/tao-test/CLAUDE.md` — current project identity
- All modified TAO framework files

## Test Plan

### Test A: Re-install Preserves Existing Config

```bash
# Backup current state
cp -r /home/tauan/Apps/tao-test/.github /tmp/tao-test-backup

# Re-install TAO
bash /home/tauan/Apps/TAO/install.sh /home/tauan/Apps/tao-test

# Verify
# 1. tao.config.json updated but project-specific values preserved
# 2. CONTEXT.md not overwritten (has project state)
# 3. CLAUDE.md not overwritten
# 4. Agent files updated to new versions
# 5. Hook files updated to new versions
# 6. .vscode/settings.json created or preserved

# Restore if needed
# cp -r /tmp/tao-test-backup/.github /home/tauan/Apps/tao-test/
```

### Test B: Hooks Work on Existing Project

```bash
cd /home/tauan/Apps/tao-test

# 1. context-hook.sh produces dashboard
# 2. lint-hook.sh handles the configured lint tool
# 3. enforcement-hook.sh works with existing rules
# 4. abex-gate.sh scans existing project files (if any)
```

### Test C: Agent Compatibility

```bash
# Verify agents load correctly
# 1. Executar-Tao.agent.md has onboarding flow but detects existing project
# 2. Wu agent has rate-limit message
# 3. No YAML frontmatter errors in any agent file
```

## Acceptance Criteria

- [ ] Re-install doesn't lose existing project configuration
- [ ] Re-install doesn't overwrite CONTEXT.md or CLAUDE.md
- [ ] Updated hooks work on existing project
- [ ] Agent files are valid (no YAML errors)
- [ ] Dashboard shows correct info for existing project
- [ ] No regression in existing functionality
- [ ] tao-test project can still be used normally after re-install

## Notes / Gotchas

- install.sh may need logic to detect existing installation and merge vs overwrite
- If install.sh currently always overwrites, this test may reveal a new issue → document as finding
- Always backup before re-install testing
- The key question: does install.sh support UPDATES or only FRESH installs?

---

**Expected commit:** `test(phase-01): T16 — regression check on tao-test passes`
