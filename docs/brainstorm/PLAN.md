# PLAN.md — TAO v0.1: The Way of AI-Native Development

**Data:** 2026-03-27 10:08
**Source:** `TAO/docs/brainstorm/BRIEF.md` (maturity 7/7, 20 decisions)
**Objetivo:** Construir TAO v0.1 MVP — repo público GitHub pronto para uso.

---

## Visão Geral

Transformar o GSD portable (22 arquivos, 2336 linhas) no TAO v0.1:
- Corrigir 8 bugs (2 critical, 2 high)
- Eliminar 42 hardcodes via `tao.config.json` centralizado
- Renomear agents para ecossistema taoísta (@Tao, @Wu, @Shen, @Di, @Qi)
- Bilíngue EN + PT-BR com adaptação cultural
- Pre-commit hooks modulares no core
- Brainstorm agent (@Wu) novo com IBIS e 5 modos
- README excelente com accordion onboarding (L1→L5)
- Tudo em `/home/tauan/Apps/TAO/` — zero dependência do RevelaME

---

## Estrutura Final do Repositório

```
TAO/
├── install.sh                          # Installer interativo
├── tao.sh                              # Monitor (status/report/dry-run/pause)
├── update-models.sh                    # Atualiza modelos pós-install
├── tao.config.json.example             # Exemplo de config (commitado)
├── LICENSE                             # MIT
├── README.md                           # EN — principal
├── README.pt-br.md                     # PT-BR
├── CONTRIBUTING.md                     # EN + PT-BR section
├── .gitignore                          # tao.config.json, etc.
│
├── docs/
│   ├── ARCHITECTURE.md                 # Adaptado do GSD
│   ├── GETTING-STARTED.md              # Accordion L1→L5
│   ├── ECONOMICS.md                    # Model costs
│   └── GUARDRAILS.md                   # 7 layers explained
│
├── templates/
│   ├── en/                             # English templates
│   │   ├── CLAUDE.md
│   │   ├── CONTEXT.md
│   │   ├── CHANGELOG.md
│   │   └── copilot-instructions.md
│   ├── pt-br/                          # Portuguese templates
│   │   ├── CLAUDE.md
│   │   ├── CONTEXT.md
│   │   ├── CHANGELOG.md
│   │   └── copilot-instructions.md
│   └── shared/                         # Language-neutral
│       └── hooks.json
│
├── agents/
│   ├── en/                             # English agents
│   │   ├── Tao.agent.md               # Orchestrator
│   │   ├── Wu.agent.md                # Brainstorm (NEW)
│   │   ├── Shen.agent.md              # Complex Worker (subagent)
│   │   ├── Shen-Architect.agent.md    # Architect (user-invocable)
│   │   ├── Di.agent.md                # DBA
│   │   └── Qi.agent.md                # Deploy
│   └── pt-br/                         # Portuguese agents
│       ├── Tao.agent.md
│       ├── Wu.agent.md
│       ├── Shen.agent.md
│       ├── Shen-Arquiteto.agent.md
│       ├── Di.agent.md
│       └── Qi.agent.md
│
├── phases/                             # Phase templates
│   ├── en/
│   │   ├── PLAN.md.template
│   │   ├── STATUS.md.template
│   │   ├── task.md.template
│   │   └── progress.txt.template
│   ├── pt-br/
│   │   ├── PLAN.md.template
│   │   ├── STATUS.md.template
│   │   ├── tarefa.md.template
│   │   └── progress.txt.template
│   └── shared/
│       ├── DISCOVERY.md.template       # Brainstorm
│       ├── DECISIONS.md.template       # IBIS format
│       └── BRIEF.md.template           # Synthesis
│
├── hooks/
│   ├── install-hooks.sh                # Installs git hooks
│   ├── pre-commit.sh                   # Orchestrator
│   ├── lint-hook.sh                    # Generic (reads tao.config.json)
│   └── context-hook.sh                 # SessionStart (generic)
│
├── scripts/
│   ├── i18n-diff.sh                    # Anti-drift between languages
│   └── new-phase.sh                    # Creates phase directory structure
│
└── docs/brainstorm/                    # TAO's own brainstorm (meta)
    ├── BRIEF.md
    ├── DISCOVERY.md                    # (referência, vive em GSD/)
    └── DECISIONS.md                    # (referência, vive em GSD/)
```

**Total estimado: ~45 arquivos** (vs 22 do GSD — +23 por bilíngue + novos)

---

## Grupos de Tarefas

### SPRINT 1 — Infraestrutura (P0)
> Fundação. Sem isso nada funciona.

- **T01** — `tao.config.json` schema + example — Define a estrutura JSON que elimina todos os [SUBSTITUIR]. Corrige 42 hardcodes. (D16)
- **T02** — `install.sh` interativo — Pergunta 5 coisas (lang, project_name, stack, git_branch, models), gera `tao.config.json` e copia templates do idioma correto. Corrige B2 (npm phantom), B3 (hooks nunca instalados), B8 (sem perguntas). (D16, D20, D14)
- **T03** — `tao.sh` monitor — Adaptar `gsd.sh` (347 linhas): ler config de `tao.config.json`, suportar phase prefix configurável, i18n de mensagens via `i18n/{lang}.sh`. (D16, D20)
- **T04** — `hooks/install-hooks.sh` — Instala git hooks (pre-commit, post-commit). Corrige B3 CRITICAL. (D9)
- **T05** — `hooks/pre-commit.sh` orquestrador — Pipeline modular: lê `tao.config.json`, roda lint por extensão, checa syntax. (D9, D19)
- **T06** — `hooks/lint-hook.sh` genérico — PostToolUse hook que lê `tao.config.json → lint_commands`, roda lint por extensão. Substitui `php-lint-hook.sh`. (D19, D16)
- **T07** — `hooks/context-hook.sh` — SessionStart hook genérico: lê `tao.config.json → paths.phases`, suporta phase prefix. Adaptar de `gsd-context-hook.sh`. (D16)
- **T08** — `.gitignore` + `LICENSE` MIT + estrutura de diretórios — Scaffold base do repo.

### SPRINT 2 — Templates Core (P0)
> Templates que o installer copia para o projeto do usuário.

- **T09** — `templates/en/CLAUDE.md` — Reescrever: zero [SUBSTITUIR], usa `tao.config.json` references, remove Dark Mode leak (B4), adiciona ABEX protocol, R0-R7 genéricos. (D11, D10, B4)
- **T10** — `templates/en/CONTEXT.md` — Adaptar com onboarding mode (`status: new_project`). (D14)
- **T11** — `templates/en/CHANGELOG.md` — Limpo, pronto para uso.
- **T12** — `templates/en/copilot-instructions.md` — Ponteiro mínimo para CLAUDE.md + security locks. Zero [SUBSTITUIR]. (D11)
- **T13** — `templates/pt-br/CLAUDE.md` — Adaptação cultural (não tradução mecânica) do T09. (D20)
- **T14** — `templates/pt-br/CONTEXT.md` — Adaptação cultural do T10. (D20)
- **T15** — `templates/pt-br/CHANGELOG.md` — Adaptação cultural do T11. (D20)
- **T16** — `templates/pt-br/copilot-instructions.md` — Adaptação cultural do T12. (D20)
- **T17** — `templates/shared/hooks.json` — VS Code hooks config apontando para lint-hook.sh e context-hook.sh. Language-neutral. (D16)

### SPRINT 3 — Agents Taoístas (P0)
> O coração do TAO. Cada agent é um .agent.md com YAML frontmatter.

- **T18** — `agents/en/Tao.agent.md` — Orchestrator (renomear de GSD.agent.md). Loop contínuo, routing matrix, subagents [Shen, Di, Qi]. Modelo: Sonnet. ~250 linhas. (D1, D8)
- **T19** — `agents/en/Wu.agent.md` — Brainstorm agent (NOVO). 5 modos (DIVERGE/CONVERGE/CAPTURE/SYNTHESIZE/RESUME), IBIS protocol, maturity gate, artefatos (DISCOVERY/DECISIONS/BRIEF). Modelo: Opus. ~350 linhas. (D3, D15)
- **T20** — `agents/en/Shen.agent.md` — Complex Worker subagent (renomear de Opus-Worker). Context-isolated, recebe prompt do @Tao. Modelo: Opus. (D1)
- **T21** — `agents/en/Shen-Architect.agent.md` — Architect user-invocable (renomear de Arquiteto). Acesso direto fora do loop. Modelo: Opus. Subagents: [Di, Qi]. (D1)
- **T22** — `agents/en/Di.agent.md` — DBA subagent (renomear de DBA). Generic DB patterns. Modelo: GPT-4.1. (D1)
- **T23** — `agents/en/Qi.agent.md` — Deploy subagent (renomear de Deploy). Git operations. Modelo: GPT-4.1. (D1)
- **T24** — `agents/pt-br/Tao.agent.md` — Adaptação cultural do T18. (D20)
- **T25** — `agents/pt-br/Wu.agent.md` — Adaptação cultural do T19. (D20)
- **T26** — `agents/pt-br/Shen.agent.md` — Adaptação cultural do T20. (D20)
- **T27** — `agents/pt-br/Shen-Arquiteto.agent.md` — Adaptação cultural do T21. (D20)
- **T28** — `agents/pt-br/Di.agent.md` — Adaptação cultural do T22. (D20)
- **T29** — `agents/pt-br/Qi.agent.md` — Adaptação cultural do T23. (D20)

### SPRINT 4 — Phase Templates + Brainstorm (P1)
> Templates de fase e brainstorm.

- **T30** — `phases/en/` — 4 templates (PLAN, STATUS, task, progress). Adaptar de `estrutura-fases/`. Generic, zero hardcode. (D16)
- **T31** — `phases/pt-br/` — 4 templates (PLAN, STATUS, tarefa, progress). Adaptação cultural. (D20)
- **T32** — `phases/shared/` — 3 brainstorm templates (DISCOVERY, DECISIONS, BRIEF). IBIS format em DECISIONS. Maturity checklist em BRIEF. Language-neutral (EN). (D3, D10)

### SPRINT 5 — Scripts Utilitários (P1)
> Tools que complementam o sistema.

- **T33** — `update-models.sh` — Lê `tao.config.json`, atualiza modelos nos .agent.md. Para uso pós-install ou quando modelos mudam. (D16)
- **T34** — `scripts/i18n-diff.sh` — Compara arquivos EN vs PT-BR por hash. Reporta drift. (D20)
- **T35** — `scripts/new-phase.sh` — Cria diretório de fase com templates do idioma correto. Lê `tao.config.json`. (D16, D20)

### SPRINT 6 — Documentação (P1)
> README, GETTING-STARTED, ARCHITECTURE. A porta de entrada.

- **T36** — `README.md` (EN) — Hero, 30s pitch, quickstart, features, agent table, model costs, license. Com mermaid diagram. Crédito ao GSD via "Inspiration" section. ~200 linhas. (D13)
- **T37** — `README.pt-br.md` — Adaptação cultural do T36. (D20)
- **T38** — `docs/GETTING-STARTED.md` — Accordion onboarding L1→L5. Cada nível em `<details>`. L1: "install and go", L5: "why IBIS, how to customize agents". ~300 linhas. (D13, D14)
- **T39** — `docs/ARCHITECTURE.md` — Adaptar de GSD ARCHITECTURE.md (585 linhas). Renomear termos, adicionar diagrama TAO. (D8)
- **T40** — `docs/ECONOMICS.md` — Model costs, routing strategy, how to minimize Opus usage. (D15, D17)
- **T41** — `docs/GUARDRAILS.md` — 7 validation layers (V1-V7, 23 gates). O que cada uma faz, como customizar. (D7, D8)
- **T42** — `CONTRIBUTING.md` — How to contribute, PR guidelines, i18n process. EN with PT-BR section.

### SPRINT 7 — Verificação Final (P2)
> Tudo testado, tudo funcional, tudo auditado.

- **T43** — Smoke Test: `install.sh` end-to-end — Criar diretório temp, rodar installer com respostas, verificar que TODOS os arquivos foram criados nos paths corretos, config gerada, hooks instalados.
- **T44** — Smoke Test: `tao.sh` — Testar `status`, `report`, `dry-run`, `pause` com um projeto fake.
- **T45** — Smoke Test: hooks — Testar pre-commit com arquivo com erro de syntax, verificar que bloqueia. Testar context-hook, verificar output JSON.
- **T46** — Consistency Check — Verificar que: todo [SUBSTITUIR] foi eliminado, todo agent referencia CLAUDE.md (não duplica), todo hardcode PT-BR tem equivalente EN, `tao.config.json.example` tem TODAS as keys usadas pelos scripts.
- **T47** — i18n-diff.sh validation — Rodar `i18n-diff.sh` nos templates EN vs PT-BR. Verificar que reporta 0 drift (ou drift intencional documentado).
- **T48** — README review — Ler README como um dev que nunca viu o projeto. Responder: (1) Entendi o que é em 30s? (2) Sei como instalar? (3) Sei o que cada agent faz? (4) Sei quanto custa?

---

## Ordem de Execução

```
SPRINT 1 (P0 — Infraestrutura):
  T08 → T01 → T02 → T03 → T04 → T05 → T06 → T07

SPRINT 2 (P0 — Templates Core):
  T09 → T10 → T11 → T12 → T17
  T13 → T14 → T15 → T16   (pode ser paralelo ao EN)

SPRINT 3 (P0 — Agents):
  T18 → T19 → T20 → T21 → T22 → T23
  T24 → T25 → T26 → T27 → T28 → T29   (pode ser paralelo ao EN)

SPRINT 4 (P1 — Phase Templates):
  T30 → T31 → T32

SPRINT 5 (P1 — Scripts):
  T33 → T34 → T35

SPRINT 6 (P1 — Docs):
  T36 → T37 → T38 → T39 → T40 → T41 → T42

SPRINT 7 (P2 — Verification):
  T43 → T44 → T45 → T46 → T47 → T48
```

**Dependências cross-sprint:**
- T02 (install.sh) depende de T01 (config schema) e T08 (scaffold)
- T03 (tao.sh) depende de T01 (config schema)
- T05 (pre-commit) depende de T04 (install-hooks)
- T06 (lint-hook) depende de T01 (config schema)
- T18-T29 (agents) dependem de T09 (CLAUDE.md) por referência
- T33 (update-models) depende de T01 (config) e T18-T29 (agents existirem)
- T43-T48 (verification) dependem de ALL sprints 1-6

---

## Mapeamento Decisão → Tarefa

Toda decisão IBIS tem pelo menos 1 tarefa que a implementa:

| Decisão | Tarefas |
|---|---|
| D1 — Core + Addons | T01, T18-T29 (agents no core) |
| D3 — Brainstorm differentiator | T19, T25, T32 |
| D5 — Skills TAO-specific | T19 (Wu has brainstorm skill built-in), T38 |
| D6 — Scope MVP | Todo o plano (escopo definido) |
| D7 — Enforcement = P0 | T04, T05, T06 |
| D8 — 3 Layers + Guardrails | T39, T41 |
| D9 — Modular pre-commit | T05 (orquestrador), T06 (lint module) |
| D10 — ABEX = protocol | T09 (CLAUDE.md inclui ABEX), T18 (Tao loop step 9) |
| D11 — CLAUDE.md = source | T09, T12, T13, T16 |
| D13 — Accordion onboarding | T38 |
| D14 — Auto onboarding mode | T02, T10, T14 |
| D15 — Sonnet decomposes, Opus deliberates | T18 (routing matrix), T40 |
| D16 — tao.config.json | T01, T02, T03, T06, T07, T33, T35 |
| D17 — 3 tiers compatibility | T40 (documented), T39 |
| D18 — MCP addon v0.2 | Scope out (documented in T41) |
| D19 — Generic lint | T06 |
| D20 — Bilingual | T13-T16, T24-T29, T31, T34, T37 |
| TAO naming | ALL (nomenclature across all files) |

**Decisões sem tarefa (scope out, documentadas):**
- D2 (superseded by D20)
- D12 (superseded by D13)
- D18 (v0.2, documented in GUARDRAILS.md)

---

## Critério de Conclusão — TAO v0.1

- [ ] Todos os P0 (Sprints 1-3) concluídos — 29 tarefas
- [ ] Todos os P1 (Sprints 4-6) concluídos — 13 tarefas
- [ ] Todos os P2 (Sprint 7) concluídos — 6 tarefas
- [ ] `install.sh` testado end-to-end em diretório limpo
- [ ] `tao.sh` testado com projeto fake
- [ ] Hooks testados (pre-commit bloqueia, context injeta)
- [ ] Zero [SUBSTITUIR] em qualquer arquivo
- [ ] `i18n-diff.sh` reporta 0 drift não-intencional
- [ ] README compreensível em 30 segundos
- [ ] Repo limpo, pronto para `git push origin main`

---

## Bugs Corrigidos (mapeamento)

| Bug | Severidade | Tarefa |
|---|---|---|
| B1 — Step numbering (5,6 duplicados) | LOW | T02 |
| B2 — npm phantom package | CRITICAL | T02 (eliminado — skills copiadas direto) |
| B3 — Git hooks never installed | CRITICAL | T02, T04 |
| B4 — "Dark Mode" RevelaME leak | HIGH | T09, T13 |
| B5 — gsd.sh doesn't read config | MEDIUM | T03 |
| B6 — `fase-` prefix hardcoded | HIGH | T01, T03, T07 |
| B7 — No CHANGELOG template | LOW | T11, T15 |
| B8 — No interactive questions | MEDIUM | T02 |

---

## Riscos e Mitigações

| Risco | Prob. | Mitigação |
|---|---|---|
| Bilíngue atrasa lançamento | Média | Escape: lançar EN-only, PT-BR em v0.1.1 |
| Agent YAML frontmatter muda | Baixa | Documentado em ARCHITECTURE. VS Code é estável. |
| Hooks JSON schema muda | Baixa | gsd-hooks.json é simples. Monitorar release notes. |
| Wu.agent.md fica muito complexo | Média | Manter ~350 linhas. IBIS jargão opt-in. |
| install.sh não funciona em todas as shells | Média | Testar bash 4+ e zsh. `#!/usr/bin/env bash`. |

---

## tao.config.json — Schema (referência para T01)

```jsonc
{
  "project": {
    "name": "MyProject",
    "description": "One-line description",
    "language": "en"          // "en" | "pt-br"
  },
  "models": {
    "orchestrator": "Claude Sonnet 4.6 (copilot)",
    "complex_worker": "Claude Opus 4.6 (copilot)",
    "free_tier": "GPT-4.1 (copilot)"
  },
  "git": {
    "dev_branch": "dev",
    "main_branch": "main",
    "auto_push": true
  },
  "paths": {
    "source": "src/",
    "docs": "docs/",
    "phases": "docs/phases/",
    "phase_prefix": "phase-"   // "phase-" (EN) | "fase-" (PT-BR)
  },
  "lint_commands": {
    ".php": "php -l {file}",
    ".py": "python3 -m py_compile {file}",
    ".ts": "npx tsc --noEmit",
    ".js": "node --check {file}",
    ".rb": "ruby -c {file}",
    ".go": "go vet {file}",
    ".rs": "cargo check"
  },
  "compliance": {
    "require_skill_check": true,
    "require_context_read": true,
    "require_changelog": true,
    "abex_enabled": true
  },
  "doc_sync": {
    "enabled": false,         // opt-in (addon level)
    "script": "scripts/doc-sync.sh"
  }
}
```

---

## 3× AUDIT RESULTS (2026-03-27 10:08)

### Audit 1/3 — Completeness (Every decision → task?)
- **20/20 IBIS decisions** → all have corresponding tasks
- **8/8 bugs** → all have fixes mapped
- **12/12 disqualifiers** → all resolved
- **10/10 gaps** → all covered
- **PASS ✅**

### Audit 2/3 — Feasibility (Every task is testable?)
- **48/48 tasks** → all have verifiable acceptance criteria
- **0 blockers** found
- **2 advisories:** T19 (Wu) requires high creativity (Opus assigned); T38 accordions have mobile risk (escape condition exists)
- **PASS ✅**

### Audit 3/3 — Dependencies (No cycles, no missing prereqs?)
- **DAG topology verified** — acyclic, flows S1→S7
- **0 circular dependencies**
- **0 missing prerequisites**
- **1 observation:** install.sh (S1) copies agents (S3) — logic is independent of content; full test in T43 (S7)
- **PASS ✅**

### Verdict: **PLAN APPROVED — ready for execution**

---

**Criado em:** 2026-03-27 10:08
**Auditoria 3×:** 2026-03-27 10:08
**Source:** BRIEF.md (maturity 7/7) → 20 decisões IBIS
**Executor:** @Tao (Sonnet) para maioria | @Shen (Opus) para T19 (Wu agent) e T09 (CLAUDE.md rewrite)
