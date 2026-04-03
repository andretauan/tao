<div align="center">

# 道 TAO

<img src="docs/tao.png" alt="TAO — De vibe coding para engenharia" width="100%" />

**De vibe coding para engenharia.**

*Você diz "executar". O TAO pega a tarefa, roteia o modelo certo, implementa, faz lint, commita — e pula pra próxima. Sem prompts. Sem babá. Sem caos.*

Um framework de desenvolvimento AI-nativo para VS Code Copilot que substitui prompt-e-reza por um **pipeline de engenharia auto-executável** — brainstorm, planejamento, execução em loop.

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilíngue](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilíngue)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)
[![v1.0.1](https://img.shields.io/badge/version-1.0.1-green.svg)](https://github.com/andretauan/tao/releases/tag/v1.0.1)

[🇺🇸 Read in English](README.md)

</div>

---

## Vibe Code vs TAO Code

Você já viu — ou viveu. Alguém abre o Copilot, digita "me faz um app", recebe uma parede de código, aceita, digita outro prompt, aceita de novo. Trinta prompts depois tem um projeto que *meio que* funciona mas ninguém planejou, ninguém revisou e ninguém consegue manter.

Isso é **vibe coding** — construir software na vibe. Sem estrutura. Sem plano. Sem controle de qualidade. Só prompts e esperança.

Funciona pra demos. Não funciona pra nada real.

**TAO Code é o oposto.** É uma mudança de mentalidade:

> **Não só faça prompts. Pense primeiro. Planeje primeiro. Depois deixe a máquina executar — com guardrails.**

Você ainda usa IA pra tudo. Ainda escreve zero (ou mínimo) código na mão. Mas ao invés de uma cadeia caótica de prompts, você tem:

- **Uma fase de brainstorm** onde a IA explora seu problema *antes* de escrever uma linha sequer
- **Um plano estruturado** onde cada tarefa é definida, delimitada e ordenada — antes de qualquer código existir
- **Um loop de execução autônomo** que implementa cada tarefa, uma por uma, com checks de lint, quality gates e commits atômicos
- **Artefatos de engenharia reais** — logs de decisão, rastreabilidade, changelogs — não apenas "compilou, shipa"

**O resultado é o mesmo:** IA constrói seu projeto. **O processo é completamente diferente:** organizado, rastreável, profissional.

Você não precisa saber programar pra usar o TAO. Mas se usar o TAO, vai começar a *pensar* como engenheiro — porque o framework força estrutura antes de código.

**Essa é a evolução. De vibe code para TAO code.**

---

## Por que TAO

### 🔄 Loop Autônomo

Você diz `executar`. O TAO pega a tarefa, implementa, faz lint, commita — **e pula pra próxima sem parar.** Vai tomar um café. Volta pra 10 commits atômicos, cada um rastreado a uma tarefa planejada.

Chega de babysitting prompt-por-prompt. Um comando roda a fase inteira.

### 🔒 Qualidade à Prova de Bala

Cada commit passa por enforcement em camadas:

- **L0 — Git hooks** bloqueiam violações no commit: linting, validação de mensagem, proteção de branch, validação de brainstorm/plano, scan de segurança ABEX. São scripts bash — determinísticos, sem IA.
- **L1 — Agent hooks** dão feedback em tempo real durante sessões: enforcement de ler-antes-de-editar (R5), detecção de comandos perigosos, auto-lint após edições, tracking de contexto. Também scripts bash determinísticos via hooks PostToolUse do VS Code.
- **L2 — Instruções dos agentes** cobrem critérios subjetivos: roteamento de modelos, scoring ABEX 3 passadas, seleção de skills. Dependem de o agente seguir as instruções.

**~75% das regras de enforcement são determinísticas (L0 + L1)** — rodam como scripts bash, não "por favor lembre de fazer lint." Código que não passa nos gates automatizados não é enviado. Os ~25% restantes (L2) dependem de compliance do agente com instruções do prompt.

### 💰 60% de Redução de Custo

Roteamento inteligente envia cada tarefa pro modelo de IA mais barato que dá conta:

- Coisa simples (CRUD, forms, testes) → **Sonnet** (1x custo)
- Coisa complexa (arquitetura, segurança) → **Opus** (3x custo)
- Operações de banco e git → **GPT-4.1** (grátis)

Sem roteamento: 10 tarefas × Opus = 30x custo. Com TAO: 2 Opus (6x) + 6 Sonnet (6x) + 2 grátis (0x) = **12x custo. 60% de economia.**

### 🛡️ Escudo contra Rate Limit

O GitHub Copilot te bloqueia quando você gasta requests premium rápido demais — mesmo no Pro+. O TAO combate isso em três níveis:

1. **Prevenção** — roteamento mantém ~60-80% dos requests em modelos baratos/grátis
2. **Fallback** — se o modelo primário for bloqueado, a cadeia de modelos do Execute-Tao automaticamente cai pro GPT-4.1 (grátis) e continua rodando
3. **Operações zero-custo** — hooks, lint e operações git são scripts determinísticos que nunca consomem requests premium

Você estica sua cota mensal de ~2 sessões para ~4+ sessões.

---

## A Ideia Central

Você diz à IA **o que** construir. O TAO cuida do **como**, **quando** e **em que ordem** — em loop contínuo, sem parar pra te perguntar nada.

```
Sem TAO (vibe coding):                Com TAO:
──────────────────────────             ────────
prompt → espera → review              "executar"
prompt → espera → review                ↓
prompt → espera → review              ┌──────────────────────────┐
prompt → espera → review              │ Pega tarefa              │
prompt → espera → review              │ → Roteia pro modelo certo│
prompt → espera → corrige             │ → Lê contexto & arquivos │
prompt → espera → review              │ → Implementa             │
prompt → espera → re-prompt           │ → Lint & valida          │
prompt → espera → torce pra dar certo │ → Commita                │
(você babysita 30+ prompts)           │ → Próxima tarefa ← LOOP  │
                                      └──────────────────────────┘
                                      (você revisa o resultado pronto)
```

**Um comando. Fase completa. Cada tarefa commitada individualmente com quality gates.**

---

## 🔄 O Loop — Motor do TAO

O loop de execução é o que diferencia o TAO de templates de prompt ou wrappers de agente. Quando você diz `executar`, isso roda **automaticamente, em sequência, sem pausar**:

```
 ┌─→ 1. CHECK PAUSA    .tao-pause presente? → PARA
 │   2. LÊ STATUS      Parseia STATUS.md → acha próxima ⏳
 │   3. ROTEIA          Tarefa simples → Sonnet (1x)
 │                      Tarefa complexa → Opus via @Shen (3x)
 │                      Banco de dados → @Di (grátis)
 │                      Git ops → @Qi (grátis)
 │   4. LÊ & IMPLEMENTA  Lê arquivos necessários → codifica → testa
 │   5. QUALITY GATE    Roda linter → corrige se falhou (até 3 tentativas)
 │   6. COMMITA         git add (arquivos específicos) → commit → push
 │   7. AVANÇA          Marca ⏳ → ✅ no STATUS.md
 └─← 8. LOOP            Volta pro passo 1 — imediatamente
```

O loop roda até que **toda tarefa da fase esteja ✅** — ou você acione o kill switch (`.tao-pause`).

**O que isso significa na prática:** você começa uma fase com 10 tarefas, diz "executar", e volta pra encontrar 10 commits atômicos, cada um com lint passando, cada um rastreado a uma tarefa planejada. Se algo falhar 3 vezes, o loop escala automaticamente pra um modelo mais potente — ele nunca para e nunca te pede pra intervir.

---

## ☯️ Pensar → Planejar → Executar

O TAO estrutura todo projeto em três camadas. Este é o cerne da mentalidade "TAO Code" — **pense antes de codar, planeje antes de construir:**

**1. PENSAR — `@Brainstorm-Wu` (Opus)**

Antes de qualquer código existir, Wu explora o espaço do problema. Produz três documentos:
- **DISCOVERY.md** — exploração aberta do domínio, restrições e possibilidades
- **DECISIONS.md** — decisões estruturadas usando o protocolo IBIS (posição → argumento → contra-argumento)
- **BRIEF.md** — síntese compacta com gate de maturidade (≥5 de 7 critérios para prosseguir)

*Pense como o esboço do arquiteto antes da construção começar.*

**2. PLANEJAR — `@Brainstorm-Wu` (Opus)**

A partir do BRIEF, Wu cria um plano acionável:
- **PLAN.md** — o que construir e por quê, com rastreabilidade de decisões
- **STATUS.md** — tabela de tarefas com ordem, complexidade e executor designado
- **Arquivos de tarefa** — especificações individuais (objetivo, arquivos a tocar, passos, critérios de aceite)

*Pense como a planta — cada cômodo, cada parede, cada fio, definido antes do primeiro prego.*

**3. EXECUTAR — `@Executar-Tao` (Sonnet)**

O Tao entra no loop autônomo. Pega a primeira tarefa pendente, lê os arquivos relevantes, implementa, roda lint, commita, e imediatamente vai pra próxima. Tarefas complexas são automaticamente roteadas para @Shen (Opus). Tarefas de banco vão pro @Di (grátis).

*Pense como a equipe de obra — seguindo a planta, cômodo por cômodo, com inspeções de qualidade a cada passo.*

**Por que isso importa:** Em vibe coding, a IA escreve código baseado na sua vibe — sem plano, sem estrutura, sem rastreabilidade. No TAO Code, cada linha de código rastreia até uma decisão que rastreia até uma exploração. Quando algo quebra, você sabe *por que* foi construído daquele jeito.

---

## 🤖 Os Agentes

Seis agentes especializados, cada um travado em um modelo de IA específico — sem troca manual, sem surpresas de custo:

| Agente | Modelo | Custo | Papel |
|--------|--------|-------|-------|
| **@Executar-Tao** 道 | Sonnet 4.6 | 1x | **O loop.** Pega tarefas, roteia modelos, implementa, faz lint, commita, repete. |
| **@Brainstorm-Wu** 悟 | Opus 4.6 | 3x | Pensa e planeja. Explora ideias, documenta decisões, cria planos estruturados. |
| **@Shen** 深 | Opus 4.6 | 3x | Worker complexo. Debug difícil, arquitetura, segurança. Chamado pelo Tao quando necessário. |
| **@Di** 地 | GPT-4.1 | grátis | DBA. Migrações, design de schema, otimização de queries. |
| **@Qi** 气 | GPT-4.1 | grátis | Deploy. Git commit, push, merge. |

**@Investigar-Shen** é uma variante invocável do @Shen — use para investigações diretas fora do loop.

**Como trabalham juntos:** Você fala com **Wu** (brainstorm & planejar) e **Tao** (executar). O Tao automaticamente chama **Shen** pra tarefas difíceis, **Di** pra banco de dados, e **Qi** pra operações git. Você nunca troca manualmente entre agentes durante a execução.

---

## 🚀 Início Rápido

### O que você precisa

- **VS Code** com **GitHub Copilot** (Agent Mode habilitado)
- **Git** e **Python 3** (3.8+)
- macOS, Linux ou WSL2 (Windows CMD nativo não suportado)

### Instalar (2 minutos)

```bash
# Clone o TAO (uma vez, em qualquer lugar)
git clone https://github.com/andretauan/tao.git ~/TAO

# Vá pro seu projeto (novo ou existente)
cd /caminho/do/seu-projeto

# Rode o instalador
bash ~/TAO/install.sh .
```

O instalador faz 5 perguntas (idioma, nome do projeto, descrição, branch, stack de lint) e gera tudo — agentes, hooks, skills, config, templates.

Depois habilite os hooks do VS Code (configuração única):
```
Configurações → busque "chat.useCustomAgentHooks" → habilite
```

### Seu primeiro projeto (3 passos)

**Passo 1 — Brainstorm.** No Copilot Chat, selecione `@Brainstorm-Wu` e diga:

> brainstorm fase 01 — quero construir [descreva seu projeto]

Wu explora o problema, documenta decisões e produz um BRIEF.

**Passo 2 — Planejar.** Ainda no `@Brainstorm-Wu`:

> planejar fase 01

Wu cria PLAN.md, STATUS.md e arquivos individuais de tarefas com especificações completas. Revise e ajuste antes de prosseguir.

**Passo 3 — Executar.** Selecione `@Executar-Tao` e diga:

> executar

**É isso.** O Tao entra no loop autônomo — pega a primeira tarefa, implementa, faz lint, commita, e pula pra próxima sem parar. Volte pra encontrar commits atômicos pra cada tarefa, cada um rastreado ao plano.

---

## 📦 O Que é Instalado

<details>
<summary>Clique para expandir a árvore de arquivos</summary>

```
seu-projeto/
├── CLAUDE.md                      # Regras para todos os agentes (contexto do projeto)
├── .github/
│   ├── copilot-instructions.md    # Auto-carregado pelo Copilot toda sessão
│   ├── instructions/
│   │   ├── tao.instructions.md    # Instruções TAO (sempre carregado)
│   │   ├── tao-code.instructions.md  # Auto-injetado em arquivos de código
│   │   ├── tao-test.instructions.md  # Auto-injetado em arquivos de teste
│   │   ├── tao-api.instructions.md   # Auto-injetado em rotas/APIs
│   │   └── tao-db.instructions.md    # Auto-injetado em DB/migrações
│   ├── agents/                    # 6 arquivos de agente (3 user-facing + 3 subagents)
│   ├── hooks/
│   │   └── hooks.json             # Hooks SessionStart + PostToolUse
│   ├── skills/                    # 14 skills TAO (auto-descobertas pelo VS Code)
│   │   ├── INDEX.md               # Catálogo de skills — ponte R3
│   │   ├── tao-onboarding/        # Guia do framework para novos usuários
│   │   ├── tao-plan-writing/      # Metodologia de decomposição de tarefas
│   │   ├── tao-brainstorm/        # Metodologia IBIS de brainstorm
│   │   ├── tao-code-review/       # Code review 6 eixos
│   │   ├── tao-security-audit/    # Checklist OWASP Top 10
│   │   ├── tao-test-strategy/     # Pirâmide de testes + cobertura
│   │   ├── tao-refactoring/       # Protocolo de refatoração segura
│   │   ├── tao-clean-code/        # Princípios SOLID, DRY, KISS
│   │   ├── tao-architecture-decision/  # ADR + matriz de trade-offs
│   │   ├── tao-api-design/        # Convenções REST
│   │   ├── tao-database-design/   # Padrões de schema + migrações
│   │   ├── tao-git-workflow/      # Convenções de commit + estratégia de branch
│   │   ├── tao-debug-investigation/  # Protocolo de debugging estruturado
│   │   └── tao-performance-audit/ # Profiling + otimização
│   └── tao/
│       ├── tao.config.json        # Config central (modelos, lint, git, paths)
│       ├── CONTEXT.md             # Estado ativo — persiste entre sessões
│       ├── CHANGELOG.md           # Changelog estruturado
│       ├── RULES.md               # Referência de regras invioláveis (7 LOCKs de segurança)
│       ├── scripts/               # Scripts shell (hooks, gates, validadores)
│       └── phases/                # Templates de fase (por idioma)
```

Quando uma fase é criada:

```
docs/phases/fase-01/
├── PLAN.md                        # O que construir e por quê
├── STATUS.md                      # Tabela de tarefas: ⏳ pendente, ✅ feita, ❌ bloqueada
├── progress.txt                   # Log de sessão
├── brainstorm/
│   ├── DISCOVERY.md               # Exploração aberta do espaço do problema
│   ├── DECISIONS.md               # Decisões estruturadas em IBIS
│   └── BRIEF.md                   # Síntese compacta (gate de maturidade ≥5/7)
└── tarefas/
    ├── 01-setup-banco.md          # Spec completa: objetivo, arquivos, passos, critérios
    ├── 02-criar-api.md
    └── ...
```

</details>

---

## 🧠 Biblioteca de Skills

O TAO vem com **14 skills embutidas** + **4 arquivos de instrução** — conhecimento especializado que ativa automaticamente. Zero ação do usuário. Sem comandos pra decorar. O conhecimento certo carrega no momento certo.

**Duas camadas de enforcement trabalham juntas:**

**Camada 1 — Arquivos de instrução** (`.instructions.md` com padrões glob `applyTo`):
O VS Code injeta essas regras em todo arquivo que faz match — automaticamente, antes do agente escrever uma linha:

| Arquivo | Ativa em | O que impõe |
|---------|----------|-------------|
| `tao-code` | Todos arquivos de código (`.py`, `.ts`, `.go`, etc.) | Clean code + segurança OWASP + self-review 6 eixos |
| `tao-test` | Arquivos de teste (`*.test.*`, `*.spec.*`, `test_*`) | Pirâmide de testes + edge cases + padrão AAA |
| `tao-api` | Arquivos de rota/controller (`routes/`, `api/`, etc.) | Convenções REST + status codes + formato de erro |
| `tao-db` | Arquivos SQL/model/migração | Regras de schema + estratégia de index + segurança de migração |

**Camada 2 — Skills** (`.github/skills/` seguindo [agentskills.io](https://agentskills.io)):
Conhecimento profundo auto-descoberto pelo VS Code. Carregado sob demanda quando o contexto faz match:

| Skill | O que faz |
|-------|-----------|
| `tao-onboarding` | Guia novos usuários pelo setup e primeira execução |
| `tao-plan-writing` | Decomposição expert de tarefas para PLAN.md |
| `tao-brainstorm` | Brainstorm IBIS com gate de maturidade |
| `tao-code-review` | Review estruturado 6 eixos (correção → padrões) |
| `tao-security-audit` | Checklist OWASP Top 10 com passos de remediação |
| `tao-test-strategy` | Pirâmide de testes, padrões de edge case, metas de cobertura |
| `tao-refactoring` | Refatoração segura com checklist pré-voo |
| `tao-clean-code` | SOLID, DRY, KISS — conhecimento base para todo código |
| `tao-architecture-decision` | Template ADR com matriz de análise de trade-offs |
| `tao-api-design` | Convenções REST, status codes, paginação, erros |
| `tao-database-design` | Padrões de schema, segurança de migração, estratégia de indexação |
| `tao-git-workflow` | Convenções de commit TAO e estratégia de branch |
| `tao-debug-investigation` | Protocolo hipótese → isolamento → correção → verificação |
| `tao-performance-audit` | Metodologia de profiling e padrões de otimização |

Todas as 14 skills são **auto-only** (`user-invocable: false`). Sem comandos `/slash` pra decorar.

**Sem conflitos:** Todas as skills usam o prefixo `tao-`. Suas próprias skills de projeto convivem sem interferência.

**Adicione as suas:** Crie uma pasta em `.github/skills/nome-da-skill/` com um `SKILL.md`. Veja [agentskills.io](https://agentskills.io) para o formato.

---

## 🔐 Arquitetura de Enforcement

O TAO impõe qualidade e segurança através de **10 hooks** (scripts shell determinísticos) + **7 LOCKs de segurança** + instruções dos agentes:

### Hooks (determinísticos — sem IA)

| Hook | Gatilho | O que faz |
|------|---------|-----------|
| `pre-commit.sh` | Git commit | Lint, proteção de branch, scan ABEX, gates de validação |
| `pre-push.sh` | Git push | Bloqueia push para main/master, bloqueia force push |
| `commit-msg.sh` | Git commit | Valida formato conventional commit (`tipo(escopo): descrição`) |
| `lint-hook.sh` | PostToolUse | Roda linter configurado após cada edição de arquivo |
| `enforcement-hook.sh` | PostToolUse | Compliance R0, R5 ler-antes-de-editar, detecção de comandos perigosos |
| `context-hook.sh` | SessionStart | Carrega contexto do projeto e rastreia operações de arquivo |
| `abex-hook.sh` | PostToolUse | Scan de segurança ABEX automatizado após edições de código |
| `brainstorm-hook.sh` | PostToolUse | Dispara validação de brainstorm em edições de BRIEF/DECISIONS/DISCOVERY |
| `plan-hook.sh` | PostToolUse | Dispara validação de plano em edições de PLAN.md/STATUS.md |
| `install-hooks.sh` | Setup | Instala git hooks em `.git/hooks/` |

### LOCKs de Segurança (7 regras invioláveis)

| Lock | Regra |
|------|-------|
| **LOCK 1 — ESCOPO** | Modificar apenas arquivos-fonte do projeto. Nunca: `CLAUDE.md`, `.github/workflows/`, `vendor/`, `node_modules/` |
| **LOCK 2 — BRANCH** | Somente branch `dev`. Nunca `git push origin main`, `--force`, `reset --hard` |
| **LOCK 3 — DESTRUTIVO** | Nunca `rm -rf`, `DROP TABLE`, `TRUNCATE`, `DELETE FROM` sem WHERE |
| **LOCK 4 — SCHEMA** | Operações que alteram schema → PARE → documente → checkpoint |
| **LOCK 5 — PAUSA** | `.tao-pause` existe → parada total imediata |
| **LOCK 6 — COMMIT** | Nunca commitar com `--no-verify`. 1 commit = 1 tarefa. |
| **LOCK 7 — EXTERNO** | Nunca fazer requisições HTTP externas ou instalar pacotes sem aprovação |

### Protocolo ABEX (Quality Gate)

O ABEX opera em dois níveis:
1. **Automatizado** — `abex-gate.sh` faz detecção de padrões de segurança via regex (SQL injection, XSS, secrets hardcoded, etc.) via hook pre-commit e PostToolUse. Determinístico.
2. **Julgamento do agente** — três passadas manuais de revisão (Segurança, Segurança do Usuário, Performance) realizadas pelo agente após cada tarefa. Baseado em instrução (L2).

### Auditoria Forense

Quando todas as tarefas da fase estão completas, o gate do `pre-commit.sh` executa o `faudit.sh` — uma auditoria forense que varre cada arquivo commitado procurando padrões de segurança, completude de documentação e integridade estrutural. É uma varredura final que captura problemas que commits individuais possam ter perdido.

---

## 💰 Economia de Modelos

O loop roteia cada tarefa pro modelo de IA mais barato que dá conta — automaticamente, sem troca manual:

| Tipo de Tarefa | Modelo | Custo | Exemplos |
|----------------|--------|-------|----------|
| Trabalho rotineiro | Sonnet 4.6 | **1x** | Forms, endpoints, CSS, testes, bug fixes |
| Trabalho complexo | Opus 4.6 | **3x** | Arquitetura, segurança, race conditions, design de sistema |
| Operações de banco | GPT-4.1 | **grátis** | Migrações, schema, otimização de queries |
| Operações git | GPT-4.1 | **grátis** | Commit, push, merge |
| Brainstorm & planejamento | Opus 4.6 | **3x** | Vale o custo — um plano ruim custa muito mais em retrabalho |

**Fase típica — 10 tarefas:**

Sem roteamento: 10 tarefas × Opus (3x) = **30x custo**.
Com TAO: 2 Opus (6x) + 6 Sonnet (6x) + 2 grátis (0x) = **12x custo — 60% de economia**.

Veja [ECONOMICS.md](docs/ECONOMICS.md) para a matemática completa de custos.

---

## 🛡️ Escudo contra Rate Limit

O GitHub Copilot limita requests premium — mesmo em planos Pro+. Use demais um modelo caro e você fica **bloqueado até a cota resetar**. O TAO ataca isso em três níveis:

**Nível 1 — Prevenção (roteamento inteligente)**
O loop roteia ~60-80% das tarefas pra Sonnet (1x) ou GPT-4.1 (grátis). Você estica sua cota mensal de ~2 sessões completas para ~4+ sessões fazendo a mesma quantidade de trabalho.

**Nível 2 — Fallback automático**
O orquestrador define uma cadeia de modelos:
```yaml
model:
  - Claude Sonnet 4.6 (copilot)   # primário
  - GPT-4.1 (copilot)             # fallback (grátis)
```
Se o Sonnet for rate-limited, o VS Code automaticamente cai pro GPT-4.1 (grátis). **O loop não para** — continua rodando com capacidade reduzida mas custo zero.

**Nível 3 — Operações zero-custo por design**
Hooks (lint após edição, carregamento de contexto) são scripts bash determinísticos — sem IA envolvida. Operações de banco (@Di) e git (@Qi) usam a tier grátis. Elas **nunca** consomem requests premium.

**Por que @Brainstorm-Wu não tem fallback (by design):** Planejamento requer raciocínio profundo. Um plano ruim de um modelo mais barato custa 6+ ciclos de execução em retrabalho. É melhor esperar a cota do Opus resetar do que planejar mal.

---

## 🌐 Bilíngue

O TAO tem suporte completo para **Inglês** e **Português Brasileiro**:

- Todos os 6 agentes em ambos os idiomas
- Todos os templates (CLAUDE.md, CONTEXT.md, CHANGELOG.md, fases, tarefas) em ambos os idiomas
- Todas as 14 skills em ambos os idiomas
- Templates de brainstorm são compartilhados (estrutura language-neutral)

Isso é adaptação cultural, não tradução mecânica. Os agentes PT-BR usam convenções, terminologia e fraseado brasileiros que soam nativos.

Escolha seu idioma durante o `install.sh` e tudo é configurado.

---

## 🔌 Compatibilidade

| Tier | Plataforma | Suporte |
|------|------------|---------|
| **Tier 1** | GitHub Copilot (VS Code Agent Mode) | Completo — agentes, hooks, roteamento de modelos, acesso a tools |
| **Tier 2** | Claude Code | Adaptador planejado — CLAUDE.md funciona nativamente |
| **Tier 3** | Cursor, Cline, Windsurf | Parcial — templates e docs funcionam, agentes precisam de setup manual |

O TAO é construído para o agent mode do GitHub Copilot (custom agents, custom hooks, roteamento de modelo via YAML frontmatter). Outras plataformas podem usar os templates e a estrutura de documentação.

---

## 📐 Princípios de Design

1. **Autonomia dentro de guardrails** — Agentes não fazem perguntas. Leem contexto, decidem, executam, commitam e iteram. Guardrails são impostos por código, não por sistema de honra.
2. **Config sobre convenção** — `tao.config.json` é a única fonte de verdade. Zero find-and-replace manual.
3. **Disco é a fonte de verdade** — Toda decisão, plano e log é persistido em arquivos. Chat é efêmero; o repo é permanente.
4. **O modelo mais barato que funciona** — Opus só quando profundidade de raciocínio é necessária. Sonnet para execução. Tier grátis sempre que possível.
5. **Agnóstico de linguagem** — Comandos de lint são configuráveis por extensão de arquivo. Funciona com Python, TypeScript, PHP, Ruby, Go, Rust — qualquer coisa com linter CLI.

---

## 💡 Inspiração

O protocolo de brainstorm do TAO foi influenciado pelos escritos de **Ralph Ammer** sobre ferramentas de pensamento — a distinção entre exploração divergente e tomada de decisão convergente.

Os nomes dos agentes seguem a filosofia Taoista: **Tao** (道 o caminho), **Wu** (悟 insight), **Shen** (深 profundidade), **Di** (地 terra), **Qi** (气 fluxo).

O protocolo IBIS (Issue-Based Information System) usado nas sessões de brainstorm vem de Kunz & Rittel (1970) — um método de argumentação estruturada para decisões complexas de design.

---

## 🛠️ Monitor CLI

O TAO inclui `tao.sh` — uma ferramenta de terminal pra acompanhar progresso sem abrir o VS Code:

```bash
./tao.sh status          # Estado de todas as fases
./tao.sh report 01       # Relatório detalhado da fase 01
./tao.sh dry-run 01      # Simula o que os agentes fariam
./tao.sh pause           # Cria kill switch (.tao-pause)
./tao.sh unpause         # Remove kill switch
```

Nota: `tao.sh` é apenas para **monitoramento**. Execução é feita pelos agentes dentro do VS Code.

---

## 🧬 TAO-DNA — Construa o Seu

Quer construir um sistema TAO-compatível para **Cursor, Cline, Windsurf, Claude Code**, ou qualquer outro ambiente?

[**TAO-DNA.md**](docs/TAO-DNA.md) documenta os **padrões universais** por trás do TAO — agnóstico de IDE, ferramentas e modelos. Cobre o loop autônomo, separação cognitiva, roteamento de modelos, guardrails determinísticos, persistência de contexto, conhecimento injetável, pipelines auto-healing e deliberação estruturada. Mais um mapa de tradução completo mostrando como cada padrão implementa em diferentes plataformas.

Não é como _usar_ o TAO. É como _pensar_ TAO.

---

## 🛠️ Troubleshooting

### Hooks não disparam
- Verifique que `.vscode/settings.json` tem `"chat.useCustomAgentHooks": true`
- Verifique que sua versão do VS Code suporta hooks de Agent Mode

### Check de compliance ausente
- Garanta que `tao.instructions.md` está carregado (verifique `.github/instructions/`)
- Verifique que o agent mode está ativo (não chat regular do Copilot)

### Erros de lint no commit
- Verifique que `lint_commands` no `tao.config.json` aponta para ferramentas instaladas
- Rode lint manualmente: `bash .github/tao/scripts/install-hooks.sh`

### Agente ignora regras

Enforcement varia por camada:

| Violação | Camada | Enforcement |
|----------|--------|-------------|
| Formato de commit errado | **L0** | `commit-msg.sh` rejeita o commit |
| Push para main/force push | **L0** | `pre-push.sh` bloqueia o push |
| Brainstorm/plano inválido | **L0** | `pre-commit.sh` bloqueia o commit |
| Lint faltando no commit | **L0** | `pre-commit.sh` roda lint automaticamente |
| `.tao-pause` ativo | **L0** | `pre-commit.sh` bloqueia todos os commits |
| Editar sem ler antes | **L1** | `enforcement-hook.sh` injeta aviso de violação R5 |
| Comando perigoso no terminal | **L1** | `enforcement-hook.sh` injeta aviso de violação LOCK |
| `--no-verify` no terminal | **L1** | `enforcement-hook.sh` injeta aviso LOCK 6 |
| Auto-lint em cada edição | **L1** | `lint-hook.sh` roda lint automaticamente |
| Scan de segurança ABEX em edição | **L1** | `abex-hook.sh` roda detecção de padrões |
| Roteamento de modelo (custo) | **L2** | Instrução do agente — não determinístico |
| Review ABEX 3 passadas | **L2** | Instrução do agente — não determinístico |

**L0 = bloqueado deterministicamente.** L1 = aviso injetado em tempo real. L2 = depende de compliance do agente.

- Problemas persistentes: abra uma [issue](https://github.com/andretauan/TAO/issues)

---

## 🤝 Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para diretrizes.

---

## 📄 Licença

[MIT](LICENSE) — Andre Tauan, 2026
