# T08 — Sanitizar file paths no pre-commit.sh

## Objetivo
Corrigir vulnerabilidade de injeção shell na seção de lint do pre-commit.sh.

## Contexto
- pre-commit.sh L71: `bash -c "$cmd"` onde `$cmd` contém `$file` sem sanitização
- lint-hook.sh sanitiza (L105), mas pre-commit.sh NÃO
- Filenames com metacharacters (`;|&$()`) podem injetar comandos

## Arquivos a Ler
- `hooks/pre-commit.sh` L50-80
- `hooks/lint-hook.sh` L100-110 — exemplo de sanitização existente

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Antes do loop de lint (L58), adicionar check de metacharacters no `$file`
2. Se `$file` contém `[;|&\`$(){}\\<>]` → skip com warning
3. Manter mesmo padrão do lint-hook.sh

## Critérios de Aceite
- [ ] Arquivo com `;` no nome → skipped
- [ ] Arquivo com espaço no nome → lint roda normalmente
- [ ] Arquivo normal → lint roda normalmente
- [ ] Warning visível quando skip ocorre
