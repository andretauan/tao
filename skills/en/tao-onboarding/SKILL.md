---
name: tao-onboarding
description: "Guide new users through TAO framework setup, concepts, and first execution. Use when someone asks about TAO, how to get started, or needs help understanding the workflow."
argument-hint: "Describe what you need help with in TAO"
---
# TAO Onboarding Guide

## When to use this skill
Use when someone is new to TAO, asks how it works, or needs help setting up their first project.

## What is TAO?
TAO (Trace · Align · Operate) is an AI-native development framework that organizes coding with AI agents into three layers:
- **Trace (Think)** — Brainstorm ideas, evaluate trade-offs, make decisions
- **Align (Plan)** — Decompose work into phases with tasks, acceptance criteria, and effort estimates
- **Operate (Execute)** — Execute tasks in an autonomous loop with quality gates

## Key Files
| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project identity + code patterns (root) |
| `.github/tao/tao.config.json` | Single source of truth for config |
| `.github/tao/CONTEXT.md` | Current state — active phase, decisions |
| `.github/tao/CHANGELOG.md` | History — what changed, when, by whom |
| `.github/tao/RULES.md` | Framework rules (R0-R7) |
| `.github/skills/INDEX.md` | Skill catalog (if exists) |
| `.github/agents/*.agent.md` | Agent definitions |

## First Execution Checklist
1. Review `.github/tao/tao.config.json` — customize models, paths, lint
2. Edit `CLAUDE.md` — add project-specific rules and code patterns
3. Set first phase in `.github/tao/CONTEXT.md`
4. Enable `chat.useCustomAgentHooks` in VS Code settings
5. In Copilot Chat: select `@Execute-Tao` and say "execute"

## The Loop
```
@Execute-Tao → reads CONTEXT.md → finds active phase
  → reads PLAN.md → picks next task
  → routes to right model (Sonnet/Opus/GPT-4.1)
  → executes task → runs lint → updates CONTEXT.md
  → commits → picks next task → repeats
```

## Agents
| Agent | When to use |
|-------|-------------|
| `@Execute-Tao` | Full autonomous execution loop |
| `@Brainstorm-Wu` | Planning, ideation, trade-off analysis |
| `@Investigate-Shen` | Complex debugging, architecture decisions, security audits |

## Rules (R0-R7)
- **R0**: Compliance check at start of every code-modifying response
- **R1**: Lint check after every edit
- **R2**: Handoff audit on session end
- **R3**: Skill check before any code task
- **R4**: Timestamp in all documentation (YYYY-MM-DD HH:MM)
- **R5**: NEVER edit without reading first
- **R6**: Update CONTEXT.md after every file edit
- **R7**: Session must end with clean git status
