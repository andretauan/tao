# T09 — Corrigir detecção de force-push no pre-push.sh

## Objetivo
Adicionar detecção de `-f` (forma curta de `--force`) no pre-push.sh.

## Contexto
- pre-push.sh L32: `grep -qE '\-\-force|--force-with-lease'`
- `git push -f origin dev` NÃO é bloqueado porque `-f` não está na regex
- LOCK 2 promete bloquear force push — está incompleto

## Arquivos a Ler
- `hooks/pre-push.sh` L30-40

## Arquivos a Modificar
- `hooks/pre-push.sh`

## Passos
1. Alterar regex de L32 para incluir `-f` como flag isolada
2. Pattern: `\s-f\s|--force\b|--force-with-lease\b`
3. Cuidado: `-f` pode ser parte de outros flags — checar posição (deve ser standalone)

## Critérios de Aceite
- [ ] `git push -f origin dev` → BLOQUEADO
- [ ] `git push --force origin dev` → BLOQUEADO
- [ ] `git push --force-with-lease` → BLOQUEADO
- [ ] `git push origin dev` → PERMITIDO
- [ ] `git push origin feature-foo` → PERMITIDO (sem false positive no `-f` de `feature`)
