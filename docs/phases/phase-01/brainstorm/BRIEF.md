# BRIEF.md — Phase 01: Vibe Coder Promise Fulfillment

> Compression of DISCOVERY.md (7 topics) + DECISIONS.md (10 decisions).
> Created: 2026-03-29 — @Brainstorm-Wu (Opus)
> Source: Full audit of TAO v1.0 against non-programmer persona.

## Maturity: 7/7
- [x] Problem/objective clear — TAO promises "no coding needed" but requires CLI, Python, Git, JSON editing
- [x] ≥2 alternatives explored — 10 IBIS decisions, each with ≥2 positions
- [x] Trade-offs evaluated — all 10 decisions have pros/cons for each position
- [x] Decisions have invalidation conditions — all 10 have "Invalidaria se"
- [x] Reference docs consulted — install.sh, all agents (EN + PT-BR), all hooks, all scripts, all READMEs
- [x] Scope defined — TAO repo changes only, test via reinstall, dev branch
- [x] Codebase patterns integrated — bash + python3, safe_copy idiom, json merge, color output pattern

---

## §1 Problem Statement

TAO v1.0 promises "you don't need to know programming" and "say execute, TAO does the rest." Audit reveals these promises FAIL for a vibe coder:

1. **First execution crashes** — no phase exists after install, CONTEXT.md has invalid placeholders
2. **Lint gates are empty** — choosing `none` (the likely default) disables all syntax checking
3. **Hooks are off by default** — without `chat.useCustomAgentHooks`, enforcement layer is gone
4. **Agent contradictions** — "help the user plan" vs "NEVER ask questions"
5. **Economic claims misleading** — "60% savings" ignores brainstorm/planning costs
6. **ABEX is honor system** — claimed as "code-enforced" but is prompt-only
7. **Missing lint tools fail silently** — configuring `.ts` without npm → silent pass

**Goal:** Fix ALL of the above so that TAO delivers what it promises.

---

## §2 Decisions Summary (10 IBIS decisions)

| # | What | Decision | Origin |
|---|------|----------|--------|
| D1 | First-run experience | Onboarding mode in Tao agent + install creates phase 01 | DISCOVERY §2 |
| D2 | Lint stack selection | Auto-detect from project files with confirmation | DISCOVERY §1 |
| D3 | Missing lint tools | Check at hook runtime, clear error message | DISCOVERY §1 |
| D4 | auto_push contradiction | Config is truth, RULES.md references config | DISCOVERY §5 |
| D5 | ABEX enforcement | Lightweight regex detection script (abex-gate.sh) | DISCOVERY §3 |
| D6 | Hooks activation | install.sh creates .vscode/settings.json | DISCOVERY §6 |
| D7 | Context dashboard | Mini-dashboard with phase/tasks/lint/hook status | DISCOVERY §6 |
| D8 | Wu rate-limit | Clear error message, no model fallback | DISCOVERY §7 |
| D9 | Economic claims | Qualify 60% to execution-only, document full-cycle | DISCOVERY §4 |
| D10 | Phase scope | TAO repo only, test via reinstall | DISCOVERY §1 |

---

## §3 Scope

### IN (this phase delivers)
- Onboarding flow for `novo_projeto` / `new_project` in BOTH Executar-Tao and Execute-Tao agents
- install.sh: auto-detect lint, create phase 01, create .vscode/settings.json, simplify output
- lint-hook.sh: verify tool existence, warn when lint_commands empty
- enforcement-hook.sh: stronger R5 enforcement
- context-hook.sh: enhanced dashboard
- RULES.md (EN template managed): fix auto_push contradiction, add novo_projeto exception
- CONTEXT.md template (EN + PT-BR): fix invalid placeholders
- abex-gate.sh: new lightweight security/quality script
- README.md + README.pt-br.md: qualify claims, add troubleshooting
- GETTING-STARTED.md: add Quick Path section
- ECONOMICS.md: document full-cycle costs
- Wu agent (EN + PT-BR): add rate-limit message
- Bilingual smoke test

### NOT in scope (deferred)
- VS Code extension / GUI wizard
- AST-based static analysis
- Wu Sonnet fallback model
- Runtime lint detection (agent auto-detects file type)
- tao.sh copy to installed projects

---

## §4 Execution Constraints

- **Branch:** `dev` only. Push to `main` only after all tests pass.
- **Bilingual:** Every agent/template change must be applied in BOTH EN and PT-BR.
- **Testing:** After all tasks, run install.sh on a clean directory and verify full flow.
- **Commit convention:** `fix(phase-01): TNN — description` or `feat(phase-01): TNN — description`
