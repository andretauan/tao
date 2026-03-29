# PLAN.md — Phase 01: Vibe Coder Promise Fulfillment

**Date:** 2026-03-29
**Phase:** 01
**Objective:** Fix every gap between TAO's promises and reality for non-programmer users.

---

## Overview

TAO v1.0 was built by and for developers. It works when conditions are pre-met (phase exists, lint configured, hooks active). But it promises "you don't need to know programming" — and that promise fails on first contact.

This phase fixes 16 specific issues across install, agents, hooks, scripts, and docs. Every change is bilingual (EN + PT-BR). All work on `dev` branch, push to `main` only after full verification.

Source: `brainstorm/BRIEF.md` (maturity 7/7, 10 IBIS decisions)

---

## Task Groups

### Group P0 — First-Run Experience (Blocking)
Without these, a vibe coder cannot use TAO at all.

- **T01** — Onboarding flow in Execute-Tao agents — Detect `novo_projeto`/`new_project`, add onboarding STEP -1 with single-question exception, invoke Wu for brainstorm (BRIEF D1, D1 exception to golden rule)
- **T02** — install.sh: auto-detect lint stack — Replace Q5 with auto-detection from project files, confirm with user, warn if `none` (BRIEF D2)
- **T03** — install.sh: auto-create phase 01 + .vscode/settings.json + simplify output — Create first phase directory, enable hooks automatically, rewrite "Next steps" message (BRIEF D1, D6)
- **T04** — lint-hook.sh: verify tool existence + warn when empty — Check `command -v` before running lint, warn once per extension when lint_commands empty (BRIEF D3)

### Group P1 — Contradictions & Consistency
Agent confusion from conflicting instructions.

- **T05** — Fix auto_push contradiction in RULES.md template — Change "always push" to "push according to git.auto_push" (BRIEF D4)
- **T06** — Fix CONTEXT.md templates — Replace `[XX — Nome da Fase]` with `01 — Awaiting Definition` in both languages (BRIEF D1)
- **T07** — Add novo_projeto exception to RULES.md — Add explicit exception to "never ask" rule for first-run onboarding (BRIEF D1)

### Group P2 — Enforcement & Quality Gates
Making claimed quality gates actually work.

- **T08** — Create abex-gate.sh — New script detecting SQL injection, eval, innerHTML, hardcoded secrets, missing error handling (BRIEF D5)
- **T09** — enforcement-hook.sh: strengthen R5 — Change warning to strong block instruction with "STOP. Read the file NOW." (BRIEF D5)
- **T10** — context-hook.sh: enhanced dashboard — Mini-dashboard with phase, tasks done/pending, lint status, hooks status (BRIEF D7)

### Group P3 — Documentation & Claims
Fixing what the README promises.

- **T11** — README (EN + PT-BR): qualify claims + add Troubleshooting — Fix "60% savings" context, qualify "no programming needed", add troubleshooting table, document context window limitation (BRIEF D9)
- **T12** — GETTING-STARTED.md: add Quick Path — 5-step quick start for vibe coders at top of doc (BRIEF D1)
- **T13** — ECONOMICS.md: full-cycle cost documentation — Add brainstorm + planning costs to the model (BRIEF D9)
- **T14** — Wu agents (EN + PT-BR): add rate-limit message — Clear message when Opus unavailable, explain what to do (BRIEF D8)

### Group P4 — Verification
Prove everything works.

- **T15** — Bilingual smoke test: fresh install + first execution — Install on clean dir in EN and PT-BR, verify onboarding flow, lint detection, hooks, phase creation, dashboard (BRIEF D10)
- **T16** — Regression check: existing v1.0 behavior preserved — Verify install.sh on existing tao-test project doesn't break, existing brainstorm docs still valid (BRIEF D10)

---

## Execution Order

```
P0 (blocking):     T02 → T03 → T04 → T01
P1 (consistency):  T05 → T06 → T07
P2 (enforcement):  T08 → T09 → T10
P3 (documentation): T11 → T12 → T13 → T14
P4 (verification): T15 → T16
```

**Notes on order:**
- T02 before T03: lint detection must be in install.sh before phase creation is added
- T04 before T01: lint-hook must handle missing tools before onboarding creates projects
- T01 depends on T03 (phase 01 exists) and T06 (CONTEXT.md template fixed)
- T15 depends on ALL previous tasks
- T08 is independent — can be parallelized with P0/P1

---

## Phase Completion Criteria

- [ ] All P0 tasks completed (T01-T04)
- [ ] All P1 tasks completed (T05-T07)
- [ ] All P2 tasks completed (T08-T10)
- [ ] All P3 tasks completed (T11-T14)
- [ ] All P4 tasks completed (T15-T16)
- [ ] validate-plan.sh passes
- [ ] validate-execution.sh passes
- [ ] forensic-audit.sh passes
- [ ] faudit.sh passes
- [ ] .github/tao/CONTEXT.md updated (for tao-test)
- [ ] .github/tao/CHANGELOG.md updated (for tao-test)
- [ ] git status clean on dev branch
- [ ] All changes tested via fresh install

---

## Dependencies / Prerequisites

- TAO repo on `dev` branch (confirmed: current state)
- Clean git status (confirmed: no pending changes)
- tao-test available for reinstall verification
- Python 3 available for script testing
