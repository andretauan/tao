# GitHub Copilot — Base Instructions | {{PROJECT_NAME}}
# Read automatically in EVERY session. For full TAO loop → use @Execute-Tao agent.

## IDENTITY

You are an agent for **{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}.
For TAO task execution (trigger "execute"/"executar"), use the **@Execute-Tao** agent in chat.

---

## MANDATORY READING (every session that modifies code)

1. Read `CLAUDE.md` — inviolable rules
2. Read `.github/tao/CONTEXT.md` — active phase + locked decisions
3. Consult `.github/tao/CHANGELOG.md` — last 3 entries
4. Consult `.github/skills/INDEX.md` — identify applicable skills (if exists)

---

## INVIOLABLE RULES (summary — details in CLAUDE.md)

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
| **@Investigate-Shen** | Architecture decisions, complex debugging, security audits |
| **@Brainstorm-Wu** | Brainstorming, planning, trade-off evaluation |

---

## SECURITY

> Adapt to your stack. These are universal security requirements.

- NEVER output user data without sanitization
- SQL: parameterized queries ONLY — zero concatenation
- Uploads: validate real MIME type
- Secrets: environment variables only (`.env`) — never hardcode
- Auth: verify permissions before accessing sensitive data
- Input validation at system boundaries

---

## SECURITY LOCKS

### LOCK 1 — SCOPE
Agent may ONLY modify project source files.
**FORBIDDEN without approval:** `CLAUDE.md`, `.github/instructions/tao.instructions.md`, `.github/workflows/`, `vendor/`, `node_modules/`, `venv/`, `.env`

### LOCK 2 — BRANCH
- Work ONLY on `dev` (or branch defined in .github/tao/tao.config.json → git.dev_branch)
- NEVER `git push origin main`
- NEVER `git push --force`
- NEVER `git reset --hard`

### LOCK 3 — DESTRUCTIVE
NEVER execute: `rm -rf`, `DROP TABLE/DATABASE`, `TRUNCATE`, `DELETE FROM` without WHERE

### LOCK 4 — SCHEMA
Any schema-altering operation → STOP → document proposed SQL → register as checkpoint

### LOCK 5 — PAUSE
If `.tao-pause` exists at project root → **IMMEDIATE STOP**

### LOCK 6 — COMMIT
- NEVER commit without passing quality gates
- NEVER commit with `--no-verify`
- Message: `type(phase-XX): TNN — short description`
- 1 commit = 1 task

---

## COMPLIANCE CHECK

Every code-modifying response MUST start with:

```
📋 COMPLIANCE CHECK
├─ Skills consulted: [list or "none applicable"]
├─ Files read before editing: [list]
├─ .github/tao/CONTEXT.md read: YES
├─ .github/tao/CHANGELOG.md consulted: YES
└─ ABEX: [PASS / N/A]
```
