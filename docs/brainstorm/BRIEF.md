# BRIEF.md — TAO v0.1: The Way of AI-Native Development
> Compressão de DISCOVERY.md (1475 linhas) + DECISIONS.md (362 linhas) do brainstorm GSD.
> Source: `/home/tauan/Apps/GSD/docs/brainstorm/`
> Gerado: 2026-03-27 10:03

## Maturidade: 7/7
- [x] Problema/objetivo claro (§1)
- [x] ≥2 alternativas exploradas por tópico
- [x] Trade-offs avaliados (IBIS em D1-D20)
- [x] Decisões têm "Invalidaria se..."
- [x] Brain docs consultados (ARCHITECTURE.md, agents, hooks)
- [x] Scope definido (§5 NÃO Implementar)
- [x] Codebase patterns integrados (42 hardcodes, 8 bugs, 12 DQs mapeados)

---

## §1 Problema Central

Transformar o sistema GSD (3 camadas: Think → Plan → Execute + Guardrails) — nascido dentro do RevelaME — em **TAO** (道): repositório open source no GitHub, renomeado e com identidade própria.

**TAO = Trace · Align · Operate** — The Way of AI-native development.

O desafio: empacotar para que um dev desconhecido consiga (1) entender em 2 min, (2) instalar em 5 min, (3) executar a primeira tarefa em 10 min, (4) descobrir layers avançadas progressivamente.

---

## §2 Prioridades

1. **Sistema completo (3 layers)** — não apenas o loop, mas brainstorm + plano + execução + guardrails
2. **Onboarding excelente** — serve de L1 (vibe coder) a L5 (architect) no MESMO doc
3. **Bilíngue desde v0.1** — EN + PT-BR com adaptação cultural (não tradução mecânica)
4. **Zero [SUBSTITUIR]** — installer interativo + gsd.config.json centralizado
5. **Identidade própria** — TAO com ecossistema taoísta de agents
6. **Enforcement real** — pre-commit hooks no core, não addon

---

## §3 Decisões Travadas (20 decisões IBIS)

### Naming — TAO (supersede D4)
- **Projeto:** TAO (道) — "The Way". Sigla: **T**race · **A**lign · **O**perate
- **Orchestrator agent:** `@Tao` — o caminho, roda o loop
- **Brainstorm agent:** `@Wu` (悟 insight) — deliberação, IBIS
- **Complex Worker:** `@Shen` (深 profundo) — Opus, tarefas complexas
- **Architect:** `@Shen` (mesmo — acesso direto fora do loop)
- **DBA:** `@Di` (地 terra) — fundação, banco de dados
- **Deploy:** `@Qi` (气 fluxo) — energia que flui pro mundo
- **Crédito ao Ralph:** seção "Inspiration" no README (Opção B do naming)

### Arquitetura (D1, D7, D8, D9)
- Core + Addons (D1). Enforcement no core (D7).
- 3 layers + Guardrails transversal (D8)
- Pre-commit como pipeline modular: orquestrador + 4 módulos (D9)

### Idioma (D20, supersede D2)
- 2 conjuntos completos (EN + PT-BR) + i18n.sh para scripts
- Templates são adaptação cultural, não tradução
- Installer pergunta idioma no step 1
- Anti-drift: `i18n-diff.sh` compara hashes

### Onboarding (D13, D14, D15)
- 1 path único com `<details>` accordions (D13)
- Modo onboarding auto: CONTEXT.md `status: new_project` (D14)
- Sonnet decompõe planos simples, Opus delibera complexos (D15)

### Instrução (D11)
- CLAUDE.md = fonte única. copilot-instructions.md = ponteiro mínimo.
- Agents focam em comportamento específico, referenciam CLAUDE.md.

### Config (D16, D19)
- `tao.config.json` centralizado (sem [SUBSTITUIR])
- Installer interativo + `update-models.sh`
- Lint hook genérico por extensão

### Qualidade (D10)
- ABEX 3× como protocolo no prompt + checklist template
- Não script automatizado (é julgamento, não check mecânico)

### Compatibilidade (D17, D18)
- 3 tiers: Copilot (full), Claude Code (adapter), Cursor/Cline (minimal)
- MCP como addon v0.2+, não core

### Diferencial (D3)
- Vender pelo Layer 3 (execução), reter pelo Layer 1 (deliberação)
- Brainstorm com IBIS é o moat incopiável

### Skills (D5)
- TAO-specific incluídas. Domínio = referenciar terceiros.

### Scope MVP (D6)
- Core funcional + Brainstorm agent + templates IBIS + README excelente + enforcement hooks

---

## §4 Contexto Técnico

### O que existe no GSD portable (22 arquivos)
- `instalar-gsd.sh` — funcional mas com 8 bugs (B1-B8)
- `gsd.sh` — monitor funcional (status/report/dry-run/pause)
- 5 agents (GSD, Opus-Worker, Arquiteto, DBA, Deploy) — modelos hardcoded
- Hooks (PostToolUse lint PHP-only, SessionStart context)
- Phase templates (PLAN, STATUS, tarefa, progress)
- ARCHITECTURE.md — excelente
- Templates (CLAUDE.md, CONTEXT.md, CHANGELOG.md, copilot-instructions.md)

### 42 hardcodes a resolver (6 categorias)
- **A (12):** PT-BR em código/scripts/templates
- **B (7):** Modelos fixos nos .agent.md
- **C (5):** PHP como stack presumida
- **D (4):** Nomes de agents fixos
- **E (6):** Paths e convenções fixas ("fase-", "dev" branch)
- **F (8):** Bugs de lógica

### 8 bugs confirmados
- **B2 CRITICAL:** `npx get-shit-done-cc@latest` — pacote inexistente
- **B3 CRITICAL:** Git hooks NUNCA são instalados
- **B4 HIGH:** "Dark Mode obrigatório" — leak do RevelaME
- **B6 HIGH:** `fase-` prefix impossibilita EN clean

### 12 desqualificadores para devs avançados
- DQ1-DQ3 (ALTA): PT-BR em templates, PHP presumido, [SUBSTITUIR] spam
- DQ5-DQ6 (ALTA): npm phantom, README fraco, sem LICENSE
- DQ8 (ALTA): Sem LICENSE

### 10 gaps entre decisões e código
- Brainstorm Agent: inexistente
- Skills TAO-specific: inexistentes
- AGENTS.md template: inexistente
- Pre-commit hooks: inexistentes
- gsd.config.json: inexistente
- GETTING-STARTED.md: inexistente
- Modo onboarding: inexistente

### 8 coisas que funcionam BEM
1. ARCHITECTURE.md — completo, preciso
2. gsd.sh — monitor funcional
3. Hook scripts — `staged_content()` é brilhante
4. Phase templates — bem estruturados
5. No-overwrite installer
6. CONTEXT.md template
7. Subagent isolation
8. Cost model docs

---

## §5 NÃO Implementar (Scope Out)

- Nada do RevelaME (sondas, psicometria, herança, voice, Cinema Quente)
- Skills de terceiros (antigravity) — referenciar
- CLI wizard `npx tao init` (v0.3)
- MCP server (v0.2)
- CI/CD workflows (v0.2)
- Auto-generator genérico (v0.3)
- Cost tracking script (v0.2)
- 3º idioma ES (quando comunidade pedir)
- Video walkthroughs (v0.2)
- Adapters Claude Code/Cline/Continue (v0.2)

---

## §6 Condições de Escape

- Se bilíngue atrasar demais → lançar EN only, PT-BR em v0.1.1
- Se installer interativo ficar complexo → fallback para tao.config.json manual
- Se accordions não renderizarem bem em mobile → separar docs por nível
- Se planos Sonnet falharem consistentemente → voltar "sempre Opus planeja"
- Se separação core/addons confundir → monolítico com flags

---

## §7 must_haves (derivados das decisões)

### Verdades invioláveis
1. TAO = The Way. Trace · Align · Operate.
2. Agents taoístas: @Tao, @Wu, @Shen, @Di, @Qi
3. 3 layers + Guardrails transversal
4. CLAUDE.md = fonte única de regras
5. Enforcement (pre-commit) = core, não addon
6. Bilíngue EN + PT-BR desde v0.1

### Artefatos obrigatórios do MVP
1. `install.sh` — interativo, ~5 perguntas, gera tao.config.json
2. `tao.config.json` — config centralizada (zero [SUBSTITUIR])
3. `tao.sh` — monitor (renomear de gsd.sh)
4. 6 agents taoístas (EN + PT-BR = 12 arquivos)
5. Wu.agent.md (Brainstorm) — novo, ~200 linhas, IBIS + 5 modos
6. Templates: CLAUDE.md, CONTEXT.md, CHANGELOG.md, copilot-instructions.md (EN + PT-BR)
7. Phase templates: PLAN, STATUS, task/tarefa, progress (EN + PT-BR)
8. Brainstorm templates: DISCOVERY.md, DECISIONS.md, BRIEF.md
9. Git hooks: pre-commit (modular), post-commit (auto-push), install-hooks.sh
10. VS Code hooks: gsd-hooks.json, lint-hook.sh (genérico), context-hook.sh
11. Skills: tao-planner, tao-executor, tao-brainstormer
12. Docs: README.md (EN), README.pt-br.md, GETTING-STARTED.md (accordions), ARCHITECTURE.md, ECONOMICS.md, GUARDRAILS.md
13. `update-models.sh` — atualiza modelos pós-install
14. `i18n-diff.sh` — anti-drift entre idiomas
15. LICENSE (MIT)
16. CONTRIBUTING.md

### Conexões
- install.sh LEIA tao.config.json
- Agents REFERENCIEM CLAUDE.md (não dupliquem)
- Pre-commit LEIA tao.config.json para lint commands
- Context hook LEIA tao.config.json para phase_prefix
- Wu.agent.md USE templates de DISCOVERY/DECISIONS/BRIEF

---

## §8 Riscos

| Risco | Prob. | Mitigação |
|---|---|---|
| Dependência VS Code Copilot API | Alta | 3 tiers de compatibilidade (D17) |
| Bilíngue drift | Média | i18n-diff.sh + PT-BR mantido por Tauan |
| Complexidade assusta novatos | Alta | Accordion pattern (D13) + modo onboarding (D14) |
| Confusão core/addons | Média | Docs claras + installer que instala core completo |
| Templates ficam stale | Alta | CI futura + community PRs |
| IBIS intimidante | Média | Wu agent guia sem jargão + "think deeper" opt-in |

---

## §9 Brain Docs + Skills

### Brain docs consultados
- `Docs/brain/01-CORE.md` — arquitetura de 3 camadas
- `Docs/brain/04-AGENTES.md` — hierarquia de agents

### Skills para execução
- `get-shit-done` — workflow principal
- `agent-customization` — criação de .agent.md
- `clean-code` — qualidade de templates
- `plan-writing` — criação do PLAN.md

---

## BRIEF QUALITY CHECK

```
📋 BRIEF QUALITY CHECK
├─ Checklist maturidade: 7/7
├─ Decisões com IBIS completo: 20/20 (D1-D20, D2 e D12 superseded)
├─ Decisões adiadas registradas: 11 itens
├─ must_haves derivados: 6 verdades, 16 artefatos, 3 conexões
├─ Brain docs consultados (R10): 01-CORE, 04-AGENTES, ARCHITECTURE.md
├─ Skills identificadas para execução (R6): get-shit-done, agent-customization, clean-code, plan-writing
├─ Condições de escape definidas: SIM (5 condições)
└─ Prioridades do usuário preservadas: SIM (6 prioridades)
```
