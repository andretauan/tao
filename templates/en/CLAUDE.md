# CLAUDE.md — Project Rules | {{PROJECT_NAME}}

> **READ THIS FILE BEFORE ANY ACTION.**
> Then read `.github/tao/RULES.md` for full TAO framework rules.

---

## PROJECT

**{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}

**Configuration:** `.github/tao/tao.config.json` is the **single source of truth** for project config.

| File | Purpose |
|------|---------|
| `.github/tao/tao.config.json` | Project config — paths, models, lint, branch, scopes |
| `.github/tao/RULES.md` | TAO framework rules — agents, R0-R7, ABEX, security locks |
| `.github/tao/CONTEXT.md` | Current state — active phase, decisions, touched files |
| `.github/tao/CHANGELOG.md` | History — what changed, when, by whom |
| `.github/tao/phases/` | Phase templates |
| `.github/skills/` | Skill library (optional) |
| `.github/agents/` | Agent definitions |

---

## MANDATORY READING ORDER

1. `CLAUDE.md` (this file) — project identity + code patterns
2. `.github/tao/RULES.md` — TAO rules, protocols, security locks
3. `.github/tao/CONTEXT.md` — current state
4. `.github/tao/CHANGELOG.md` — last 5 entries
5. `.github/tao/tao.config.json` — project config
6. `.github/skills/INDEX.md` — applicable skills (if exists)

---

## CODE PATTERNS

> Define your project-specific code patterns below.
> Reference `.github/tao/tao.config.json` → `lint_commands` for language-specific conventions.

```
<!-- PROJECT-SPECIFIC PATTERNS -->
<!-- Add your coding standards, naming conventions, and patterns here. -->
<!-- Examples: -->
<!--   - SQL: always use prepared statements                          -->
<!--   - Output: always escape with appropriate function              -->
<!--   - Auth: check permissions on first line of handler             -->
<!--   - Error responses: use consistent format (ok/error helpers)    -->
```
