# T07 — Hooks L1 para brainstorm e plan validation

## Objetivo
Criar hooks PostToolUse que rodam validate-brainstorm.sh e validate-plan.sh como feedback em tempo real durante sessões de agente (L1 advisory, não blocking).

## Contexto
- L0 (pre-commit) bloqueia commits inválidos (T01-T02)
- L1 (hooks.json) deve dar feedback IMEDIATO durante a sessão — antes do commit
- Isso fecha o ciclo: agente recebe aviso antes de tentar commitar algo inválido

## Arquivos a Ler
- `templates/shared/hooks.json` — hooks existentes
- `hooks/lint-hook.sh` — exemplo de PostToolUse hook
- `scripts/validate-brainstorm.sh`
- `scripts/validate-plan.sh`

## Arquivos a Criar
- `hooks/brainstorm-hook.sh`
- `hooks/plan-hook.sh`

## Arquivos a Modificar
- `templates/shared/hooks.json`
- `install.sh` (adicionar cópia dos novos hooks)

## Passos
1. Criar `brainstorm-hook.sh`:
   - Trigger: PostToolUse quando tool é createFile/editFiles e path contém `brainstorm/`
   - Ação: executar validate-brainstorm.sh e injetar resultado como additionalContext
   - Output: JSON com feedback (PASS ou lista de falhas)
2. Criar `plan-hook.sh`:
   - Trigger: PostToolUse quando tool é createFile/editFiles e path contém `STATUS.md` ou `PLAN.md`
   - Ação: executar validate-plan.sh e injetar resultado
3. Registrar ambos no hooks.json PostToolUse array
4. Adicionar safe_copy_exec no install.sh

## Critérios de Aceite
- [ ] Edição de BRIEF.md → validate-brainstorm feedback imediato
- [ ] Edição de PLAN.md/STATUS.md → validate-plan feedback imediato
- [ ] Hooks são non-blocking (exit 0 sempre)
- [ ] hooks.json atualizado
- [ ] install.sh copia novos hooks
