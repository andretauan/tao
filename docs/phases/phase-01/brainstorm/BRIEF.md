# BRIEF.md — Phase 01: Vibe Coder Promise Fulfillment + Enforcement Architecture

> Compression of DISCOVERY.md (8 topics) + DECISIONS.md (12 decisions).
> Created: 2026-03-29 — @Brainstorm-Wu (Opus)
> Updated: 2025-07-15 — Expanded with enforcement architecture (40 gaps, 24 tasks)
> Source: Full audit of TAO v1.0 against non-programmer persona + enforcement layer analysis.

## Maturity: 7/7
- [x] Problem/objective clear — TAO promises "no coding needed" but requires CLI, Python, Git, JSON editing
- [x] ≥2 alternatives explored — 10 IBIS decisions, each with ≥2 positions
- [x] Trade-offs evaluated — all 10 decisions have pros/cons for each position
- [x] Decisions have invalidation conditions — all 10 have "Invalidaria se"
- [x] Reference docs consulted — install.sh, all agents (EN + PT-BR), all hooks, all scripts, all READMEs, tao.config.json.example
- [x] Scope defined — TAO repo changes only, test via reinstall, dev branch, 24 tasks across 6 groups
- [x] Codebase patterns integrated — bash + python3, safe_copy idiom, json merge, color output pattern, hook architecture

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
8. **Text rules fail ~30% of the time** — scientific audit proved LLMs skip compliance checks, fabricate "SIM" responses, ignore reading lists

**Fundamental insight:** Text rules in agent instructions are probabilistic (~70%). The ONLY way to guarantee compliance is to move enforcement to code (pre-commit hooks = 100%, PostToolUse hooks = ~95%).

**Goal:** Fix ALL of the above with a 3-layer enforcement architecture (L0/L1/L2) targeting ~98% compliance.

---

## §2 Decisions Summary (12 IBIS decisions)

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
| D11 | Enforcement architecture | Layered defense: L0 (pre-commit 100%) + L1 (hooks ~95%) + L2 (text ~80%) | DISCOVERY §8 |
| D12 | Compliance data | Hybrid: hooks inject objective data, agent reports subjective | DISCOVERY §8 |

---

## §3 Scope

### IN (this phase delivers — 24 tasks across 6 groups)

**P0-HARD — L0 Deterministic Enforcement (T01-T04)**
- pre-commit.sh: expand with destructive scan, pause check, ABEX, timestamp validation
- commit-msg.sh: NEW — validate commit message format (LOCK 6)
- pre-push.sh: NEW — block push main, block force push (LOCK 2)
- abex-gate.sh: NEW — regex security scanner for TOP 5 vulnerability patterns

**P1-HOOKS — L1 Semi-Deterministic Enforcement (T05-T08)**
- context-hook.sh: expand with real timestamp, skills injection, compliance pre-computed data
- enforcement-hook.sh: expand with terminal intercept, stronger R5, compliance config reading
- abex-hook.sh: NEW — PostToolUse security scan
- compliance config wiring: connect tao.config.json compliance flags to ALL hooks

**P2-TEXT — L2 Text Instruction Fixes (T09-T13)**
- Single canonical compliance check with prescriptive SEQUENCE (DRY across 12 sources)
- RULES.md: fix auto_push contradiction, novo_projeto exception, ABEX unification
- CONTEXT.md template: fix invalid placeholders and typos
- All 12 agent files: unify reading lists + compliance format
- INDEX.md: complete all 14 skill descriptions + R3 matching algorithm

**P3-INSTALL — Installation Fixes (T14-T17)**
- install.sh: auto-detect lint stack (replace Q5)
- install.sh: create phase-01, .vscode/settings.json, .gitignore, actionable output
- lint-hook.sh: verify tool existence, warn when empty
- Onboarding flow in Execute-Tao agents (EN+PT-BR)

**P4-DOCS — Documentation Fixes (T18-T21)**
- README qualify claims + troubleshooting (EN+PT-BR)
- GETTING-STARTED.md Quick Path
- ECONOMICS.md full-cycle costs
- Wu agents rate-limit message (EN+PT-BR)

**P5-VERIFY — Verification (T22-T24)**
- Bilingual smoke test
- Regression check on existing projects
- Enforcement test L0/L1 hooks

### NOT in scope (deferred)
- VS Code extension / GUI wizard
- AST-based static analysis
- Wu Sonnet fallback model
- Runtime lint detection (agent auto-detects file type)
- tao.sh copy to installed projects
- Agent action logging / forensic audit trail
- Full 100% enforcement (irreducibly ~2% subjective)

---

## §4 Execution Constraints

- **Branch:** `dev` only. Push to `main` only after all tests pass.
- **Bilingual:** Every agent/template change must be applied in BOTH EN and PT-BR.
- **Testing:** After all tasks, run install.sh on a clean directory and verify full flow.
- **Commit convention:** `fix(phase-01): TNN — description` or `feat(phase-01): TNN — description`
