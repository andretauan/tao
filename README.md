<div align="center">

# 道 TAO

**Trace · Align · Operate**

*The Way of AI-native development*

[![License: MIT](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)
[![Bilingual](https://img.shields.io/badge/i18n-EN%20%7C%20PT--BR-blue.svg)](#-bilingual)
[![VS Code](https://img.shields.io/badge/VS%20Code-Copilot%20Agent%20Mode-purple.svg)](https://code.visualstudio.com/)

[🇧🇷 Leia em Português](README.pt-br.md)

</div>

---

## 🎯 The Problem

AI coding assistants are powerful — but chaotic. Without structure:

- **Context evaporates** between sessions. Every conversation starts from zero.
- **No quality gates** — the AI writes code, you eyeball it, ship and pray.
- **Planning is skipped** — you jump straight to code, then spend 3x fixing what a 10-minute brainstorm would have prevented.
- **Model costs explode** — you use the most expensive model for everything, including tasks a cheaper one handles fine.

TAO fixes this by giving Copilot Agent Mode a disciplined operating system.

---

## ☯️ The Way — Three Layers

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│   Layer 1 — THINK          @Wu (Opus)               │
│   ┌───────────────────────────────────────────┐     │
│   │ Brainstorm → DISCOVERY → DECISIONS → BRIEF│     │
│   └───────────────────────────────────────────┘     │
│                      ↓                              │
│   Layer 2 — PLAN           @Wu (Opus)               │
│   ┌───────────────────────────────────────────┐     │
│   │ BRIEF → PLAN.md → STATUS.md → Task files  │     │
│   └───────────────────────────────────────────┘     │
│                      ↓                              │
│   Layer 3 — EXECUTE        @Tao (Sonnet)            │
│   ┌───────────────────────────────────────────┐     │
│   │ Pick task → Route agent → Implement →     │     │
│   │ Lint → Commit → Next task (loop)          │     │
│   └───────────────────────────────────────────┘     │
│                                                     │
│   ── Guardrails ──────────────────────────────────  │
│   Pre-commit hooks · Skill checks · ABEX audit     │
│   Compliance block · Context persistence · Doc sync │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Think** before you code. **Plan** before you build. **Execute** with discipline.

---

## 🤖 The Agents

Five agents, named after Taoist concepts, each with a clear role:

| Agent | Meaning | Model | Cost | Role |
|-------|---------|-------|------|------|
| **@Tao** | 道 the way | Sonnet 4.6 | 1x | Orchestrator — runs the execution loop, routes tasks to agents |
| **@Wu** | 悟 insight | Opus 4.6 | 3x | Brainstorm & planning — ideation, trade-offs, IBIS decisions, plan creation |
| **@Shen** | 深 depth | Opus 4.6 | 3x | Complex worker — hard debugging, architecture, security-critical code |
| **@Di** | 地 earth | GPT-4.1 | free | DBA — database migrations, schema, query optimization |
| **@Qi** | 气 flow | GPT-4.1 | free | Deploy — git operations, commit, push, merge |

**@Shen-Architect** is a user-invocable variant of @Shen for direct access outside the loop.

---

## 🚀 Quickstart

### 1. Clone TAO

```bash
git clone https://github.com/yourusername/tao.git ~/TAO
```

### 2. Run the installer in your project

```bash
cd /path/to/your-project
bash ~/TAO/install.sh .
```

The installer asks 5 questions (language, project name, description, branch, lint stack), then generates everything.

### 3. Enable VS Code hooks

In VS Code Settings, enable:

```
chat.useCustomAgentHooks: true
```

### 4. Start a brainstorm

Open Copilot Chat, select **@Wu**, and say:

```
brainstorm phase 01
```

Wu will explore ideas, document decisions using the IBIS protocol, and produce a BRIEF when ready.

### 5. Create the plan

Still in **@Wu**:

```
plan phase 01
```

Wu turns the BRIEF into PLAN.md + STATUS.md + individual task files.

### 6. Execute

Select **@Tao** and say:

```
execute
```

Tao picks the first pending task, reads the instructions, implements, lints, commits, and loops to the next one. Complex tasks are routed to @Shen automatically.

---

## 📦 What You Get

After running `install.sh`, your project gets:

```
your-project/
├── tao.config.json                # Central config — models, paths, lint, git
├── CLAUDE.md                      # Rules for all agents (your project context)
├── CONTEXT.md                     # Active phase, state, decisions
├── CHANGELOG.md                   # Structured changelog
├── .github/
│   ├── copilot-instructions.md    # Auto-loaded by Copilot every session
│   ├── agents/
│   │   ├── Tao.agent.md           # @Tao — orchestrator
│   │   ├── Wu.agent.md            # @Wu — brainstorm & planning
│   │   ├── Shen.agent.md          # @Shen — complex worker (subagent)
│   │   ├── Shen-Architect.agent.md # @Shen-Architect — direct access
│   │   ├── Di.agent.md            # @Di — DBA
│   │   └── Qi.agent.md            # @Qi — deploy
│   └── hooks/
│       └── hooks.json             # VS Code PostToolUse & SessionStart hooks
└── scripts/
    ├── lint-hook.sh               # PostToolUse — lint after file edit
    ├── context-hook.sh            # SessionStart — load context automatically
    ├── install-hooks.sh           # Git hook installer
    └── pre-commit.sh              # Modular pre-commit lint pipeline
```

When you create a phase, you get:

```
docs/phases/phase-01/
├── PLAN.md                        # What to build and why
├── STATUS.md                      # Task table with status tracking
├── progress.txt                   # Session log + codebase patterns
├── brainstorm/
│   ├── DISCOVERY.md               # Exploration by topic
│   ├── DECISIONS.md               # IBIS-format decisions
│   └── BRIEF.md                   # Compressed synthesis
└── tasks/
    ├── 01-setup-database.md       # Individual task with full spec
    ├── 02-create-api.md
    └── ...
```

---

## 💰 Model Economics

TAO routes each task to the cheapest model that can handle it:

| Task Type | Model | Cost | Examples |
|-----------|-------|------|----------|
| CRUD, views, bug fixes | Sonnet 4.6 | **1x** | Forms, API endpoints, CSS, tests |
| Architecture, debugging, security | Opus 4.6 | **3x** | Race conditions, auth systems, system design |
| Database operations | GPT-4.1 | **free** | Migrations, schema changes, EXPLAIN ANALYZE |
| Git operations | GPT-4.1 | **free** | Commit, push, merge |
| Brainstorm & planning | Opus 4.6 | **3x** | Worth it — a bad plan costs 6+ execution cycles |

**The math:** A typical phase has ~10 tasks. Without routing, all 10 use Opus (30x). With TAO, maybe 2 need Opus (6x), 6 use Sonnet (6x), 2 use free tier (0x) = **12x total instead of 30x**. That's a 60% reduction.

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

1. **Config over convention** — `tao.config.json` holds all project-specific values. Templates use placeholders, the installer fills them. Zero manual find-and-replace.
2. **Disk is the source of truth** — every decision, plan, and progress log is persisted to files. Chat is ephemeral; the repo is permanent.
3. **Agents don't ask questions** — they read context, decide, execute, and report. Total autonomy within guardrails.
4. **The cheapest model that works** — Opus only when reasoning depth is required. Sonnet for everything else. Free tier wherever possible.
5. **Language-agnostic** — lint commands are configurable per extension. Works with PHP, Python, TypeScript, Ruby, Go, Rust, or anything with a CLI linter.

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

[MIT](LICENSE) — Tauan Bernardo, 2026

---

<div align="center">

*"The way that can be told is not the eternal Way."* — Lao Tzu

**TAO** — Stop prompting. Start operating.

</div>
