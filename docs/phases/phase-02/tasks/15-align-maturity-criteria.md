# T15 — Alinhar critérios de maturidade no tao-brainstorm/SKILL.md

## Objetivo
Corrigir os 7 critérios de maturidade no skill de brainstorm para serem idênticos aos definidos no Brainstorm-Wu.agent.md e BRIEF.md.template.

## Contexto
- Brainstorm-Wu.agent.md e BRIEF.md.template definem 7 critérios consistentes
- tao-brainstorm/SKILL.md lista critérios DIFERENTES
- Agente consultando o skill pode avaliar maturidade com critérios errados

## Arquivos a Ler
- `agents/en/Brainstorm-Wu.agent.md` — critérios canônicos
- `phases/shared/BRIEF.md.template` — critérios no template
- `skills/en/tao-brainstorm/SKILL.md` — critérios atuais (ERRADOS)
- `skills/pt-br/tao-brainstorm/SKILL.md` — versão PT-BR

## Arquivos a Modificar
- `skills/en/tao-brainstorm/SKILL.md`
- `skills/pt-br/tao-brainstorm/SKILL.md`

## Passos
1. Copiar os 7 critérios exatos do Brainstorm-Wu.agent.md
2. Substituir os critérios no SKILL.md EN
3. Substituir os critérios no SKILL.md PT-BR
4. Verificar que os 3 locais (agent, template, skill) são idênticos

## Critérios de Aceite
- [ ] 7 critérios idênticos nos 3 locais
- [ ] EN e PT-BR consistentes
