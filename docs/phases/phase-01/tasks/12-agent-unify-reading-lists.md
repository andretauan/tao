# Task T12 — Unify Agent Reading Lists + Compliance (12 files)

**Phase:** 01 — Enforcement Architecture
**Complexity:** High
**Executor:** Architect (Opus)
**Priority:** P2-TEXT (L2)
**Depends on:** T09 (canonical compliance format defined)

---

## Objective

Ensure ALL 6 agents (× 2 languages = 12 files) have consistent reading lists and compliance check sections. Fix specific gaps per agent.

## Gaps Fixed

- G20: Shen + Investigar-Shen: no compliance check section
- G21: Di missing RULES.md in reading list
- G22: Qi no real guard for main push
- G23: Wu RESUME mode says "pergunta" (contradicts golden rule)
- G27: Mandatory reading lists inconsistent

## Files to Read (all 12 agent files)

PT-BR:
- `agents/pt-br/Executar-Tao.agent.md`
- `agents/pt-br/Shen.agent.md`
- `agents/pt-br/Investigar-Shen.agent.md`
- `agents/pt-br/Di.agent.md`
- `agents/pt-br/Qi.agent.md`
- `agents/pt-br/Brainstorm-Wu.agent.md`

EN:
- `agents/en/Execute-Tao.agent.md`
- `agents/en/Shen.agent.md`
- `agents/en/Investigate-Shen.agent.md`
- `agents/en/Di.agent.md`
- `agents/en/Qi.agent.md`
- `agents/en/Brainstorm-Wu.agent.md`

Also read:
- `templates/en/RULES.md` — canonical reading list reference

## Changes Per Agent

### Executar-Tao / Execute-Tao (reference — already good)
- Add note above compliance block: "Canonical format: see .github/tao/RULES.md §R0"
- No other changes needed (already has 5-item reading list + compliance)

### Shen (subagent)
- ADD compliance check section (same 7-field format, reference RULES.md §R0)
- ADD reading list: CLAUDE.md, RULES.md, CONTEXT.md, tao.config.json
- Note: Shen is context-isolated, needs its own rules

### Investigar-Shen
- ADD to reading list: `.github/tao/tao.config.json`, `.github/tao/CHANGELOG.md`
- ADD compliance check section (reference RULES.md §R0)
- Currently only reads: CLAUDE.md, CONTEXT.md, INDEX.md (missing config + changelog)

### Di
- ADD to reading list: `.github/tao/RULES.md`, `.github/tao/CONTEXT.md`
- Currently only reads: CLAUDE.md + project config

### Qi
- ADD to reading list: `.github/tao/RULES.md`
- STRENGTHEN merge main guard: "NEVER execute merge to main without: (1) explicit user order, (2) all validate-*.sh scripts passing, (3) git status clean"
- Currently: text says "SOMENTE com autorização expressa" but no checklist

### Brainstorm-Wu
- FIX RESUME mode: change "pergunta: Continuar divergindo, ou pronto para convergir?" to autonomous decision: "Evaluate maturity score. If < 5/7 → continue DIVERGE. If ≥ 5/7 and open issues → CONVERGE. If ≥ 5/7 and resolved → SYNTHESIZE."
- No compliance check needed (Wu doesn't modify code)

## Acceptance Criteria

- [ ] All 12 agent files updated
- [ ] Shen has compliance check section
- [ ] Investigar-Shen has 5-item reading list + compliance
- [ ] Di reads RULES.md + CONTEXT.md
- [ ] Qi has 3-point merge guard checklist
- [ ] Wu RESUME mode is autonomous (no question)
- [ ] All compliance blocks reference RULES.md §R0
