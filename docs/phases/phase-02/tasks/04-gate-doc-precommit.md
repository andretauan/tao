# T04 — Gate de documentação no pre-commit.sh

## Objetivo
Adicionar validação de documentação como gate L0 no pre-commit.sh para commits de conclusão de fase.

## Contexto
- `doc-validate.sh` verifica completude de documentação (CHANGELOG, progress.txt, etc.)
- Deve rodar junto com T03 (mesma condição: todas tasks ✅)

## Arquivos a Ler
- `hooks/pre-commit.sh`
- `scripts/doc-validate.sh`

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Mesma condição de T03 (todas tasks ✅)
2. Executar `doc-validate.sh {phase_dir}`
3. Se exit 1: bloquear commit
4. Se exit 0: permitir

## Critérios de Aceite
- [ ] Documentação incompleta → commit bloqueado
- [ ] Documentação ok → commit passa
- [ ] Fase com tasks ⏳ → pula gate
