<div align="center">

# 道 TAO

**De vibe coding pra engenharia.**

*Você diz "executar". O TAO pega a tarefa, roteia pro modelo certo, implementa, faz lint, comita — e parte pra próxima. Sem prompt. Sem babysitting. Sem caos.*

Um framework de desenvolvimento AI-native para VS Code Copilot que substitui o prompt-e-reza por um **pipeline de engenharia autônomo** — brainstorm, planejamento e execução em loop.

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilingual](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilíngue)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)
[![v1.0.0](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/andretauan/tao/releases/tag/v1.0.0)

[🇺🇸 Read in English](README.md)

</div>

---

## Vibe Code vs TAO Code

Você já viu — ou já viveu. Alguém abre o Copilot, digita "faz um app pra mim", recebe um muro de código, aceita, digita outro prompt, aceita de novo. Trinta prompts depois tem um projeto que *meio que* funciona, mas ninguém planejou, ninguém revisou, e ninguém consegue dar manutenção.

Isso é **vibe coding** — construir software na base do feeling. Sem estrutura. Sem plano. Sem controle de qualidade. Só prompt e esperança.

Funciona pra demo. Não funciona pra nada real.

**TAO Code é o oposto.** É uma mudança de mentalidade:

> **Não basta dar prompt. Pense primeiro. Planeje primeiro. Depois deixe a máquina executar — com guardrails.**

Você continua usando IA pra tudo. Continua escrevendo zero (ou mínimo) código na mão. Mas ao invés de uma cadeia caótica de prompts, você tem:

- **Uma fase de brainstorm** onde a IA explora seu problema *antes* de escrever uma linha sequer
- **Um plano estruturado** onde cada tarefa é definida, delimitada e ordenada — antes de qualquer código existir
- **Um loop de execução autônomo** que implementa cada tarefa, uma a uma, com checks de lint, quality gates e commits atômicos
- **Artefatos reais de engenharia** — logs de decisão, rastreabilidade, changelogs — não só "compilou, manda"

**O resultado é o mesmo:** a IA constrói seu projeto. **O processo é completamente diferente:** organizado, rastreável, profissional.

Você não precisa saber programar pra usar o TAO. Mas se usar o TAO, vai começar a *pensar* como engenheiro — porque o framework te obriga a pensar antes de construir.

**Esse é o upgrade. De vibe code pra TAO code.**

---

## Por que TAO

### 🔄 Loop Autônomo

Você diz `executar`. O TAO pega a tarefa, implementa, faz lint, comita — **e parte pra próxima sem parar.** Vai tomar um café. Volta pra encontrar 10 commits atômicos, cada um rastreável até uma tarefa planejada.

Chega de ficar babysitting prompt por prompt. Um comando roda a fase inteira.

### 🔒 Qualidade Blindada

Cada commit passa por lint no pre-commit, checks de compliance, e uma auditoria forense em 3 passes (integridade estrutural, consistência cross-file, completude de documentação). **Nada vai pro repo sem ser severamente analisado.**

Os guardrails são enforced por código — scripts bash que bloqueiam commits ruins. Não é sistema de honra. Não é "lembra de fazer lint". Código que não passa, não entra. Ponto.

### 💰 60% de Redução de Custo

Roteamento inteligente manda cada tarefa pro modelo de IA mais barato que dá conta:

- Coisas simples (CRUD, forms, testes) → **Sonnet** (custo 1x)
- Coisas complexas (arquitetura, segurança) → **Opus** (custo 3x)
- Banco de dados e operações git → **GPT-4.1** (grátis)

Sem roteamento: 10 tarefas × modelo caro = custo 30x. Com TAO: **custo 12x.** Mesmo trabalho, 60% mais barato.

### 🛡️ Proteção Contra Rate Limit

O Copilot te bloqueia quando você queima premium requests rápido demais — mesmo no Pro+. O TAO combate isso em três níveis:

1. **Prevenção** — roteamento mantém ~60-80% dos requests em modelos mais baratos/grátis
2. **Fallback** — se o modelo principal é bloqueado, o loop troca automaticamente pra um modelo grátis e continua rodando
3. **Ops zero-custo** — hooks, lint, operações git nunca consomem premium requests

Você estica sua cota mensal de ~2 sessões pra ~4+ sessões.

---

## A Ideia Central

Você diz pra IA **o que** construir. O TAO cuida do **como**, **quando** e **em que ordem** — num loop contínuo, sem parar pra te perguntar nada.

```
Sem TAO (vibe coding):                Com TAO:
──────────────────────                 ────────
prompt → espera → revisa               "executar"
prompt → espera → revisa                 ↓
prompt → espera → revisa               ┌──────────────────────────┐
prompt → espera → revisa               │ Pega tarefa              │
prompt → espera → revisa               │ → Roteia pro modelo certo│
prompt → espera → conserta             │ → Lê contexto & arquivos │
prompt → espera → revisa               │ → Implementa             │
prompt → espera → re-prompt            │ → Lint & valida          │
prompt → espera → torce pra funcionar  │ → Comita                 │
(você babysita 30+ prompts)            │ → Próxima tarefa ← LOOP  │
                                       └──────────────────────────┘
                                       (você revisa o resultado pronto)
```

**Um comando. Fase inteira. Cada tarefa comitada individualmente com quality gates.**

---

## 🔄 O Loop — O Motor do TAO

O loop de execução é o que torna o TAO diferente de templates de prompt ou wrappers de agente. Quando você diz `executar`, isso roda **automaticamente, em sequência, sem pausar**:

```
 ┌─→ 1. CHECAR PAUSA   .tao-pause existe? → PARA
 │   2. LER STATUS     Parseia STATUS.md → acha próxima tarefa ⏳
 │   3. ROTEAR         Tarefa simples → Sonnet (1x)
 │                     Tarefa complexa → Opus via @Shen (3x)
 │                     Banco de dados → @Di (grátis)
 │                     Operações git → @Qi (grátis)
 │   4. LER & IMPLEMENTAR  Lê arquivos necessários → código → teste
 │   5. QUALITY GATE   Roda linter → corrige se falhou (até 3 tentativas)
 │   6. COMITAR        git add (arquivos específicos) → commit → push
 │   7. AVANÇAR        Marca ⏳ → ✅ no STATUS.md
 └─← 8. LOOP           Volta pro passo 1 — imediatamente
```

O loop roda até que **todas as tarefas da fase sejam ✅** — ou você acione o kill switch (`.tao-pause`).

**Na prática:** você começa uma fase com 10 tarefas, diz "executar", e volta pra encontrar 10 commits atômicos, cada um com lint passando, cada um rastreável até uma tarefa planejada. Se algo falha 3 vezes, o loop escala automaticamente pra um modelo mais poderoso — nunca para e nunca te pede pra intervir.

---

## ☯️ Pensar → Planejar → Executar

O TAO estrutura todo projeto em três camadas. Esse é o coração da mentalidade "TAO Code" — **pense antes de codar, planeje antes de construir:**

**1. PENSAR — `@Brainstorm-Wu` (Opus)**

Antes de qualquer código existir, Wu explora o espaço do seu problema. Ele produz três documentos:
- **DISCOVERY.md** — exploração aberta do domínio, restrições e possibilidades
- **DECISIONS.md** — decisões estruturadas usando o protocolo IBIS (posição → argumento → contra-argumento)
- **BRIEF.md** — síntese comprimida com gate de maturidade (precisa atingir 5/7 pra prosseguir)

*Pense como o esboço do arquiteto antes da construção começar.*

**2. PLANEJAR — `@Brainstorm-Wu` (Opus)**

A partir do BRIEF, Wu cria um plano acionável:
- **PLAN.md** — o que construir e por quê, com rastreabilidade de decisões
- **STATUS.md** — tabela de tarefas com ordem, complexidade e atribuição de executor
- **Arquivos de tarefa** — specs individuais para cada tarefa (objetivo, arquivos, passos, critérios de aceite)

*Pense como a planta — cada cômodo, cada parede, cada fio, definido antes do primeiro prego ser batido.*

**3. EXECUTAR — `@Executar-Tao` (Sonnet)**

Tao entra no loop autônomo. Pega a primeira tarefa pendente, lê os arquivos relevantes, implementa, roda lint, comita, e parte imediatamente pra próxima. Tarefas complexas são roteadas automaticamente pro @Shen (Opus). Tarefas de banco vão pro @Di (grátis).

*Pense como a equipe de obra — seguindo a planta, cômodo por cômodo, com inspeção de qualidade em cada etapa.*

**Por que isso importa:** No vibe coding, a IA escreve código baseado no seu feeling — sem plano, sem estrutura, sem rastreabilidade. No TAO Code, cada linha de código rastreia até uma decisão que rastreia até uma exploração. Quando algo quebra, você sabe *por que* foi construído daquele jeito. Quando você passa o projeto pra outra pessoa, ela entende o raciocínio.

---

## 🤖 Os Agentes

Cinco agentes especializados, cada um travado num modelo de IA específico — sem troca manual, sem surpresa no custo:

| Agente | Modelo | Custo | Função |
|--------|--------|-------|--------|
| **@Executar-Tao** 道 | Sonnet 4.6 | 1x | **O loop.** Pega tarefas, roteia modelos, implementa, faz lint, comita, repete. |
| **@Brainstorm-Wu** 悟 | Opus 4.6 | 3x | Pensa e planeja. Explora ideias, documenta decisões, cria planos estruturados. |
| **@Shen** 深 | Opus 4.6 | 3x | Worker complexo. Debugging difícil, arquitetura, segurança. Chamado pelo Tao quando necessário. |
| **@Di** 地 | GPT-4.1 | grátis | DBA. Migrations, design de schema, otimização de queries. |
| **@Qi** 气 | GPT-4.1 | grátis | Deploy. Git commit, push, merge. |

**@Investigar-Shen** é uma variante do @Shen para o usuário invocar — use para investigações diretas fora do loop.

**Como trabalham juntos:** Você conversa com **Wu** (brainstorm & plano) e **Tao** (executar). Tao chama automaticamente **Shen** pra tarefas difíceis, **Di** pra banco de dados e **Qi** pra operações git. Você nunca troca manualmente entre agentes durante a execução.

---

## 🚀 Início Rápido

### O que você precisa

- **VS Code** com **GitHub Copilot** (Agent Mode habilitado)
- **Git** e **Python 3** (3.8+)
- macOS, Linux ou WSL2 (CMD nativo do Windows não é suportado)

### Instalar (2 minutos)

```bash
# Clone o TAO (uma vez, em qualquer lugar)
git clone https://github.com/andretauan/tao.git ~/TAO

# Vá pro seu projeto (novo ou existente)
cd /caminho/do/seu-projeto

# Rode o instalador
bash ~/TAO/install.sh .
```

O instalador faz 5 perguntas (idioma, nome do projeto, descrição, branch, stack de lint) e gera tudo automaticamente — agentes, hooks, config, templates.

Depois habilite os hooks no VS Code (configuração única):
```
Configurações → busque "chat.useCustomAgentHooks" → habilite
```

### Seu primeiro projeto (3 passos)

**Passo 1 — Brainstorm.** No Copilot Chat, selecione `@Brainstorm-Wu` e diga:

> brainstorm phase 01 — quero construir [descreva seu projeto]

Wu explora o problema, documenta decisões e produz um BRIEF.

**Passo 2 — Planejar.** Ainda no `@Brainstorm-Wu`:

> plan phase 01

Wu cria PLAN.md, STATUS.md e arquivos de tarefa individuais com specs completas. Revise e ajuste antes de prosseguir.

**Passo 3 — Executar.** Selecione `@Executar-Tao` e diga:

> executar

**Pronto.** Tao entra no loop autônomo — pega a primeira tarefa, implementa, faz lint, comita e parte pra próxima sem parar. Volte pra encontrar commits atômicos pra cada tarefa, tudo rastreável até o plano.

---

## 📦 O Que é Instalado

<details>
<summary>Clique pra expandir a árvore de arquivos</summary>

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
│       └── phases/                # Templates de fase (por idioma)
```

Quando uma fase é criada:

```
docs/phases/phase-01/
├── PLAN.md                        # O que construir e por quê
├── STATUS.md                      # Tabela de tarefas: ⏳ pendente, ✅ feito, ❌ bloqueado
├── progress.txt                   # Log de sessão
├── brainstorm/
│   ├── DISCOVERY.md               # Exploração aberta do espaço do problema
│   ├── DECISIONS.md               # Decisões estruturadas em IBIS
│   └── BRIEF.md                   # Síntese comprimida (gate de maturidade 5/7)
└── tasks/
    ├── 01-setup-database.md       # Spec completa: objetivo, arquivos, passos, critérios
    ├── 02-create-api.md
    └── ...
```

</details>

---

## 💰 Economia de Modelos

O loop roteia cada tarefa pro modelo de IA mais barato que dá conta — automaticamente, sem troca manual:

| Tipo de Tarefa | Modelo | Custo | Exemplos |
|----------------|--------|-------|----------|
| Trabalho rotineiro | Sonnet 4.6 | **1x** | Forms, endpoints de API, CSS, testes, bug fixes |
| Trabalho complexo | Opus 4.6 | **3x** | Arquitetura, segurança, race conditions, design de sistema |
| Operações de banco | GPT-4.1 | **grátis** | Migrations, mudanças de schema, otimização de queries |
| Operações git | GPT-4.1 | **grátis** | Commit, push, merge |
| Brainstorm & planejamento | Opus 4.6 | **3x** | Vale o custo — um plano ruim sai muito mais caro em retrabalho |

**Fase típica — 10 tarefas:**

Sem roteamento: 10 tarefas × Opus (3x) = **custo 30x**.
Com TAO: 2 Opus (6x) + 6 Sonnet (6x) + 2 grátis (0x) = **custo 12x — economia de 60%**.

Veja [ECONOMICS.md](docs/ECONOMICS.md) para a matemática completa de custos.

---

## 🛡️ Proteção Contra Rate Limit

O GitHub Copilot limita premium requests — mesmo nos planos Pro+. Use demais um modelo caro e você é **bloqueado até a cota resetar**. O TAO ataca isso em três níveis:

**Nível 1 — Prevenção (roteamento inteligente)**
O loop roteia ~60-80% das tarefas pra Sonnet (1x) ou GPT-4.1 (grátis). Você estica sua cota mensal de ~2 sessões completas pra ~4+ sessões fazendo a mesma quantidade de trabalho.

**Nível 2 — Fallback automático**
O orquestrador define uma cadeia de modelos:
```yaml
model:
  - Claude Sonnet 4.6 (copilot)   # primário
  - GPT-4.1 (copilot)             # fallback (grátis)
```
Se Sonnet é bloqueado por rate limit, o VS Code automaticamente cai pro GPT-4.1 (grátis). **O loop não para** — continua rodando com capacidade reduzida mas custo zero.

**Nível 3 — Operações zero-custo por design**
Hooks (lint após edição, carregamento de contexto) são scripts shell determinísticos — sem IA envolvida. Operações de banco (@Di) e git (@Qi) usam o tier grátis. Essas **nunca** consomem premium requests.

**Por que o @Brainstorm-Wu NÃO tem fallback (por design):** Planejamento exige raciocínio profundo. Um plano ruim de um modelo mais fraco custa 6+ ciclos de execução em retrabalho. É melhor esperar a cota do Opus resetar do que planejar mal.

---

## 🌐 Bilíngue

O TAO vem com suporte completo para **inglês** e **português brasileiro**:

- Todos os 6 agentes nos dois idiomas
- Todos os templates (CLAUDE.md, CONTEXT.md, CHANGELOG.md, fases, tarefas) nos dois idiomas
- Templates de brainstorm são compartilhados (estrutura neutra de idioma)

Isso é adaptação cultural, não tradução mecânica. Os agentes em PT-BR usam convenções, terminologia e fraseado brasileiros que soam nativos.

Escolha o idioma durante o `install.sh` e tudo é configurado.

---

## 🔌 Compatibilidade

| Tier | Plataforma | Suporte |
|------|------------|---------|
| **Tier 1** | GitHub Copilot (VS Code Agent Mode) | Completo — agentes, hooks, roteamento de modelo, acesso a ferramentas |
| **Tier 2** | Claude Code | Adapter planejado — CLAUDE.md funciona nativamente |
| **Tier 3** | Cursor, Cline, Windsurf | Parcial — templates e docs funcionam, agentes precisam de setup manual |

O TAO é feito para o agent mode do GitHub Copilot (agentes customizados, hooks customizados, roteamento de modelo via YAML frontmatter). Outras plataformas podem usar os templates e a estrutura de documentação.

---

## 📐 Princípios de Design

1. **Autonomia dentro de guardrails** — Agentes não fazem perguntas. Leem contexto, decidem, executam, comitam e voltam pro loop. Guardrails são enforced por código, não por sistema de honra.
2. **Config sobre convenção** — `tao.config.json` é a fonte única de verdade. Zero busca-e-substitui manual.
3. **Disco é a fonte de verdade** — Cada decisão, plano e log de progresso é persistido em arquivos. Chat é efêmero; o repo é permanente.
4. **O modelo mais barato que funciona** — Opus só quando profundidade de raciocínio é necessária. Sonnet pra execução. Tier grátis sempre que possível.
5. **Agnóstico de linguagem** — Comandos de lint são configuráveis por extensão de arquivo. Funciona com Python, TypeScript, PHP, Ruby, Go, Rust — qualquer coisa com linter CLI.

---

## 💡 Inspiração

O protocolo de brainstorm do TAO foi influenciado pelos escritos de **Ralph Ammer** sobre ferramentas de pensamento — a distinção entre exploração divergente e tomada de decisão convergente.

A nomenclatura dos agentes segue a filosofia taoísta: **Tao** (道 o caminho), **Wu** (悟 insight), **Shen** (深 profundidade), **Di** (地 terra), **Qi** (气 fluxo).

O protocolo IBIS (Issue-Based Information System) usado nas sessões de brainstorm vem de Kunz & Rittel (1970) — um método de argumentação estruturada para decisões complexas de design.

---

## 🛠️ CLI Monitor

O TAO inclui o `tao.sh` — uma ferramenta de terminal pra acompanhar o progresso sem abrir o VS Code:

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
