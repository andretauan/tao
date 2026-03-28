# TAO (道) Instructions | {{PROJECT_NAME}}
# Auto-loaded by VS Code Copilot in every session.
# This file is TAO-managed. It will be overwritten on TAO updates.

## IDENTITY

You are an agent for **{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}.
For TAO task execution (trigger "execute"/"executar"), use the **@Execute-Tao** agent in chat.

---

## MANDATORY READING (every session that modifies code)

1. Read `CLAUDE.md` — project-specific rules and coding patterns
2. Read `.github/tao/RULES.md` — TAO framework rules and protocols
3. Read `.github/tao/CONTEXT.md` — active phase + locked decisions
4. Consult `.github/tao/CHANGELOG.md` — last 3 entries
5. Read `.github/tao/tao.config.json` — project config (paths, models, lint, branch)
6. Consult `.github/skills/INDEX.md` — identify applicable skills (if exists)

---

## INVIOLABLE RULES (summary — full details in .github/tao/RULES.md)

| # | Rule |
|---|------|
| R0 | Compliance check at start of every code-modifying response |
| R1 | Syntax/lint check after every code edit (read .github/tao/tao.config.json → lint_commands) |
| R2 | Handoff = audit prompt, not blind continuation |
| R3 | Skill check before any code task (if skills exist) |
| R4 | Timestamp in all documentation: YYYY-MM-DD HH:MM |
| R5 | NEVER edit a file without reading it first |
| R6 | Update .github/tao/CONTEXT.md after every file edit |
| R7 | Session must end with clean `git status` |

---

## AVAILABLE AGENTS

| Agent | Use |
|-------|-----|
| **@Execute-Tao** | Full TAO loop — picks tasks, routes models, commits automatically |
| **@Investigate-Shen** / **@Investigar-Shen** | Architecture decisions, complex debugging, security audits |
| **@Brainstorm-Wu** | Brainstorming, planning, trade-off evaluation |

---

## SECURITY LOCKS (critical — enforced immediately)

- **SCOPE**: Only modify project source files. FORBIDDEN without approval: `CLAUDE.md`, `.github/workflows/`, `vendor/`, `node_modules/`, `.env`
- **BRANCH**: Work ONLY on `dev` (or branch in .github/tao/tao.config.json → git.dev_branch). NEVER force push or push to main.
- **DESTRUCTIVE**: NEVER `rm -rf`, `DROP TABLE/DATABASE`, `TRUNCATE`, `DELETE FROM` without WHERE
- **PAUSE**: If `.tao-pause` exists at project root → **IMMEDIATE STOP**
- **COMMIT**: NEVER commit without quality gates. Message: `type(scope): description`. 1 commit = 1 task.

---

## COMPLIANCE CHECK

Every code-modifying response MUST start with:

```
📋 COMPLIANCE CHECK
├─ Skills consulted: [list or "none applicable"]
├─ Files read before editing: [list]
├─ CONTEXT.md read: YES
├─ CHANGELOG.md consulted: YES
└─ ABEX: [PASS / N/A]
```
