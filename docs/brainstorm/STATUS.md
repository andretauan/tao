# STATUS — TAO v0.1 Build

> Executor reads this file to know which task to run.
> Mark ✅ when done. Mark ❌ if blocked.
> **Last update:** 2026-03-27 10:08
>
> **Execution order:**
> S1: T08→T01→T02→T03→T04→T05→T06→T07
> S2: T09→T10→T11→T12→T17 | T13→T14→T15→T16
> S3: T18→T19→T20→T21→T22→T23 | T24→T25→T26→T27→T28→T29
> S4: T30→T31→T32
> S5: T33→T34→T35
> S6: T36→T37→T38→T39→T40→T41→T42
> S7: T43→T44→T45→T46→T47→T48

## SPRINT 1 — Infrastructure (P0)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T08 | .gitignore + LICENSE + scaffold | ⏳ | Sonnet | Low | First task — creates directory structure |
| T01 | tao.config.json schema + example | ⏳ | Sonnet | Medium | Defines ALL configurable values |
| T02 | install.sh interactive | ⏳ | Opus | High | 5 questions, generates config, copies templates |
| T03 | tao.sh monitor | ⏳ | Sonnet | Medium | Adapt from gsd.sh (347 lines) |
| T04 | hooks/install-hooks.sh | ⏳ | Sonnet | Low | Fixes B3 CRITICAL |
| T05 | hooks/pre-commit.sh orchestrator | ⏳ | Sonnet | Medium | Modular pipeline |
| T06 | hooks/lint-hook.sh generic | ⏳ | Sonnet | Medium | PostToolUse, reads tao.config.json |
| T07 | hooks/context-hook.sh generic | ⏳ | Sonnet | Low | SessionStart, reads tao.config.json |

## SPRINT 2 — Core Templates (P0)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T09 | templates/en/CLAUDE.md | ⏳ | Opus | High | Zero [SUBSTITUIR], ABEX, generic rules |
| T10 | templates/en/CONTEXT.md | ⏳ | Sonnet | Low | Onboarding mode |
| T11 | templates/en/CHANGELOG.md | ⏳ | Sonnet | Low | — |
| T12 | templates/en/copilot-instructions.md | ⏳ | Sonnet | Medium | Minimal pointer to CLAUDE.md |
| T13 | templates/pt-br/CLAUDE.md | ⏳ | Opus | High | Cultural adaptation of T09 |
| T14 | templates/pt-br/CONTEXT.md | ⏳ | Sonnet | Low | — |
| T15 | templates/pt-br/CHANGELOG.md | ⏳ | Sonnet | Low | — |
| T16 | templates/pt-br/copilot-instructions.md | ⏳ | Sonnet | Medium | — |
| T17 | templates/shared/hooks.json | ⏳ | Sonnet | Low | Language-neutral |

## SPRINT 3 — Taoist Agents (P0)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T18 | agents/en/Tao.agent.md | ⏳ | Opus | High | Orchestrator, loop, routing matrix |
| T19 | agents/en/Wu.agent.md | ⏳ | Opus | High | NEW — brainstorm, IBIS, 5 modes |
| T20 | agents/en/Shen.agent.md | ⏳ | Sonnet | Medium | Complex worker subagent |
| T21 | agents/en/Shen-Architect.agent.md | ⏳ | Sonnet | Medium | User-invocable architect |
| T22 | agents/en/Di.agent.md | ⏳ | Sonnet | Low | DBA subagent |
| T23 | agents/en/Qi.agent.md | ⏳ | Sonnet | Low | Deploy subagent |
| T24 | agents/pt-br/Tao.agent.md | ⏳ | Opus | High | Cultural adaptation of T18 |
| T25 | agents/pt-br/Wu.agent.md | ⏳ | Opus | High | Cultural adaptation of T19 |
| T26 | agents/pt-br/Shen.agent.md | ⏳ | Sonnet | Medium | — |
| T27 | agents/pt-br/Shen-Arquiteto.agent.md | ⏳ | Sonnet | Medium | — |
| T28 | agents/pt-br/Di.agent.md | ⏳ | Sonnet | Low | — |
| T29 | agents/pt-br/Qi.agent.md | ⏳ | Sonnet | Low | — |

## SPRINT 4 — Phase Templates (P1)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T30 | phases/en/ (4 templates) | ⏳ | Sonnet | Medium | PLAN, STATUS, task, progress |
| T31 | phases/pt-br/ (4 templates) | ⏳ | Sonnet | Medium | PLAN, STATUS, tarefa, progress |
| T32 | phases/shared/ (3 brainstorm) | ⏳ | Sonnet | Medium | DISCOVERY, DECISIONS, BRIEF |

## SPRINT 5 — Utility Scripts (P1)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T33 | update-models.sh | ⏳ | Sonnet | Medium | Updates models in .agent.md files |
| T34 | scripts/i18n-diff.sh | ⏳ | Sonnet | Medium | Anti-drift EN vs PT-BR |
| T35 | scripts/new-phase.sh | ⏳ | Sonnet | Low | Creates phase dir with templates |

## SPRINT 6 — Documentation (P1)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T36 | README.md (EN) | ⏳ | Opus | High | Hero, pitch, quickstart, features |
| T37 | README.pt-br.md | ⏳ | Opus | High | Cultural adaptation |
| T38 | docs/GETTING-STARTED.md | ⏳ | Opus | High | Accordion L1→L5 |
| T39 | docs/ARCHITECTURE.md | ⏳ | Sonnet | Medium | Adapt from GSD (585 lines) |
| T40 | docs/ECONOMICS.md | ⏳ | Sonnet | Medium | Model costs, routing |
| T41 | docs/GUARDRAILS.md | ⏳ | Sonnet | Medium | 7 layers, 23 gates |
| T42 | CONTRIBUTING.md | ⏳ | Sonnet | Low | EN + PT-BR section |

## SPRINT 7 — Verification (P2)

| # | Task | Status | Executor | Complexity | Notes |
|---|---|---|---|---|---|
| T43 | Smoke: install.sh e2e | ⏳ | Sonnet | Medium | Fresh dir, answer questions, verify |
| T44 | Smoke: tao.sh | ⏳ | Sonnet | Medium | status/report/dry-run/pause |
| T45 | Smoke: hooks | ⏳ | Sonnet | Medium | pre-commit blocks, context injects |
| T46 | Consistency check | ⏳ | Opus | High | Zero [SUBSTITUIR], no duplication |
| T47 | i18n-diff validation | ⏳ | Sonnet | Low | Run diff, verify 0 drift |
| T48 | README UX review | ⏳ | Opus | Medium | 30s comprehension test |

---

## SUMMARY — 2026-03-27 10:08

| Sprint | Done | Pending | Tasks |
|---|---|---|---|
| S1 — Infrastructure | 0/8 | 8 | T01-T08 |
| S2 — Templates | 0/9 | 9 | T09-T17 |
| S3 — Agents | 0/12 | 12 | T18-T29 |
| S4 — Phase Templates | 0/3 | 3 | T30-T32 |
| S5 — Scripts | 0/3 | 3 | T33-T35 |
| S6 — Documentation | 0/7 | 7 | T36-T42 |
| S7 — Verification | 0/6 | 6 | T43-T48 |
| **TOTAL** | **0/48** | **48** | — |

**Executor breakdown:** Opus: 14 tasks | Sonnet: 34 tasks
