<div align="center">

# 道 TAO

**Pare de dar prompt. Comece a operar.**

*Você diz "executar". O TAO pega a tarefa, roteia pro modelo certo, implementa, faz lint, comita — e parte pra próxima. Sozinho.*

Um framework de desenvolvimento AI-native para VS Code Copilot que transforma o agent mode num **pipeline de engenharia autônomo** com brainstorm, planejamento e execução em loop.

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilingual](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilíngue)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)
[![v1.0.0](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/andretauan/tao/releases/tag/v1.0.0)

[🇺🇸 Read in English](README.md)

</div>

---

## Por que TAO

<table>
<tr>
<td width="50%">

### 🔄 Loop Autônomo
Você diz `executar`. O TAO pega a tarefa, implementa, faz lint, comita — **e parte pra próxima sem parar.** Vai tomar um café. Volta pra 10 commits atômicos, cada um rastreável até uma tarefa planejada.

</td>
<td width="50%">

### 🔒 Qualidade Blindada
Cada commit passa por lint no pre-commit, checks de compliance, e uma auditoria ABEX em 3 passes (segurança · UX · performance). **Nada vai pro repo sem ser severamente analisado.** Os guardrails são enforced por código, não por promessa.

</td>
</tr>
<tr>
<td width="50%">

### 💰 60% de Redução de Custo
Roteamento inteligente manda cada tarefa pro modelo mais barato que dá conta. CRUD → Sonnet (1x). Banco → GPT-4.1 (grátis). **Só arquitetura e segurança usam Opus (3x).** Mesmo trabalho, fração dos premium requests.

</td>
<td width="50%">

### 🛡️ Proteção Contra Rate Limit
O Copilot te bloqueia quando você queima premium requests rápido demais — mesmo no Pro+. O TAO **previne esgotamento de cota** via roteamento, e se você bater no limite, **fallback automático mantém o loop rodando** a custo zero.

</td>
</tr>
</table>

---

## A Ideia Central

Você diz pra IA **o que** construir. O TAO cuida do **como**, **quando** e **em que ordem** — num loop contínuo, sem parar pra te perguntar nada.

```
Sem TAO:                              Com TAO:
────────                              ────────
prompt → espera → revisa              "executar"
prompt → espera → revisa                ↓
prompt → espera → revisa              ┌──────────────────────────┐
prompt → espera → revisa              │ Pega tarefa              │
prompt → espera → revisa              │ → Roteia pro modelo certo│
prompt → espera → conserta            │ → Lê contexto & arquivos │
prompt → espera → revisa              │ → Implementa             │
prompt → espera → re-prompt           │ → Lint & valida          │
(você babysita 30+ prompts)           │ → Comita                 │
                                      │ → Próxima tarefa ← LOOP  │
                                      └──────────────────────────┘
                                      (você revisa o resultado pronto)
```

**Um comando. Fase inteira. Cada tarefa comitada individualmente com quality gates.**

---

## 🔄 O Loop — O Coração do TAO

O loop de execução é o que torna o TAO diferente de uma coleção de templates de prompt. Quando você diz `executar`, isso acontece **automaticamente, em sequência, sem pausar**:

```
 ┌─→ 1. CHECAR PAUSA   .tao-pause existe? → PARA
 │   2. LER STATUS     Parseia STATUS.md → acha próxima tarefa ⏳
 │   3. ROTEAR         Tarefa simples → Sonnet (1x)
 │                     Tarefa complexa → Opus via @Shen (3x)
 │                     Banco de dados → @Di (grátis)
 │                     Operações git → @Qi (grátis)
 │   4. LER & IMPLEMENTAR  Lê arquivos necessários → código → teste
 │   5. QUALITY GATE   Roda linter → corrige se falhou (3 tentativas)
 │   6. COMITAR        git add (arquivos específicos) → commit → push
 │   7. AVANÇAR        Marca ⏳ → ✅ no STATUS.md
 └─← 8. LOOP           Volta pro passo 1 — imediatamente
```

O loop roda até que todas as tarefas da fase sejam ✅ — ou você acione o kill switch (`.tao-pause`).

**Na prática:** você começa uma fase com 10 tarefas, diz "executar", e volta pra encontrar 10 commits atômicos, cada um com lint passando, cada um rastreável até uma tarefa planejada.

---

## ☯️ Três Camadas

O TAO estrutura todo projeto em **Pensar → Planejar → Executar**:

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  PENSAR         @Brainstorm-Wu (Opus)            │
│  ┌────────────────────────────────────────────┐  │
│  │ Brainstorm → DISCOVERY → DECISIONS → BRIEF │  │
│  └────────────────────────────────────────────┘  │
│                       ↓                          │
│  PLANEJAR       @Brainstorm-Wu (Opus)            │
│  ┌────────────────────────────────────────────┐  │
│  │ BRIEF → PLAN.md → STATUS.md → Task files   │  │
│  └────────────────────────────────────────────┘  │
│                       ↓                          │
│  EXECUTAR       @Executar-Tao (Sonnet)           │
│  ┌────────────────────────────────────────────┐  │
│  │ Pega tarefa → Roteia modelo → Implementa → │  │
│  │ Lint → Comita → ────────── LOOP ──→ repete │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ── Guardrails (zero custo LLM) ──────────────── │
│  Pre-commit hooks · Lint on save · Auditoria ABEX│
│  Compliance block · Persistência de contexto     │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Pense** antes de codar. **Planeje** antes de construir. **Execute** em loop — não prompt a prompt.

---

## 🤖 Os Agentes

Cinco agentes, cada um com modelo fixo — sem troca manual, sem surpresa no custo:

| Agente | Modelo | Custo | O que faz |
|--------|--------|-------|-----------|
| **@Executar-Tao** 道 | Sonnet 4.6 | 1x | **O loop.** Pega tarefas, roteia modelos, implementa, faz lint, comita, repete. |
| **@Brainstorm-Wu** 悟 | Opus 4.6 | 3x | Explora ideias, documenta decisões (protocolo IBIS), cria planos. |
| **@Shen** 深 | Opus 4.6 | 3x | Worker complexo — debugging difícil, arquitetura, segurança. Chamado pelo Tao quando necessário. |
| **@Di** 地 | GPT-4.1 | grátis | DBA — migrations, schema, otimização de queries. |
| **@Qi** 气 | GPT-4.1 | grátis | Deploy — git commit, push, merge. |

**@Investigar-Shen** é uma variante do @Shen para acesso direto fora do loop.

---

## 🚀 Início Rápido

### Pré-requisitos

- **VS Code** com **GitHub Copilot** (Agent Mode habilitado)
- **Git** e **Python 3** (3.8+)
- macOS, Linux ou WSL2 (CMD nativo do Windows não suportado)

### Instalar

```bash
git clone https://github.com/andretauan/tao.git ~/TAO
cd /caminho/do/seu-projeto
bash ~/TAO/install.sh .
```

O instalador faz 5 perguntas (idioma, nome do projeto, descrição, branch, stack de lint) e gera tudo.

Habilite os hooks no VS Code em Configurações:
```
chat.useCustomAgentHooks: true
```

### Usar

**1. Brainstorm** — Selecione @Brainstorm-Wu → `brainstorm phase 01`
Wu explora ideias, documenta decisões e produz um BRIEF.

**2. Planejar** — Ainda no @Brainstorm-Wu → `plan phase 01`
Wu cria PLAN.md, STATUS.md e arquivos de tarefa individuais com specs completas.

**3. Executar** — Selecione @Executar-Tao → `executar`
**É aqui que o TAO brilha.** Tao entra no loop autônomo: pega a primeira tarefa pendente, lê arquivos, implementa, faz lint, comita, e parte imediatamente pra próxima. Tarefas complexas vão pro @Shen (Opus). Tarefas de banco vão pro @Di (grátis). Você não dá outro prompt até a fase acabar.

---

## 📦 O Que é Instalado

<details>
<summary>Clique para expandir a árvore de arquivos</summary>

```
seu-projeto/
├── CLAUDE.md                      # Regras para todos os agentes (contexto do projeto)
├── .github/
│   ├── copilot-instructions.md    # Carregado automaticamente pelo Copilot toda sessão
│   ├── instructions/
│   │   └── tao.instructions.md    # Instruções específicas do TAO
│   ├── agents/                    # 6 arquivos de agente (3 visíveis + 3 subagentes)
│   ├── hooks/
│   │   └── hooks.json             # Hooks SessionStart + PostToolUse
│   └── tao/
│       ├── tao.config.json        # Config central (modelos, lint, git, paths)
│       ├── CONTEXT.md             # Estado ativo — persiste entre sessões
│       ├── CHANGELOG.md           # Changelog estruturado
│       ├── RULES.md               # Referência de regras invioláveis
│       ├── scripts/               # 12 shell scripts (hooks, gates, validadores)
│       └── phases/                # Templates de fase
```

Quando você cria uma fase:

```
docs/phases/phase-01/
├── PLAN.md                        # O que construir e por quê
├── STATUS.md                      # Tabela de tarefas com rastreamento ⏳/✅/❌
├── progress.txt                   # Log de sessão + padrões do codebase
├── brainstorm/
│   ├── DISCOVERY.md               # Exploração por tópico
│   ├── DECISIONS.md               # Decisões IBIS com condições de invalidação
│   └── BRIEF.md                   # Síntese comprimida (gate de maturidade 5/7)
└── tasks/
    ├── 01-setup-database.md       # Spec completa: objetivo, arquivos, passos, critérios
    ├── 02-create-api.md
    └── ...
```

</details>

---

## 💰 Economia de Modelos

O loop roteia cada tarefa pro modelo mais barato que dá conta — automaticamente, sem troca manual:

| Tipo de Tarefa | Modelo | Custo | Exemplos |
|----------------|--------|-------|----------|
| CRUD, views, bug fixes | Sonnet 4.6 | **1x** | Forms, endpoints de API, CSS, testes |
| Arquitetura, debugging, segurança | Opus 4.6 | **3x** | Race conditions, sistemas de auth, design de sistema |
| Operações de banco | GPT-4.1 | **grátis** | Migrations, mudanças de schema, EXPLAIN ANALYZE |
| Operações git | GPT-4.1 | **grátis** | Commit, push, merge |
| Brainstorm & planejamento | Opus 4.6 | **3x** | Vale a pena — um plano ruim custa 6+ ciclos de execução |

**Fase típica — 10 tarefas:** Sem roteamento, todas as 10 vão pro Opus (30x). Com TAO: 2 Opus (6x) + 6 Sonnet (6x) + 2 grátis (0x) = **12x ao invés de 30x — redução de 60%**.

---

## 🛡️ Proteção Contra Rate Limit

O GitHub Copilot limita premium requests — mesmo nos planos Pro+. Use demais um modelo caro e você é **bloqueado até a cota resetar**. O TAO ataca esse problema em três níveis:

**1. Prevenção — roteamento inteligente**
O loop roteia ~60-80% das tarefas pra Sonnet (1x) ou GPT-4.1 (grátis). Você estica sua cota mensal de ~2 sessões pra ~4 sessões fazendo a mesma quantidade de trabalho.

**2. Fallback automático**
O orquestrador (@Executar-Tao) define uma cadeia de modelos no YAML frontmatter:
```yaml
model:
  - Claude Sonnet 4.6 (copilot)
  - GPT-4.1 (copilot)
```
Se Sonnet é bloqueado por rate limit, o VS Code automaticamente cai pro GPT-4.1 (grátis). **O loop não para** — continua rodando com capacidade reduzida mas custo zero.

**3. Operações zero-custo por design**
Hooks (lint após edição, carregamento de contexto) são scripts shell determinísticos. Operações de banco (@Di) e git (@Qi) usam o tier grátis. Nenhuma dessas operações consome premium requests — nunca.

**Por que o @Brainstorm-Wu NÃO tem fallback (por design):** Planejamento requer raciocínio nível Opus. Um plano ruim de um modelo mais fraco custa 6+ ciclos de execução em retrabalho. É melhor esperar a cota do Opus resetar do que planejar mal.

Veja [ECONOMICS.md](docs/ECONOMICS.md) para a matemática completa de custos.

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

1. **Autonomia dentro de guardrails** — Agentes não fazem perguntas. Leem contexto, decidem, executam, comitam e voltam pro loop. Os guardrails são enforced por código, não por honra.
2. **Config sobre convenção** — `tao.config.json` guarda todos os valores específicos do projeto. Zero busca-e-substitui manual.
3. **Disco é a fonte de verdade** — Cada decisão, plano e log de progresso é persistido em arquivos. Chat é efêmero; o repo é permanente.
4. **O modelo mais barato que funciona** — Opus só quando profundidade de raciocínio é necessária. Sonnet pra execução. Tier grátis sempre que possível.
5. **Agnóstico de linguagem** — Comandos de lint são configuráveis por extensão. Funciona com PHP, Python, TypeScript, Ruby, Go, Rust, ou qualquer coisa com linter CLI.

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

[MIT](LICENSE) — Andre Tauan, 2026

---

<div align="center">

*"O caminho que pode ser dito não é o Caminho eterno."* — Lao Tzu

**TAO** — A IA executa. Você revisa.

</div>
