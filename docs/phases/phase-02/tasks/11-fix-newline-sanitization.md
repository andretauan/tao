# T11 — Corrigir sanitização de newlines no lint-hook.sh

## Objetivo
Adicionar newlines e carriage returns à regex de sanitização de FILE_PATH.

## Contexto
- lint-hook.sh L105: regex `[';|&\`$(){}\\<>']` não inclui `\n` nem `\r`
- Path com newline embutido poderia injetar via `bash -c`

## Arquivos a Ler
- `hooks/lint-hook.sh` L100-110

## Arquivos a Modificar
- `hooks/lint-hook.sh`

## Passos
1. Adicionar `$'\n'` e `$'\r'` ao check de sanitização
2. Pode ser check separado: `if [[ "$FILE_PATH" == *$'\n'* ]] || [[ "$FILE_PATH" == *$'\r'* ]]`

## Critérios de Aceite
- [ ] Path com newline → skipped
- [ ] Path com carriage return → skipped
- [ ] Path normal → lint roda
