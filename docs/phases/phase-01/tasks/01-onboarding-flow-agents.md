# Task T01 — Onboarding Flow in Execute-Tao Agents (EN + PT-BR)

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** High
**Executor:** Architect (Opus via @Shen)
**Priority:** P0

---

## Objective

Add a STEP -1 (onboarding check) to both `Executar-Tao.agent.md` (PT-BR) and `Execute-Tao.agent.md` (EN) that detects `novo_projeto` / `new_project` status and enters a guided first-run flow instead of the normal execution loop.

## Context

After install, CONTEXT.md has `status: novo_projeto` and no usable phase. The agent's golden rule says "NEVER ask questions." This creates a deadlock: the agent can't execute (nothing to run) and can't ask (forbidden). The solution is a one-time exception for project initialization that fires before the main loop.

## Files to Read (BEFORE editing)

- `agents/pt-br/Executar-Tao.agent.md` — current agent definition, full file
- `agents/en/Execute-Tao.agent.md` — English version
- `templates/pt-br/CONTEXT.md` — understand novo_projeto status
- `templates/en/CONTEXT.md` — understand new_project status

## Files to Create/Edit

- `agents/pt-br/Executar-Tao.agent.md` — add STEP -1 before STEP 0, add exception to golden rule
- `agents/en/Execute-Tao.agent.md` — same changes, English version

## Implementation Steps

1. Read both agent files completely
2. In the "Regra de Ouro" / "Golden Rule" section, add exception:
   ```
   EXCEÇÃO: Quando CONTEXT.md status == "novo_projeto"/"new_project" E project.description 
   é genérica/vazia, o agente PODE fazer UMA pergunta: "O que você quer construir?"
   Após a resposta, retorna ao modo autônomo.
   ```
3. Add STEP -1 BEFORE the existing STEP 0, with this logic:
   ```
   STEP -1 — ONBOARDING CHECK
   Read CONTEXT.md → if status == "novo_projeto" / "new_project":
     → DO NOT enter the main loop
     → Read tao.config.json → project.description
     → IF description is generic ("My project", "teste tao", empty, matches default):
       → EXCEPTION to "never ask": present message:
         "Projeto novo detectado. O que você quer construir? Descreva em 1-2 frases."
         (EN: "New project detected. What do you want to build? Describe in 1-2 sentences.")
       → Save response as project context for brainstorm
     → Run new-phase.sh to create phase 01 if dir doesn't exist
     → Invoke Wu as subagent for brainstorm of phase 01 with project description
     → After Wu completes: invoke Shen for PLAN.md + STATUS.md
     → Update CONTEXT.md: status → "em_andamento"/"in_progress", phase → "01"
     → Enter main loop (GOTO STEP 0)
   ```
4. Ensure BOTH language versions have identical logic (adapted phrasing)
5. Verify the agent's YAML frontmatter is unchanged

## Acceptance Criteria

- [ ] PT-BR agent has STEP -1 with onboarding logic
- [ ] EN agent has STEP -1 with onboarding logic (same logic, English text)
- [ ] Golden rule has explicit exception for novo_projeto/new_project
- [ ] STEP -1 creates phase 01 if missing
- [ ] STEP -1 invokes Wu for brainstorm
- [ ] STEP -1 updates CONTEXT.md status
- [ ] YAML frontmatter unchanged
- [ ] No other existing steps modified (only insertion)

## Notes / Gotchas

- The exception must fire ONLY when status is exactly `novo_projeto` or `new_project` — not on any other status
- The question is asked ONCE per project lifetime. After this, normal autonomy resumes.
- If project.description is already substantive (>10 words, not default), skip the question and use it directly
- The new-phase.sh script must be invoked via terminal: `bash .github/tao/scripts/new-phase.sh 01 "First Phase"`

---

**Expected commits:**
- `feat(phase-01): T01 — add onboarding flow to Executar-Tao agent (pt-br)`
- `feat(phase-01): T01 — add onboarding flow to Execute-Tao agent (en)`
