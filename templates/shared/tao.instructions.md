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
| R3 | Skill routing — auto-enforced (see table below) |
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

## SKILL ROUTING (R3 — auto-enforced, zero user action required)

TAO skills are auto-loaded by VS Code based on context. The instruction files `tao-code`, `tao-test`, `tao-api`, `tao-db` inject critical rules into every matching file. Skills provide deep knowledge on demand.

**Always active (every code task):**
| Skill | Trigger |
|-------|---------|
| `tao-clean-code` | Any code file — SOLID, DRY, KISS, function design |
| `tao-security-audit` | Any code file — OWASP Top 10, injection, auth |
| `tao-code-review` | Any code change — 6-axis self-review before commit |
| `tao-git-workflow` | Any git operation — commit format, branch discipline |

**Context-triggered (auto-loaded when relevant):**
| Skill | Trigger |
|-------|---------|
| `tao-test-strategy` | Test files — pyramid, edge cases, coverage |
| `tao-api-design` | Route/controller files — REST, status codes, pagination |
| `tao-database-design` | SQL/model/migration files — schema, indexes, safety |
| `tao-refactoring` | Refactoring tasks — pre-flight checklist, safe transforms |
| `tao-debug-investigation` | Bug investigation — hypothesis → isolate → fix → verify |
| `tao-performance-audit` | Performance tasks — profiling, bottleneck identification |
| `tao-architecture-decision` | Architecture decisions — ADR template, trade-off matrix |
| `tao-plan-writing` | PLAN.md creation — task decomposition methodology |
| `tao-brainstorm` | Brainstorming — IBIS methodology, maturity gate |
| `tao-onboarding` | New user questions — TAO setup guide |

**Compliance check must list which skills were active.** If a skill should have triggered but didn't, read it manually from `.github/skills/`.

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
