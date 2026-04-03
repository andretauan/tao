# T17 — Documentar fallback no Investigate-Shen

## Objetivo
Esclarecer no texto interno do agent que Sonnet 4.6 é fallback, não modelo primário.

## Contexto
- YAML: `model: [Opus 4.6, Sonnet 4.6]`
- Texto L11: "Model: Opus 4.6" — omite o fallback
- Mesmo problema de T16

## Arquivos a Modificar
- `agents/en/Investigate-Shen.agent.md`
- `agents/pt-br/Investigar-Shen.agent.md`

## Passos
1. Alterar texto: "Model: Opus 4.6 (primary) — Sonnet 4.6 as automatic fallback when rate-limited"
2. Consistência EN e PT-BR

## Critérios de Aceite
- [ ] Texto e YAML consistentes
- [ ] EN e PT-BR idênticos em semântica
