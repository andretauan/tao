# Task T14 — Wu Agents: Add Rate-Limit Message

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P3

---

## Objective

Add a clear message to Wu agent instructions for when Opus is unavailable due to rate limiting, explaining WHY Wu cannot use Sonnet and WHAT the user should do.

## Context

Wu agents require Opus — this is a hard requirement documented in the agent file. But when Opus is rate-limited, there's no guidance for the user. They see "model unavailable" with no explanation. Adding a clear message in the agent instructions helps the AI explain the situation instead of silently failing or falling back to Sonnet (which would produce low-quality brainstorming).

## Files to Read (BEFORE editing)

- `agents/en/Brainstorm-Wu.agent.md` — full file
- `agents/pt-br/Brainstorm-Wu.agent.md` — full file

## Files to Create/Edit

- `agents/en/Brainstorm-Wu.agent.md` — add rate-limit section
- `agents/pt-br/Brainstorm-Wu.agent.md` — same in Portuguese

## Implementation Steps

1. Read both Wu agent files
2. Add a section after the model restriction:

   **EN:**
   ```markdown
   ## When Opus is Unavailable
   
   If Opus is rate-limited or unavailable, Wu MUST:
   1. Inform the user clearly: "Wu requires Opus for brainstorming. Opus is currently unavailable (rate limit). Please wait 10-15 minutes and try again."
   2. Do NOT fall back to Sonnet — Sonnet produces shallow brainstorming that leads to incomplete plans
   3. Do NOT attempt to continue the session with a lesser model
   4. Save any in-progress work to disk before stopping
   ```

   **PT-BR:**
   ```markdown
   ## Quando Opus Está Indisponível
   
   Se Opus estiver com rate-limit ou indisponível, Wu DEVE:
   1. Informar o usuário claramente: "Wu requer Opus para brainstorming. Opus está indisponível no momento (rate limit). Aguarde 10-15 minutos e tente novamente."
   2. NÃO usar Sonnet como fallback — Sonnet produz brainstorming superficial que leva a planos incompletos
   3. NÃO tentar continuar a sessão com um modelo inferior
   4. Salvar qualquer trabalho em andamento no disco antes de parar
   ```

3. Verify the section integrates well with the existing model restriction section

## Acceptance Criteria

- [ ] EN Wu agent has "When Opus is Unavailable" section
- [ ] PT-BR Wu agent has "Quando Opus Está Indisponível" section
- [ ] Message explains WHY Sonnet won't work (shallow brainstorming)
- [ ] Message tells user WHAT to do (wait 10-15 min)
- [ ] Instructions include saving work before stopping
- [ ] No changes to model requirement itself

## Notes / Gotchas

- The 10-15 minute wait is approximate — rate limits vary by provider
- The key insight is: better to wait for Opus than get bad brainstorming from Sonnet
- This is instruction text, not code — the agent will read it and act accordingly
- Both language versions must convey the same information

---

**Expected commit:** `docs(phase-01): T14 — Wu agents add rate-limit guidance`
