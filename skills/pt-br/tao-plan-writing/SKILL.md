---
name: tao-plan-writing
description: "Decomposição expert de tarefas para criar PLAN.md no TAO. Quebra features em fases e tarefas com critérios de aceite, estimativas e dependências. Use ao planejar trabalho, criar fases ou decompor features."
user-invocable: false
---
# Escrita de Plano TAO

## Quando usar
Auto-carregado ao criar ou atualizar PLAN.md, decompor features em tarefas ou planejar fases.

## Princípios de Decomposição
1. **Uma tarefa = um commit** — se precisa de múltiplos commits, divida
2. **Critérios de aceite são testáveis** — nada de "funciona corretamente" vago
3. **Tarefas ordenadas por dependência** — tarefas bloqueadas vêm depois dos bloqueadores
4. **Cada tarefa tem esforço estimado** — S (< 30 min), M (30-90 min), L (90+ min)

## Estrutura do PLAN.md
```markdown
# Fase XX — [Título da Fase]

**Objetivo:** Uma frase descrevendo o que esta fase alcança
**Pré-requisito:** Fase XX-1 completa (ou "nenhum")

## Tarefas

### T01 — [Nome da Tarefa]
- **Escopo:** Quais arquivos/módulos isso toca
- **Critérios de aceite:**
  - [ ] Critério 1 (testável)
  - [ ] Critério 2 (testável)
- **Esforço:** S | M | L
- **Modelo:** Sonnet | Opus | GPT-4.1
- **Dependências:** nenhuma | T0X

### T02 — [Nome da Tarefa]
...
```

## Regras de Roteamento de Modelo
| Tipo de Tarefa | Modelo | Custo |
|----------------|--------|-------|
| CRUD simples, config, boilerplate | GPT-4.1 | Grátis |
| Lógica padrão, testes, integração | Sonnet | Baixo |
| Arquitetura complexa, segurança, debug | Opus | Alto |

## Heurísticas de Decomposição
- **Banco primeiro** — schema antes do código que lê
- **Interface primeiro** — contrato da API antes da implementação
- **Testes junto** — tarefa de teste segue imediatamente a de implementação
- **Config por último** — ambiente/deploy config depois de todo o código

## Red Flags (divida a tarefa se...)
- Tarefa toca mais de 3 arquivos
- Descrição usa "e" mais de uma vez
- Escopo cruza fronteiras de módulos
- Esforço estimado é L — geralmente divisível

## Quality Gate
Antes de marcar PLAN.md como completo, verifique:
- [ ] Todas as tarefas têm critérios de aceite
- [ ] Todas as tarefas têm estimativas de esforço
- [ ] Todas as tarefas têm modelo atribuído
- [ ] Dependências formam um DAG (sem circular)
- [ ] Contagem de tarefas entre 3-10 por fase
