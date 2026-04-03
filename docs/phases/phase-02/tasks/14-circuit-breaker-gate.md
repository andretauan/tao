# T14 — Circuit breaker GATE_LOOP

## Objetivo
Adicionar limite total de tentativas ao GATE_LOOP de pós-execução (mesmo padrão de T12).

## Contexto
- Execute-Tao.agent.md L221-228: `gate_attempt = 0` após intervenção Shen → loop infinito possível

## Arquivos a Modificar
- `agents/en/Execute-Tao.agent.md`
- `agents/pt-br/Executar-Tao.agent.md`

## Passos
1. Adicionar `total_gate_attempts = 0` antes do GATE_LOOP
2. Incrementar a cada tentativa
3. `if total_gate_attempts >= 9: STOP + mark phase ⚠️ + report`

## Critérios de Aceite
- [ ] Após 9 tentativas totais → STOP
- [ ] Fase marcada como ⚠️ no STATUS.md
- [ ] Relatório com todas as tentativas e outputs
- [ ] Idêntico EN e PT-BR
