# T19 — Alinhar numeração de LOCKs

## Objetivo
Garantir que todos os LOCKs (LOCK 1-7) têm numeração consistente em todos os arquivos.

## Contexto
- LOCKs são referenciados em: GUARDRAILS.md, RULES.md, pre-commit.sh, pre-push.sh, enforcement-hook.sh, agents
- Numeração pode estar inconsistente entre documentação e código

## Arquivos a Ler
- `docs/GUARDRAILS.md` — definição dos LOCKs
- `templates/en/RULES.md` — referências
- `templates/pt-br/RULES.md` — referências PT-BR
- `hooks/pre-commit.sh` — uso nos comentários
- `hooks/pre-push.sh` — uso nos comentários
- `hooks/enforcement-hook.sh` — uso nos comentários

## Arquivos a Modificar
- Todos os que tiverem numeração inconsistente

## Passos
1. Criar tabela canônica de LOCKs com número, nome, script e descrição
2. Verificar cada arquivo contra a tabela
3. Corrigir inconsistências

## Critérios de Aceite
- [ ] Tabela canônica de LOCKs definida
- [ ] Todos os arquivos usam mesma numeração
- [ ] Cross-references corretas
