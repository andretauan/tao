# T21 — Completar PASS 3 (hacker) do faudit.sh

## Objetivo
Implementar os checks faltantes na perspectiva de atacante do faudit.sh.

## Contexto
- faudit.sh tem 3 passes: Surface → Structural → Hacker
- PASS 3 está parcialmente implementado
- Checks faltantes: dependency audit, env var leak, debug endpoints, insecure defaults

## Arquivos a Ler
- `scripts/faudit.sh` — seção PASS 3

## Arquivos a Modificar
- `scripts/faudit.sh`

## Passos
1. Auditar checks existentes na PASS 3
2. Adicionar checks faltantes:
   - Busca por `.env` files commitados (não devem estar no repo)
   - Busca por `DEBUG=True` / `DEBUG=true` em config files
   - Busca por ports hardcoded (3000, 8080, etc.) sem variável de ambiente
   - Busca por `console.log` / `print()` de dados sensíveis
3. Cada check: PASS/FAIL/WARN com descrição clara

## Critérios de Aceite
- [ ] Todos os checks da PASS 3 implementados
- [ ] Cada check produz output claro
- [ ] Nenhum false positive em projetos típicos
