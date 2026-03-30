# Task T23 — Regression Check Existing Projects

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P5-VERIFY
**Depends on:** T01-T21 (all implementation tasks)

---

## Objective

Verify that all changes are backward-compatible with existing TAO installations. Run the install script on the test project (tao-test) and verify hooks, config, and agents work correctly.

## Gaps Fixed

- Verification task — ensures no breaking changes for existing users

## Files to Read

- `/home/tauan/Apps/tao-test/` — existing test project
- `/home/tauan/Apps/tao-test/.github/tao/tao.config.json` — existing config
- `/home/tauan/Apps/tao-test/CLAUDE.md` — existing project file

## Verification Steps

### 1. Config compatibility

- Read existing tao.config.json in tao-test
- Verify new config fields (if any) have sensible defaults
- Verify no required field was renamed or removed

### 2. Hook compatibility

- Copy updated hooks to tao-test/.github/tao/hooks/
- Run pre-commit.sh manually — should pass on clean state
- Verify context-hook.sh generates valid CONTEXT dashboard
- Verify enforcement-hook.sh doesn't crash on missing fields

### 3. Agent compatibility

- Copy updated agents to tao-test/.github/agents/
- Verify CLAUDE.md still references correct paths
- Verify tao.instructions.md is compatible with updated agents

### 4. Install script compatibility

- Run install.sh on a fresh temp directory
- Verify it doesn't break on:
  - Empty directory (new project)
  - Directory with existing .github/ (existing project)
  - Directory with existing tao.config.json (upgrade path)

## Acceptance Criteria

- [ ] Existing tao-test config still works with new hooks
- [ ] pre-commit.sh runs without error on clean repo
- [ ] context-hook.sh generates valid output
- [ ] enforcement-hook.sh runs without error
- [ ] install.sh works on fresh directory
- [ ] install.sh doesn't overwrite existing config
- [ ] No breaking changes identified (or all documented)
