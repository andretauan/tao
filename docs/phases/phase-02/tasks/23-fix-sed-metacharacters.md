# T23 — Robustecer sed no new-phase.sh

## Objetivo
Corrigir escape de metacharacters sed nos placeholders do new-phase.sh para nomes de projeto com caracteres especiais.

## Contexto
- new-phase.sh usa sed para substituir `{{PROJECT_NAME}}` e `{{PROJECT_DESCRIPTION}}`
- Metacharacters sed (`&`, `/`, `\`) no valor de substituição corrompem o resultado
- Ex: projeto "Foo & Bar" → sed interpreta `&` como backreference

## Arquivos a Ler
- `scripts/new-phase.sh` — seções de substituição de placeholders

## Arquivos a Modificar
- `scripts/new-phase.sh`

## Passos
1. Opção A: Substituir sed por Python para operações de substituição
2. Opção B: Escapar corretamente todos os metacharacters antes do sed
   - `value=$(echo "$value" | sed 's/[&/\]/\\&/g')`
3. Testar com nomes: "Foo & Bar", "path/to/thing", "back\slash"

## Critérios de Aceite
- [ ] Nome com `&` → substituição correta
- [ ] Nome com `/` → substituição correta
- [ ] Nome com `\` → substituição correta
- [ ] Nome normal → sem regressão
