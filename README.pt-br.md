<div align="center">

# 道 TAO

**Trace · Align · Operate**

*O Caminho do desenvolvimento AI-native*

Um framework de agentes que dá estrutura ao VS Code Copilot: **brainstorm → planejar → executar** — roteando cada tarefa pro modelo de IA certo.

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilingual](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilíngue)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)

[🇺🇸 Read in English](README.md)

</div>

---

## 🎯 O Problema

Assistentes de IA para código são poderosos — mas caóticos. Sem estrutura:

- **O contexto evapora** entre sessões. Toda conversa começa do zero.
- **Sem quality gates** — a IA escreve código, você olha por cima, faz deploy e reza.
- **Planejamento é pulado** — você vai direto pro código, depois gasta 3x consertando o que um brainstorm de 10 minutos teria evitado.
- **Custo de modelo explode** — você usa o modelo mais caro pra tudo, inclusive tarefas que um mais barato resolve tranquilo.

O TAO resolve isso dando ao Copilot Agent Mode um sistema operacional disciplinado.

---

## ☯️ O Caminho — Três Camadas

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   Camada 1 — PENSAR        @Wu (Opus)               │
│   ┌───────────────────────────────────────────┐     │
│   │ Brainstorm → DISCOVERY → DECISIONS → BRIEF│     │
│   └───────────────────────────────────────────┘     │
│                      ↓                              │
│   Camada 2 — PLANEJAR      @Wu (Opus)               │
│   ┌───────────────────────────────────────────┐     │
│   │ BRIEF → PLAN.md → STATUS.md → Task files  │     │
│   └───────────────────────────────────────────┘     │
│                      ↓                              │
│   Camada 3 — EXECUTAR      @Tao (Sonnet)            │
│   ┌───────────────────────────────────────────┐     │
│   │ Pega tarefa → Roteia agente → Implementa →│     │
│   │ Lint → Commit → Próxima tarefa (loop)     │     │
│   └───────────────────────────────────────────┘     │
│                                                     │
│   ── Guardrails ──────────────────────────────────  │
│   Pre-commit hooks · Skill checks · ABEX audit     │
│   Compliance block · Context persistence · Doc sync │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Pense** antes de codar. **Planeje** antes de construir. **Execute** com disciplina.

---

## 🤖 Os Agentes

Cinco agentes, nomeados a partir de conceitos taoístas, cada um com um papel claro:

| Agente | Significado | Modelo | Custo | Papel |
|--------|-------------|--------|-------|-------|
| **@Tao** | 道 o caminho | Sonnet 4.6 | 1x | Orquestrador — roda o loop de execução, roteia tarefas para os agentes |
| **@Wu** | 悟 insight | Opus 4.6 | 3x | Brainstorm & planejamento — ideação, trade-offs, decisões IBIS, criação de planos |
| **@Shen** | 深 profundidade | Opus 4.6 | 3x | Worker complexo — debugging difícil, arquitetura, código crítico de segurança |
| **@Di** | 地 terra | GPT-4.1 | grátis | DBA — migrations, schema, otimização de queries |
| **@Qi** | 气 fluxo | GPT-4.1 | grátis | Deploy — operações git, commit, push, merge |

**@Shen-Architect** é uma variante do @Shen que o usuário pode invocar diretamente, fora do loop.

---

## 🚀 Início Rápido

### 1. Clone o TAO

```bash
git clone https://github.com/yourusername/tao.git ~/TAO
```

### 2. Rode o instalador no seu projeto

```bash
cd /path/to/your-project
bash ~/TAO/install.sh .
```

O instalador faz 5 perguntas (idioma, nome do projeto, descrição, branch, stack de lint), e gera tudo automaticamente.

### 3. Habilite os hooks no VS Code

Nas Configurações do VS Code, habilite:

```
chat.useCustomAgentHooks: true
```

### 4. Inicie um brainstorm

Abra o Copilot Chat, selecione **@Wu**, e diga:

```
brainstorm phase 01
```

Wu vai explorar ideias, documentar decisões usando o protocolo IBIS, e produzir um BRIEF quando estiver pronto.

### 5. Crie o plano

Ainda no **@Wu**:

```
plan phase 01
```

Wu transforma o BRIEF em PLAN.md + STATUS.md + arquivos de tarefa individuais.

### 6. Execute

Selecione **@Tao** e diga:

```
execute
```

Tao pega a primeira tarefa pendente, lê as instruções, implementa, faz lint, comita e parte pra próxima. Tarefas complexas são roteadas pro @Shen automaticamente.

---

## 📦 O Que Você Recebe

Depois de rodar `install.sh`, seu projeto ganha:

```
your-project/
├── tao.config.json                # Config central — modelos, paths, lint, git
├── CLAUDE.md                      # Regras para todos os agentes (contexto do projeto)
├── CONTEXT.md                     # Fase ativa, estado, decisões
├── CHANGELOG.md                   # Changelog estruturado
├── .github/
│   ├── copilot-instructions.md    # Carregado automaticamente pelo Copilot a cada sessão
│   ├── agents/
│   │   ├── Tao.agent.md           # @Tao — orquestrador
│   │   ├── Wu.agent.md            # @Wu — brainstorm & planejamento
│   │   ├── Shen.agent.md          # @Shen — worker complexo (subagent)
│   │   ├── Shen-Architect.agent.md # @Shen-Architect — acesso direto
│   │   ├── Di.agent.md            # @Di — DBA
│   │   └── Qi.agent.md            # @Qi — deploy
│   └── hooks/
│       └── hooks.json             # Hooks PostToolUse & SessionStart do VS Code
└── scripts/
    ├── lint-hook.sh               # PostToolUse — lint após edição de arquivo
    ├── context-hook.sh            # SessionStart — carrega contexto automaticamente
    ├── install-hooks.sh           # Instalador de git hooks
    └── pre-commit.sh              # Pipeline modular de lint no pre-commit
```

Quando você cria uma fase, ganha:

```
docs/phases/phase-01/
├── PLAN.md                        # O que construir e por quê
├── STATUS.md                      # Tabela de tarefas com rastreamento de status
├── progress.txt                   # Log de sessão + padrões do codebase
├── brainstorm/
│   ├── DISCOVERY.md               # Exploração por tópico
│   ├── DECISIONS.md               # Decisões no formato IBIS
│   └── BRIEF.md                   # Síntese comprimida
└── tasks/
    ├── 01-setup-database.md       # Tarefa individual com spec completa
    ├── 02-create-api.md
    └── ...
```

---

## 💰 Economia de Modelos

O TAO roteia cada tarefa pro modelo mais barato que dá conta:

| Tipo de Tarefa | Modelo | Custo | Exemplos |
|----------------|--------|-------|----------|
| CRUD, views, bug fixes | Sonnet 4.6 | **1x** | Forms, endpoints de API, CSS, testes |
| Arquitetura, debugging, segurança | Opus 4.6 | **3x** | Race conditions, sistemas de auth, design de sistema |
| Operações de banco | GPT-4.1 | **grátis** | Migrations, mudanças de schema, EXPLAIN ANALYZE |
| Operações git | GPT-4.1 | **grátis** | Commit, push, merge |
| Brainstorm & planejamento | Opus 4.6 | **3x** | Vale a pena — um plano ruim custa 6+ ciclos de execução |

**A conta:** Uma fase típica tem ~10 tarefas. Sem roteamento, todas as 10 usam Opus (30x). Com TAO, talvez 2 precisem de Opus (6x), 6 usam Sonnet (6x), 2 usam tier grátis (0x) = **12x no total ao invés de 30x**. Redução de 60%.

---

## 🌐 Bilíngue

O TAO vem com suporte completo para **inglês** e **português brasileiro**:

- Todos os 6 agentes nos dois idiomas
- Templates de CLAUDE.md, CONTEXT.md, CHANGELOG.md nos dois idiomas
- Templates de fase (PLAN, STATUS, tarefa, progress) nos dois idiomas
- Templates de brainstorm (DISCOVERY, DECISIONS, BRIEF) são compartilhados (estrutura neutra de idioma)

Isso é adaptação cultural, não tradução mecânica. Os agentes em PT-BR usam convenções, terminologia e fraseado brasileiros que soam nativos — não traduzidos.

Escolha o idioma durante o `install.sh` e tudo é configurado.

---

## 🔌 Compatibilidade

| Tier | Plataforma | Suporte |
|------|------------|---------|
| **Tier 1** | GitHub Copilot (VS Code Agent Mode) | Completo — agentes, hooks, acesso a ferramentas |
| **Tier 2** | Claude Code | Adapter planejado — CLAUDE.md funciona nativamente |
| **Tier 3** | Cursor, Cline, Windsurf | Mínimo — CLAUDE.md e templates funcionam, agentes precisam de setup manual |

O TAO é feito para o agent mode do GitHub Copilot (agentes customizados via `.agent.md`, hooks customizados via `hooks.json`, roteamento de modelo via YAML frontmatter). Outras plataformas podem usar os templates e a estrutura de documentação.

---

## 📐 Princípios de Design

1. **Config sobre convenção** — `tao.config.json` guarda todos os valores específicos do projeto. Templates usam placeholders, o instalador preenche. Zero busca-e-substitui manual.
2. **Disco é a fonte de verdade** — cada decisão, plano e log de progresso é persistido em arquivos. Chat é efêmero; o repo é permanente.
3. **Agentes não fazem perguntas** — eles leem o contexto, decidem, executam e reportam. Autonomia total dentro dos guardrails.
4. **O modelo mais barato que funciona** — Opus só quando profundidade de raciocínio é necessária. Sonnet pro resto. Tier grátis sempre que possível.
5. **Agnóstico de linguagem** — comandos de lint são configuráveis por extensão. Funciona com PHP, Python, TypeScript, Ruby, Go, Rust, ou qualquer coisa que tenha um linter CLI.

---

## 💡 Inspiração

O design do TAO foi fortemente influenciado pelos escritos de **Ralph Ammer** sobre ferramentas de pensamento e processos criativos — em particular a distinção entre exploração divergente e tomada de decisão convergente, que dá forma ao protocolo de brainstorm.

A nomenclatura dos agentes segue a filosofia taoísta: **Tao** (道 o caminho) como o caminho central, **Wu** (悟 insight) para deliberação, **Shen** (深 profundidade) para trabalho complexo, **Di** (地 terra) para operações de dados fundamentais, e **Qi** (气 fluxo) para movimento e deploy.

O protocolo IBIS (Issue-Based Information System) usado nas sessões de brainstorm vem de Kunz & Rittel (1970) — um método de argumentação estruturada onde cada decisão é rastreável através de posições, argumentos e contra-argumentos.

---

## 🛠️ CLI Monitor

O TAO inclui o `tao.sh` — um script de monitoramento para acompanhar o progresso sem abrir o VS Code:

```bash
./tao.sh status          # Mostra estado de todas as fases
./tao.sh report 01       # Relatório detalhado da fase 01
./tao.sh dry-run 01      # Simula o que os agentes fariam
./tao.sh pause           # Cria kill switch (.tao-pause)
./tao.sh unpause         # Remove kill switch
```

Nota: `tao.sh` é apenas para **monitoramento**. A execução é feita pelos agentes dentro do VS Code.

---

## 🤝 Contribuindo

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para diretrizes.

---

## 📄 Licença

[MIT](LICENSE) — Tauan Bernardo, 2026

---

<div align="center">

*"O caminho que pode ser dito não é o Caminho eterno."* — Lao Tzu

**TAO** — Pare de dar prompt. Comece a operar.

</div>
