# Task T07 — RULES.md: Add novo_projeto Exception

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P1

---

## Objective

Add an explicit exception to the "NEVER ask the user questions" rule in RULES.md and agent instructions for the `novo_projeto` / `new_project` scenario, where the agent MUST ask one question to understand the project.

## Context

Execute-Tao agents have a "Golden Rule: TOTAL AUTONOMY — NEVER ask the user questions". But the `novo_projeto`/`new_project` skill says "Ask the user to describe their project". This is a direct contradiction. The fix is simple: add a single explicit exception to the Golden Rule.

## Files to Read (BEFORE editing)

- `templates/en/RULES.md` — find the autonomy rules section
- `templates/pt-br/RULES.md` — same in Portuguese
- `agents/en/Execute-Tao.agent.md` — find the Golden Rule
- `agents/pt-br/Executar-Tao.agent.md` — same in Portuguese

## Files to Create/Edit

- `templates/en/RULES.md` — add novo_projeto exception
- `templates/pt-br/RULES.md` — add novo_projeto exception
- `agents/en/Execute-Tao.agent.md` — add exception to Golden Rule
- `agents/pt-br/Executar-Tao.agent.md` — add exception to Golden Rule

## Implementation Steps

1. Read all 4 files
2. In RULES.md templates, find the autonomy/question prohibition rule and add:
   - EN: "**Exception:** During `new_project` (STEP -1), the agent MUST ask the user to describe their project. This is the ONLY permitted question."
   - PT-BR: "**Exceção:** Durante `novo_projeto` (STEP -1), o agente DEVE perguntar ao usuário para descrever seu projeto. Esta é a ÚNICA pergunta permitida."
3. In Execute-Tao agents, find the Golden Rule and add the same exception
4. Verify the onboarding flow (T01) references this exception

## Acceptance Criteria

- [ ] EN RULES.md has explicit novo_projeto exception
- [ ] PT-BR RULES.md has explicit novo_projeto exception
- [ ] EN Execute-Tao agent has exception to Golden Rule
- [ ] PT-BR Executar-Tao agent has exception to Golden Rule
- [ ] Exception is narrow: ONLY for novo_projeto, ONLY one question
- [ ] No other changes to the autonomy rules

## Notes / Gotchas

- The exception must be NARROW — only one question, only during novo_projeto
- Don't weaken the autonomy rule in general — it's important for ongoing work
- This task coordinates with T01 (onboarding flow) but can be done independently
- Both RULES.md files are TEMPLATES — existing installations won't update automatically

---

**Expected commit:** `fix(phase-01): T07 — RULES.md adds novo_projeto exception to autonomy rule`
