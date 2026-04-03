# T05 — Gate forensic no pre-commit.sh

## Objetivo
Adicionar `forensic-audit.sh` como gate L0 final para commits de conclusão de fase.

## Contexto
- README diz "Every commit passes through a 3-pass forensic audit" — atualmente FALSO
- `forensic-audit.sh` implementa 3 rounds com 24 verificações — é real e robusto
- Deve ser a última verificação antes de permitir o commit de conclusão

## Arquivos a Ler
- `hooks/pre-commit.sh`
- `scripts/forensic-audit.sh`

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Mesma condição de T03/T04 (todas tasks ✅)
2. Executar `forensic-audit.sh {phase_dir}` como último gate
3. Se exit 1: bloquear commit com saída do round que falhou
4. Se exit 0: permitir — commit de conclusão passa por TODOS os gates

## Critérios de Aceite
- [ ] Auditoria forense falha → commit bloqueado
- [ ] Auditoria forense passa → commit liberado
- [ ] Output do round falho é mostrado ao usuário
- [ ] README se torna VERDADEIRO para commits de conclusão de fase
