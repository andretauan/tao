<div align="center">

# 道 TAO

**Stop prompting. Start operating.**

*You say "execute". TAO picks the task, routes the right model, implements, lints, commits — and loops to the next one. Autonomously.*

An AI-native development framework for VS Code Copilot that turns agent mode into a **self-running engineering pipeline** with brainstorm, planning, and autonomous execution.

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilingual](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilingual)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)
[![v1.0.0](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/andretauan/tao/releases/tag/v1.0.0)

[🇧🇷 Leia em Português](README.pt-br.md)

</div>

---

## Why TAO

<table>
<tr>
<td width="50%">

### 🔄 Autonomous Loop
You say `execute`. TAO picks the task, implements, lints, commits — **and loops to the next one without stopping.** Go grab a coffee. Come back to 10 atomic commits, each traced to a planned task.

</td>
<td width="50%">

### 🔒 Bulletproof Quality
Every commit passes through pre-commit linting, compliance checks, and a 3-pass ABEX audit (security · UX · performance). **Nothing ships without being thoroughly analyzed.** The guardrails are code-enforced, not honor-system.

</td>
</tr>
<tr>
<td width="50%">

### 💰 60% Cost Reduction
Smart routing sends each task to the cheapest model that can handle it. CRUD → Sonnet (1x). Database → GPT-4.1 (free). **Only architecture and security use Opus (3x).** Same work, fraction of the premium requests.

</td>
<td width="50%">

### 🛡️ Rate Limit Shield
Copilot blocks you when you burn through premium requests too fast — even on Pro+. TAO **prevents quota exhaustion** through routing, and if you do hit the cap, **automatic model fallback keeps the loop running** at zero cost.

</td>
</tr>
</table>

---

## The Core Idea

You tell the AI **what** to build. TAO handles the **how**, **when**, and **in what order** — in a continuous loop, without stopping to ask you anything.

```
Without TAO:                          With TAO:
─────────────                         ─────────
prompt → wait → review                "execute"
prompt → wait → review                  ↓
prompt → wait → review                ┌──────────────────────────┐
prompt → wait → review                │ Pick task                │
prompt → wait → review                │ → Route to right model   │
prompt → wait → fix                   │ → Read context & files   │
prompt → wait → review                │ → Implement              │
prompt → wait → re-prompt             │ → Lint & validate        │
(you babysit 30+ prompts)            │ → Commit                 │
                                      │ → Next task ←───── LOOP  │
                                      └──────────────────────────┘
                                      (you review the finished result)
```

**One command. Full phase. Every task committed individually with quality gates.**

---

## 🔄 The Loop — TAO's Core

The execution loop is what makes TAO different from a collection of prompt templates. When you say `execute`, this happens **automatically, in sequence, without pausing**:

```
 ┌─→ 1. CHECK PAUSE    Is .tao-pause present? → STOP
 │   2. READ STATUS    Parse STATUS.md → find next ⏳ task
 │   3. ROUTE          Simple task → Sonnet (1x)
 │                     Complex task → Opus via @Shen (3x)
 │                     Database → @Di (free)
 │                     Git ops → @Qi (free)
 │   4. READ & IMPLEMENT  Read required files → code → test
 │   5. QUALITY GATE   Run linter → fix if failed (3 attempts)
 │   6. COMMIT         git add (specific files) → commit → push
 │   7. ADVANCE        Mark ⏳ → ✅ in STATUS.md
 └─← 8. LOOP           Back to step 1 — immediately
```

The loop runs until every task in the phase is ✅ — or you hit the kill switch (`.tao-pause`).

**What this means in practice:** you start a phase with 10 tasks, say "execute", and come back to find 10 atomic commits, each with lint passing, each traced to a planned task.

---

## ☯️ Three Layers

TAO structures every project into **Think → Plan → Execute**:

```
┌──────────────────────────────────────────────────┐
│                                                  │
│  THINK          @Brainstorm-Wu (Opus)            │
│  ┌────────────────────────────────────────────┐  │
│  │ Brainstorm → DISCOVERY → DECISIONS → BRIEF │  │
│  └────────────────────────────────────────────┘  │
│                       ↓                          │
│  PLAN            @Brainstorm-Wu (Opus)           │
│  ┌────────────────────────────────────────────┐  │
│  │ BRIEF → PLAN.md → STATUS.md → Task files   │  │
│  └────────────────────────────────────────────┘  │
│                       ↓                          │
│  EXECUTE         @Execute-Tao (Sonnet)           │
│  ┌────────────────────────────────────────────┐  │
│  │ Pick task → Route model → Implement →      │  │
│  │ Lint → Commit → ───────── LOOP ──→ repeat  │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ── Guardrails (zero LLM cost) ───────────────── │
│  Pre-commit hooks · Lint on save · ABEX audit    │
│  Compliance block · Context persistence          │
│                                                  │
└──────────────────────────────────────────────────┘
```

**Think** before you code. **Plan** before you build. **Execute** in a loop — not prompt by prompt.

---

## 🤖 The Agents

Five agents, each with a fixed model — no manual switching, no cost surprises:

| Agent | Model | Cost | What it does |
|-------|-------|------|-------------|
| **@Execute-Tao** 道 | Sonnet 4.6 | 1x | **The loop.** Picks tasks, routes models, implements, lints, commits, repeats. |
| **@Brainstorm-Wu** 悟 | Opus 4.6 | 3x | Explores ideas, documents decisions (IBIS protocol), creates plans. |
| **@Shen** 深 | Opus 4.6 | 3x | Complex worker — hard debugging, architecture, security. Called by Tao when needed. |
| **@Di** 地 | GPT-4.1 | free | DBA — migrations, schema, query optimization. |
| **@Qi** 气 | GPT-4.1 | free | Deploy — git commit, push, merge. |

**@Investigate-Shen** is a user-invocable variant of @Shen for direct access outside the loop.

---

## 🚀 Quickstart

### Prerequisites

- **VS Code** with **GitHub Copilot** (Agent Mode enabled)
- **Git** and **Python 3** (3.8+)
- macOS, Linux, or WSL2 (native Windows CMD not supported)

### Install

```bash
git clone https://github.com/andretauan/tao.git ~/TAO
cd /path/to/your-project
bash ~/TAO/install.sh .
```

The installer asks 5 questions (language, project name, description, branch, lint stack) and generates everything.

Enable VS Code hooks in Settings:
```
chat.useCustomAgentHooks: true
```

### Use

**1. Brainstorm** — Select @Brainstorm-Wu → `brainstorm phase 01`
Wu explores ideas, documents decisions, and produces a BRIEF.

**2. Plan** — Still in @Brainstorm-Wu → `plan phase 01`
Wu creates PLAN.md, STATUS.md, and individual task files with full specs.

**3. Execute** — Select @Execute-Tao → `execute`
**This is where TAO shines.** Tao enters the autonomous loop: picks the first pending task, reads files, implements, lints, commits, and immediately moves to the next one. Complex tasks route to @Shen (Opus). Database tasks route to @Di (free). You don't prompt again until the phase is done.

---

## 📦 What Gets Installed

<details>
<summary>Click to expand file tree</summary>

```
your-project/
├── CLAUDE.md                      # Rules for all agents (project context)
├── .github/
│   ├── copilot-instructions.md    # Auto-loaded by Copilot every session
│   ├── instructions/
│   │   └── tao.instructions.md    # TAO-specific instructions
│   ├── agents/                    # 6 agent files (3 visible + 3 subagents)
│   ├── hooks/
│   │   └── hooks.json             # SessionStart + PostToolUse hooks
│   └── tao/
│       ├── tao.config.json        # Central config (models, lint, git, paths)
│       ├── CONTEXT.md             # Active state — persists between sessions
│       ├── CHANGELOG.md           # Structured changelog
│       ├── RULES.md               # Inviolable rules reference
│       ├── scripts/               # 12 shell scripts (hooks, gates, validators)
│       └── phases/                # Phase templates
```

When you create a phase:

```
docs/phases/phase-01/
├── PLAN.md                        # What to build and why
├── STATUS.md                      # Task table with ⏳/✅/❌ tracking
├── progress.txt                   # Session log + codebase patterns
├── brainstorm/
│   ├── DISCOVERY.md               # Exploration by topic
│   ├── DECISIONS.md               # IBIS decisions with invalidation conditions
│   └── BRIEF.md                   # Compressed synthesis (5/7 maturity gate)
└── tasks/
    ├── 01-setup-database.md       # Full spec: objective, files, steps, criteria
    ├── 02-create-api.md
    └── ...
```

</details>

---

## 💰 Model Economics

The loop routes every task to the cheapest model that can handle it — automatically, no manual switching:

| Task Type | Model | Cost | Examples |
|-----------|-------|------|----------|
| CRUD, views, bug fixes | Sonnet 4.6 | **1x** | Forms, API endpoints, CSS, tests |
| Architecture, debugging, security | Opus 4.6 | **3x** | Race conditions, auth systems, system design |
| Database operations | GPT-4.1 | **free** | Migrations, schema changes, EXPLAIN ANALYZE |
| Git operations | GPT-4.1 | **free** | Commit, push, merge |
| Brainstorm & planning | Opus 4.6 | **3x** | Worth it — a bad plan costs 6+ execution cycles |

**Typical phase — 10 tasks:** Without routing, all 10 hit Opus (30x). With TAO: 2 Opus (6x) + 6 Sonnet (6x) + 2 free (0x) = **12x instead of 30x — 60% reduction**.

---

## 🛡️ Rate Limit Shield

GitHub Copilot caps premium requests — even on Pro+ plans. Use too much of an expensive model and you're **blocked until the quota resets**. TAO attacks this problem at three levels:

**1. Prevention — smart routing**
The loop routes ~60-80% of tasks to Sonnet (1x) or GPT-4.1 (free). You stretch your monthly quota from ~2 sessions to ~4 sessions doing the same amount of work.

**2. Automatic fallback**
The orchestrator (@Execute-Tao) defines a model chain in its YAML frontmatter:
```yaml
model:
  - Claude Sonnet 4.6 (copilot)
  - GPT-4.1 (copilot)
```
If Sonnet is rate-limited, VS Code automatically falls back to GPT-4.1 (free). **The loop doesn't stop** — it keeps running at reduced capability but zero cost.

**3. Zero-cost operations by design**
Hooks (lint after edit, context loading) are deterministic shell scripts. Database ops (@Di) and git ops (@Qi) use the free tier. None of these consume premium requests — ever.

**Why @Brainstorm-Wu has no fallback (by design):** Planning requires Opus-level reasoning. A bad plan from a cheaper model costs 6+ execution cycles in rework. It's better to wait for Opus quota to reset than to plan badly.

See [ECONOMICS.md](docs/ECONOMICS.md) for the full cost math.

---

## 🌐 Bilingual

TAO ships with full support for **English** and **Brazilian Portuguese**:

- All 6 agents in both languages
- CLAUDE.md, CONTEXT.md, CHANGELOG.md templates in both languages
- Phase templates (PLAN, STATUS, task, progress) in both languages
- Brainstorm templates (DISCOVERY, DECISIONS, BRIEF) are shared (language-neutral structure)

This is cultural adaptation, not mechanical translation. The PT-BR agents use Brazilian conventions, terminology, and phrasing that feel native — not translated.

Choose your language during `install.sh` and everything is set.

---

## 🔌 Compatibility

| Tier | Platform | Support |
|------|----------|---------|
| **Tier 1** | GitHub Copilot (VS Code Agent Mode) | Full — agents, hooks, tool access |
| **Tier 2** | Claude Code | Adapter planned — CLAUDE.md works natively |
| **Tier 3** | Cursor, Cline, Windsurf | Minimal — CLAUDE.md and templates work, agents need manual setup |

TAO is built for GitHub Copilot's agent mode (custom agents via `.agent.md`, custom hooks via `hooks.json`, model routing via YAML frontmatter). Other platforms can use the templates and documentation structure.

---

## 📐 Design Principles

1. **Autonomy within guardrails** — Agents don't ask questions. They read context, decide, execute, commit, and loop. The guardrails are code-enforced, not honor-system.
2. **Config over convention** — `tao.config.json` holds all project-specific values. Zero manual find-and-replace.
3. **Disk is the source of truth** — Every decision, plan, and progress log is persisted to files. Chat is ephemeral; the repo is permanent.
4. **The cheapest model that works** — Opus only when reasoning depth is required. Sonnet for execution. Free tier wherever possible.
5. **Language-agnostic** — Lint commands are configurable per extension. Works with PHP, Python, TypeScript, Ruby, Go, Rust, or anything with a CLI linter.

---

## 💡 Inspiration

TAO's design was heavily influenced by **Ralph Ammer's** writing on thinking tools and creative processes — particularly the distinction between divergent exploration and convergent decision-making that shapes the brainstorm protocol.

The agent naming follows Taoist philosophy: **Tao** (道 the way) as the central path, **Wu** (悟 insight) for deliberation, **Shen** (深 depth) for complex work, **Di** (地 earth) for grounded data operations, and **Qi** (气 flow) for movement and deployment.

The IBIS protocol (Issue-Based Information System) used in brainstorm sessions comes from Kunz & Rittel (1970) — a structured argumentation method where every decision traces back through positions, arguments, and counter-arguments.

---

## 🛠️ CLI Monitor

TAO includes `tao.sh` — a monitoring script for checking progress without opening VS Code:

```bash
./tao.sh status          # Show state of all phases
./tao.sh report 01       # Detailed report for phase 01
./tao.sh dry-run 01      # Simulate what agents would do
./tao.sh pause           # Create kill switch (.tao-pause)
./tao.sh unpause         # Remove kill switch
```

Note: `tao.sh` is for **monitoring only**. Execution is done by the agents inside VS Code.

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

[MIT](LICENSE) — Andre Tauan, 2026

---

<div align="center">

*"The way that can be told is not the eternal Way."* — Lao Tzu

**TAO** — The AI runs. You review.

</div>
