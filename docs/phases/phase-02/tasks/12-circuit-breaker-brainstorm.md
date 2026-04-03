# T12 — Circuit breaker BRAINSTORM_FIX_LOOP

## Objetivo
Adicionar limite total de tentativas ao BRAINSTORM_FIX_LOOP no Execute-Tao para evitar loop infinito.

## Contexto
- Execute-Tao.agent.md L97-112: após 3 tentativas, reseta `brainstorm_fix_attempt = 0` e recomeça
- Isso pode loopear infinitamente se Wu e Shen não conseguirem corrigir
- Solução: adicionar `total_brainstorm_attempts` que nunca reseta

## Arquivos a Ler
- `agents/en/Execute-Tao.agent.md` L85-115
- `agents/pt-br/Executar-Tao.agent.md` L85-115

## Arquivos a Modificar
- `agents/en/Execute-Tao.agent.md`
- `agents/pt-br/Executar-Tao.agent.md`

## Passos
1. Adicionar `total_brainstorm_attempts = 0` antes do loop
2. Incrementar `total_brainstorm_attempts` a cada tentativa (Wu ou Shen)
3. Adicionar check: `if total_brainstorm_attempts >= 9: STOP + report`
4. Mensagem de STOP deve listar todas as tentativas e outputs

## Critérios de Aceite
- [ ] Após 9 tentativas totais → STOP com relatório
- [ ] Counter total independente do counter por ciclo
- [ ] Mensagem de parada é clara e acionável
- [ ] Idêntico EN e PT-BR
