# Task T24 — Enforcement Test L0/L1 Hooks

**Phase:** 01 — Enforcement Architecture
**Complexity:** High
**Executor:** Sonnet
**Priority:** P5-VERIFY
**Depends on:** T01-T08 (all hook tasks)

---

## Objective

Systematically test all enforcement hooks (L0 and L1) with positive and negative test cases. Every hook must block what it claims to block and pass what it claims to pass.

## Gaps Fixed

- Verification task — ensures enforcement actually works as designed

## Files to Read

- `hooks/pre-commit.sh` — L0 enforcement
- `hooks/install-hooks.sh` — hook installation (commit-msg, pre-push)
- `hooks/enforcement-hook.sh` — L1 enforcement
- `hooks/context-hook.sh` — L1 context injection
- `hooks/lint-hook.sh` — L1 lint enforcement
- New files: `scripts/abex-gate.sh`, `hooks/abex-hook.sh` (created in T04, T07)

## Test Cases

### L0 — Pre-commit (MUST block)

| Test | Input | Expected |
|------|-------|----------|
| Branch protection | Commit on `main` | ❌ BLOCKED |
| Pause file | `.tao-pause` exists | ❌ BLOCKED |
| Destructive scan | File contains `rm -rf /` | ❌ BLOCKED |
| Destructive scan | File contains `DROP DATABASE` | ❌ BLOCKED |
| Lint failure | Lint command returns non-zero | ❌ BLOCKED |
| ABEX | File contains `eval($_GET` | ❌ BLOCKED |
| Timestamp stale | CONTEXT.md >30min old | ❌ BLOCKED (or warned) |
| Clean commit | All rules pass | ✅ PASS |

### L0 — Commit-msg (MUST block)

| Test | Input | Expected |
|------|-------|----------|
| Wrong format | "fixed stuff" | ❌ BLOCKED |
| Correct format | "fix(fase-01): T05 — expand context hook" | ✅ PASS |
| Missing task ref | "fix(fase-01): description" | ⚠️ WARN |

### L0 — Pre-push (MUST block)

| Test | Input | Expected |
|------|-------|----------|
| Push to main | `git push origin main` | ❌ BLOCKED |
| Force push | `git push --force` | ❌ BLOCKED |
| Push to dev | `git push origin dev` | ✅ PASS |

### L1 — Enforcement hook (SHOULD warn)

| Test | Input | Expected |
|------|-------|----------|
| Edit without read | Agent edits file.php (not in read list) | ⚠️ WARNING |
| Edit after read | Agent reads then edits file.php | ✅ SILENT |

### L1 — Context hook (SHOULD inject)

| Test | Input | Expected |
|------|-------|----------|
| Session start | Agent starts session | Context dashboard injected |
| Phase detected | tao.config.json has active phase | Phase info in dashboard |
| No config | tao.config.json missing | Graceful fallback message |

### L1 — ABEX hook (SHOULD warn)

| Test | Input | Expected |
|------|-------|----------|
| SQL injection | File contains string concat in query | ⚠️ WARNING |
| Safe query | File uses parameterized query | ✅ SILENT |

## Execution Method

For each test case:
1. Set up the condition (create test file, modify config, etc.)
2. Trigger the hook (attempt commit, start session, etc.)
3. Verify expected outcome (blocked/warned/passed)
4. Clean up test artifacts

Record results in a test matrix: PASS/FAIL for each case.

## Acceptance Criteria

- [ ] All L0 test cases executed and documented
- [ ] All L1 test cases executed and documented
- [ ] Zero false negatives (hook should block but doesn't)
- [ ] False positive rate acceptable (<5%)
- [ ] Test matrix recorded in STATUS.md or separate report
- [ ] Any failures tracked as follow-up issues
