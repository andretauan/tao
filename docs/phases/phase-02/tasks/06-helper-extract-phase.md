# T06 — Helper: extrair fase ativa no pre-commit.sh

## Objetivo
Criar funções reutilizáveis no pre-commit.sh para determinar a fase ativa e o estado das tasks. Prerequisito para T01-T05.

## Contexto
- T01-T05 precisam saber: qual a fase ativa? quantas tasks ⏳ vs ✅?
- Informação vem de `tao.config.json` (paths) + `CONTEXT.md` (fase ativa) + `STATUS.md` (contagem)
- context-hook.sh já implementa lógica similar — reusar padrão

## Arquivos a Ler
- `hooks/pre-commit.sh` — onde adicionar
- `hooks/context-hook.sh` L60-90 — lógica existente de extração de fase
- `tao.config.json.example` — campos paths.phases e paths.phase_prefix

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Criar função `get_active_phase_dir()`:
   - Ler `tao.config.json` → `paths.phases` e `paths.phase_prefix`
   - Ler `CONTEXT.md` → extrair número da fase ativa
   - Retornar path completo (ex: `docs/phases/phase-01`)
   - Fallback: se CONTEXT.md não existe, retornar string vazia
2. Criar função `count_tasks()`:
   - Receber phase_dir como argumento
   - Ler STATUS.md → contar ⏳ e ✅
   - Retornar via variáveis globais `TASKS_PENDING` e `TASKS_DONE`
3. Criar função `locate_script()`:
   - Buscar script em caminhos candidatos (`.github/tao/scripts/`, path relativo ao hook)
   - Retornar path do executável ou string vazia

## Critérios de Aceite
- [ ] `get_active_phase_dir` retorna path correto
- [ ] `get_active_phase_dir` retorna "" se CONTEXT.md não existe
- [ ] `count_tasks` conta ⏳ e ✅ corretamente
- [ ] `locate_script` encontra scripts em projetos instalados
- [ ] Funções são usadas por T01-T05
