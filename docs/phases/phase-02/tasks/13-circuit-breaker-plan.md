# T13 — Circuit breaker PLAN_FIX_LOOP

## Objetivo
Adicionar limite total de tentativas ao PLAN_FIX_LOOP (mesmo padrão de T12).

## Contexto
- Execute-Tao.agent.md L128-135: mesmo problema do BRAINSTORM_FIX_LOOP

## Arquivos a Modificar
- `agents/en/Execute-Tao.agent.md`
- `agents/pt-br/Executar-Tao.agent.md`

## Passos
1. Adicionar `total_plan_attempts = 0` antes do loop
2. Incrementar a cada tentativa
3. `if total_plan_attempts >= 9: STOP + report`

## Critérios de Aceite
- [ ] Após 9 tentativas totais → STOP
- [ ] Counter total independente
- [ ] Idêntico EN e PT-BR
