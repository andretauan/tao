# Task T21 — Wu Agents Rate-Limit Message (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P4-DOCS
**Depends on:** None

---

## Objective

Add rate-limit handling to Wu agent definitions so the agent gracefully handles Opus rate limits instead of failing or switching to Sonnet silently.

## Gaps Fixed

- G28: Wu has no rate-limit handling — hits Opus limits silently, may degrade to Sonnet

## Files to Read

- `agents/pt-br/Brainstorm-Wu.agent.md` — current implementation
- `agents/en/Brainstorm-Wu.agent.md` — current implementation

## Files to Edit

- `agents/pt-br/Brainstorm-Wu.agent.md` — add rate-limit protocol
- `agents/en/Brainstorm-Wu.agent.md` — add rate-limit protocol

## Changes

### 1. Add Rate-Limit Protocol section

Add after the "Restrição de Modelo (INVIOLÁVEL)" / "Model Restriction (INVIOLABLE)" section:

**PT-BR:**
```markdown
## Protocolo de Rate-Limit

Se Opus estiver indisponível ou rate-limited:

1. **NÃO** trocar silenciosamente para Sonnet
2. Informar o usuário: "⚠️ Opus rate-limited. Sessão de brainstorm pausada."
3. Salvar estado atual em disco (DISCOVERY.md / DECISIONS.md)
4. Sugerir: "Aguarde ~15 minutos e retome com: @Brainstorm-Wu continuar"
5. **PARAR** — não continuar com modelo inferior

Razão: Um brainstorm superficial do Sonnet é PIOR que nenhum brainstorm — gera falsa confiança em decisões mal fundamentadas.
```

**EN:**
```markdown
## Rate-Limit Protocol

If Opus is unavailable or rate-limited:

1. **DO NOT** silently switch to Sonnet
2. Inform user: "⚠️ Opus rate-limited. Brainstorm session paused."
3. Save current state to disk (DISCOVERY.md / DECISIONS.md)
4. Suggest: "Wait ~15 minutes and resume with: @Brainstorm-Wu continue"
5. **STOP** — do not continue with inferior model

Reason: A shallow Sonnet brainstorm is WORSE than no brainstorm — it creates false confidence in poorly reasoned decisions.
```

## Acceptance Criteria

- [ ] Rate-limit protocol added to PT-BR Wu agent
- [ ] Rate-limit protocol added to EN Wu agent
- [ ] Protocol instructs save-and-stop, not degrade
- [ ] User gets clear message with resume instructions
