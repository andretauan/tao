# T03 — Gate de execução no pre-commit.sh

## Objetivo
Adicionar validação de execução como gate L0 no pre-commit.sh, para que o commit de conclusão de fase passe por `validate-execution.sh`.

## Contexto
- `validate-execution.sh` verifica integridade de execução (tasks vs STATUS, artefatos, etc.)
- Só faz sentido rodar quando TODAS as tasks estão ✅ (fase completa)
- Atualmente nunca é chamado automaticamente

## Arquivos a Ler
- `hooks/pre-commit.sh`
- `scripts/validate-execution.sh`

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Usar helper de T06 para contar tasks ⏳ e ✅
2. Se ⏳ == 0 e ✅ > 0 (todas completas): executar `validate-execution.sh {phase_dir}`
3. Se exit 1: bloquear commit
4. Se exit 0 ou tasks ⏳ restantes: permitir

## Critérios de Aceite
- [ ] Fase completa + validação falha → commit bloqueado
- [ ] Fase completa + validação ok → commit passa
- [ ] Fase com tasks ⏳ → pula gate
