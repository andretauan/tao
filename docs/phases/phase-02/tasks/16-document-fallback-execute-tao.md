# T16 — Documentar fallback no Execute-Tao

## Objetivo
Esclarecer no texto interno do agent que GPT-4.1 é fallback (rate-limit shield), não modelo primário.

## Contexto
- YAML: `model: [Sonnet 4.6, GPT-4.1]` — correto como fallback
- Texto L22: "Model: Sonnet 4.6" — omite o fallback
- Inconsistência confunde a auditoria e potencialmente o agente

## Arquivos a Modificar
- `agents/en/Execute-Tao.agent.md`
- `agents/pt-br/Executar-Tao.agent.md`

## Passos
1. Alterar texto do "Model" para: "Model: Sonnet 4.6 (primary) — GPT-4.1 as automatic fallback when rate-limited"
2. Garantir consistência EN e PT-BR

## Critérios de Aceite
- [ ] Texto e YAML consistentes
- [ ] Fallback documentado explicitamente
- [ ] EN e PT-BR idênticos em semântica
