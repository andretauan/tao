# PLAN.md — Phase 01: TAO Enforcement Architecture + Vibe Coder Promise Fulfillment

**Date:** 2026-03-30 — Rewritten with enforcement architecture
**Phase:** 01
**Objective:** Fix every gap between TAO's promises and reality. Move critical rules from text (L2) to deterministic enforcement (L0/L1).

---

## Architecture: Defense in Depth

TAO v1.0 relies ~90% on text instructions (L2). LLMs treat text as probabilistic, not deterministic. Proof: compliance check failed on first execution (6/7 fields wrong).

This plan reorganizes enforcement into 3 layers:

| Layer | Type | Reliability | Mechanism |
|-------|------|------------|-----------|
| **L0 — Hard Gates** | Deterministic | **100%** | pre-commit, commit-msg, pre-push hooks — exit 1 = blocked |
| **L1 — Real-Time Hooks** | Injected context | **~95%** | PostToolUse/SessionStart — inject data + warnings |
| **L2 — Text** | Probabilistic | **~70%** | Agent instructions — improved, prescriptive, DRY |

**Target:** Move from ~70% compliance to ~98%.

Source: `brainstorm/BRIEF.md` (maturity 7/7, 12 IBIS decisions) + scientific audit (40 gaps mapped)

---

## Gap Map (40 gaps → 24 tasks)

| Gap Range | Category | Count | Covered by |
|-----------|----------|-------|------------|
| G01-G07 | L0 — Hard gates missing | 7 | T01-T04 |
| G08-G14 | L1 — Hooks missing | 7 | T05-T08 |
| G15-G27 | L2 — Text inconsistencies | 13 | T09-T13 |
| G28-G33 | Install experience | 6 | T14-T17 |
| G34-G38 | Documentation | 5 | T18-T21 |
| G39-G40 | New findings | 2 | T03, T15 |

---

## Task Groups

### Group P0-HARD — Deterministic Enforcement Gates (L0)
These make violations IMPOSSIBLE at commit/push time. The model MUST fix errors to proceed.

- **T01** — pre-commit.sh: expand with destructive pattern scan (LOCK 3), .tao-pause check (LOCK 5), ABEX basic patterns, timestamp validation for CHANGELOG.md — *Gaps: G03, G04, G05, G06; Origin: BRIEF §1, D5, D11*
- **T02** — Create commit-msg.sh: validate `tipo(escopo): desc` format, max 72 chars. Update install-hooks.sh — *Gaps: G01; Origin: D11*
- **T03** — Create pre-push.sh: block push to main/master, block --force flag. Read main_branch from tao.config.json. Update install-hooks.sh to install commit-msg + pre-push hooks — *Gaps: G02, G07, G22, G39; Origin: BRIEF §1, D4, D11*
- **T04** — Create abex-gate.sh: regex-based security scanner detecting SQL injection, eval, innerHTML, hardcoded secrets. Exit 1 = BLOCK. Called by T01 and T07 — *Gaps: G06; Origin: BRIEF §1, D5*

### Group P1-HOOKS — Real-Time Enforcement (L1)
These give the model CORRECT data and realtime feedback on EVERY action.

- **T05** — context-hook.sh: inject real timestamp, skills list from INDEX.md, lint status, hook status, pre-computed compliance data. Agent receives FACTS, not templates to guess — *Gaps: G08, G09, G10; Origin: D7, D12*
- **T06** — enforcement-hook.sh: add terminal command interception (detect push main, --force, --no-verify, rm -rf), strengthen R5 to BLOCK tone, read compliance.* config — *Gaps: G07, G11, G12, G14; Origin: D5, D11*
- **T07** — Create abex-hook.sh: PostToolUse hook running abex-gate.sh on each edited file. Add to hooks.json — *Gaps: G13; Origin: D5, D11*
- **T08** — Wire compliance.* config into all hooks: context-hook reads require_context_read, enforcement reads require_skill_check, abex reads abex_enabled. Disabled = skip gracefully — *Gaps: G14; Origin: D11*

### Group P2-TEXT — Instruction Consistency (L2)
Fix contradictions and ambiguity. Make text prescriptive (SEQUENCE), not descriptive.

- **T09** — Canonical compliance check: define ONE 7-field format in RULES.md as prescriptive SEQUENCE (execute date → read CONTEXT → read CHANGELOG → read config → check skills → THEN emit block). All other sources reference RULES.md. DRY — *Gaps: G15, G25, G26, G27; Origin: D11, D12*
- **T10** — Fix RULES.md (EN+PT-BR): change "always push" → "push according to git.auto_push", add novo_projeto exception to autonomy rules, unify ABEX definition — *Gaps: G16, G19, G25; Origin: D1, D4*
- **T11** — Fix CONTEXT.md templates (EN+PT-BR): replace `[XX — Nome da Fase]` with `01 — Pending Definition`, fix "Open Pendencies" → "Open Issues" (EN) — *Gaps: G17, G18; Origin: D1*
- **T12** — Unify ALL agent reading lists + compliance (6 agents × 2 languages = 12 files): add compliance check to Shen+Investigar-Shen, add RULES.md to Di, add RULES.md to Qi + strengthen push guard, fix Wu RESUME contradiction — *Gaps: G20, G21, G22, G23, G27; Origin: D11*
- **T13** — Fix INDEX.md (EN+PT-BR): complete all 14 skill descriptions, document R3 matching algorithm — *Gaps: G24, G26; Origin: D11*

### Group P3-INSTALL — First-Run Experience
Make TAO work for vibe coders on first contact.

- **T14** — install.sh: auto-detect lint stack from project files (replace Q5), confirm with user, fallback to `none` with warning — *Gaps: G28; Origin: D2*
- **T15** — install.sh: create phase-01 via new-phase.sh, create .vscode/settings.json with hooks toggle, add .tao-session/ to .gitignore, simplify output message — *Gaps: G29, G30, G31, G40; Origin: D1, D6*
- **T16** — lint-hook.sh: check `command -v` before running lint tool, warn once per session if lint_commands empty for extension — *Gaps: G33; Origin: D3*
- **T17** — Onboarding flow in Execute-Tao + Executar-Tao agents (EN+PT-BR): detect novo_projeto status, STEP -1 with single question exception, invoke Wu — *Gaps: G38; Origin: D1*

### Group P4-DOCS — Documentation
Align promises with reality.

- **T18** — README (EN+PT-BR): qualify "60% savings" to execution-only, qualify "no programming needed", add troubleshooting table, document context window limitation — *Gaps: G34, G35; Origin: D9*
- **T19** — GETTING-STARTED.md: add 5-step Quick Path section at top for vibe coders — *Gaps: G36; Origin: D1*
- **T20** — ECONOMICS.md: add brainstorm + planning costs, compare full-cycle TAO vs pure vibe coding — *Gaps: G34; Origin: D9*
- **T21** — Wu agents (EN+PT-BR): add clear rate-limit message when Opus unavailable — *Gaps: G37; Origin: D8*

### Group P5-VERIFY — Verification
Prove everything works.

- **T22** — Bilingual smoke test: fresh install on clean dir (EN + PT-BR), verify phase creation, lint detection, hooks active, dashboard, onboarding — *Origin: D10*
- **T23** — Regression check: install.sh on existing tao-test project doesn't break, existing brainstorm docs still valid — *Origin: D10*
- **T24** — Enforcement test: verify pre-commit blocks bad message/destructive code/paused state, pre-push blocks main/force, enforcement-hook catches terminal dangers, context-hook injects real data — *Origin: D11*

---

## Execution Order

```
P0-HARD (L0):    T04 → T01 → T02 → T03
P1-HOOKS (L1):   T05 → T06 → T07 → T08
P2-TEXT (L2):    T09 → T10 → T11 → T12 → T13
P3-INSTALL:      T14 → T15 → T16 → T17
P4-DOCS:         T18 → T19 → T20 → T21
P5-VERIFY:       T22 → T23 → T24
```

**Dependencies:**
- T04 FIRST: abex-gate.sh is dependency of T01 (pre-commit) and T07 (hook)
- P0 before P1: hard gates before hooks (hooks reference enforcement logic)
- T09 before T10-T13: canonical compliance is referenced by all agent fixes
- T14 before T15: lint detection before phase creation
- T17 last in P3: onboarding depends on all other install fixes
- P4 is independent of P0-P3: documentation can be parallelized
- P5 last: verification covers everything

**Parallelization:**
- P4 can run in parallel with P0-P3 (documentation vs code changes)
- T02 and T03 within P0 are independent of each other
- Within P2, T10+T11 are independent of each other

---

## Phase Completion Criteria

- [ ] All P0-HARD tasks completed (T01-T04) — hard gates working
- [ ] All P1-HOOKS tasks completed (T05-T08) — real-time enforcement active
- [ ] All P2-TEXT tasks completed (T09-T13) — instructions consistent
- [ ] All P3-INSTALL tasks completed (T14-T17) — fresh install works
- [ ] All P4-DOCS tasks completed (T18-T21) — claims honest
- [ ] All P5-VERIFY tasks completed (T22-T24) — everything proven
- [ ] validate-plan.sh passes
- [ ] validate-execution.sh passes
- [ ] forensic-audit.sh passes
- [ ] faudit.sh passes
- [ ] .github/tao/CONTEXT.md updated (for tao-test)
- [ ] .github/tao/CHANGELOG.md updated (for tao-test)
- [ ] git status clean on dev branch
- [ ] All changes tested via fresh install
- [ ] Enforcement test passes (T24) — L0/L1 hooks block violations

---

## Dependencies / Prerequisites

- TAO repo on `dev` branch (confirmed)
- Clean git status
- tao-test available for reinstall verification
- Python 3 available for script testing
- Both EN and PT-BR templates exist in TAO repo
