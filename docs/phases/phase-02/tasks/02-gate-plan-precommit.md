# T02 — Gate de plan no pre-commit.sh

## Objetivo
Adicionar validação de plano como gate L0 no pre-commit.sh, para que commits com PLAN.md/STATUS.md inválidos sejam bloqueados.

## Contexto
- `validate-plan.sh` existe e funciona, mas só é chamado via instrução textual
- Se o agente pular plan_gate, nada impede um commit com plano inválido

## Arquivos a Ler
- `hooks/pre-commit.sh`
- `scripts/validate-plan.sh`
- `agents/en/Execute-Tao.agent.md` L128-135

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Usar helper `get_active_phase_dir()` de T06
2. Checar se `STATUS.md` existe no diretório da fase
3. Checar se alguma task já está ✅ (se sim, pula — plano já validado em sessão anterior)
4. Se STATUS existe e nenhuma task ✅: executar `validate-plan.sh {phase_dir}`
5. Se exit 1: bloquear commit
6. Se exit 0 ou script não encontrado: permitir

## Critérios de Aceite
- [ ] PLAN.md inválido → commit bloqueado
- [ ] PLAN.md válido → commit passa
- [ ] Task ✅ já existe → pula gate
- [ ] Mensagem bilíngue
