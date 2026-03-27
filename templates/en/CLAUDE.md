# CLAUDE.md — Universal Agent Instructions | {{PROJECT_NAME}}

> **READ THIS FILE ENTIRELY BEFORE ANY ACTION.**
> Every agent operating in this project, regardless of task size, must:
> 1. Read `CLAUDE.md` (this file)
> 2. Read `CONTEXT.md` (current state)
> 3. Consult `CHANGELOG.md` (last 5 entries)
> 4. Check `.github/skills/INDEX.md` if it exists — read applicable skills
> Only then: execute.

---

## PROJECT

**{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}

**Configuration:** `tao.config.json` is the **single source of truth** for project config.
It contains: source paths, lint commands, models, branch policy, and all runtime settings.
Agents MUST read `tao.config.json` to resolve project-specific values (stack, paths, commands).

| File | Purpose |
|------|---------|
| `tao.config.json` | Project config — paths, models, lint, branch, scopes |
| `CONTEXT.md` | Current state — active phase, decisions, touched files |
| `CHANGELOG.md` | History — what changed, when, by whom |
| `phases/` | Phase docs — plans, status, tasks, progress |
| `.github/skills/` | Skill library (optional) |
| `.github/agents/` | Agent definitions |

---

## AGENT HIERARCHY

This project uses the **TAO (道) agent system** — Trace · Align · Operate.
Routing is automatic: Sonnet (1x) for routine work, Opus (3x) for complex decisions, free-tier for DB/deploy.

| Agent | Symbol | Model | Role |
|-------|--------|-------|------|
| **Tao** | 道 | Sonnet | Orchestrator — task loop, automatic routing |
| **Shen** | 深 | Opus | Complex Worker — subagent invoked by Tao for hard tasks |
| **Shen-Architect** | 深 | Opus | Architect — user-invocable, direct access outside loop |
| **Wu** | 悟 | Opus | Brainstorm/Planning — ideation, trade-offs, synthesis |
| **Di** | 地 | Free tier | DBA — migrations, schema, query optimization |
| **Qi** | 气 | Free tier | Deploy — git operations, CI/CD, environment sync |

**Details:** See `.github/agents/` for full agent definitions and protocols.

### Escalation Matrix

| Activity | Model | Justification |
|----------|-------|---------------|
| CRUD, views, CSS, routine fixes | **Sonnet** | Mechanical — follow clear instructions |
| Execute validated plan | **Sonnet** | Plan already decided by Opus |
| Docs, changelog, formatting | **Sonnet** | Transcription, not judgment |
| Architecture decisions | **Opus** | Requires systemic reasoning |
| Security-critical code | **Opus** | Zero tolerance for mistakes |
| Complex debugging (3+ failed attempts) | **Opus** | Pattern recognition under ambiguity |
| Brainstorm / planning / trade-offs | **Opus** | Judgment — where Sonnet fails catastrophically |
| System prompt / LLM config rewrites | **Opus** | Nuance and context sensitivity |
| DB operations, migrations | **Free tier** | Specialized, low-cost |
| Git add, commit, push, merge | **Free tier** | Mechanical operations |

### Rule: Sonnet Never Plans (INVIOLABLE)

> The cost of a bad plan >>> the cost of using Opus to plan.
> A flawed Sonnet plan wastes 6+ execution cycles in rework.

Sonnet is **PROHIBITED** for:
- Generating ideas or exploring approaches
- Deciding trade-offs between alternatives
- Evaluating plan completeness
- Synthesizing conversations into decision documents
- Any activity requiring "what's missing here?"

Sonnet is **SAFE** only when:
- Transcribing decisions **already made** by Opus/user
- Loading context (reading files, presenting state)
- Executing a plan **already validated** by Opus
- Commit, push, changelog, mechanical formatting

---

## INVIOLABLE RULES

### R0 — Compliance Check (MANDATORY FORMAT)

> **Every response that modifies code MUST begin with this block. No exceptions.**

```
📋 COMPLIANCE CHECK
├─ Skills consulted: [list or "none applicable — justification: ..."]
├─ Files read before editing: [list]
├─ CONTEXT.md read: YES
├─ CHANGELOG.md consulted: YES
└─ ABEX: [PASS / N/A]
```

This block MUST be the **FIRST thing** in the response. If the agent forgot: STOP, go back, emit the block.

### R1 — Syntax Check Mandatory

After editing any code file: run the appropriate lint/compile check.
Lint commands are defined in `tao.config.json` → `lint_commands`.
If lint fails → fix → re-run (max 3 attempts). After 3 failures → rollback → log in progress.txt.

### R2 — Handoff = Audit Prompt

Handoff MUST be an **audit prompt** for the next agent, not "continue next step."
Format: "Audit [file list]. Verify [specific points]." See §HANDOFF below.

### R3 — Skill Check Mandatory

Before ANY task that modifies code: check `.github/skills/INDEX.md` (if it exists) and read applicable skill(s).
No skill read = execution prohibited.

### R4 — Timestamp Mandatory

All documentation entries: `YYYY-MM-DD HH:MM`. Obtain via `date '+%Y-%m-%d %H:%M'` before editing.
Missing time = invalid entry.

### R5 — Read Before Edit

NEVER edit a file without reading its full content first.
NEVER invent APIs, functions, or behaviors — always read the real code first.

### R6 — CONTEXT.md Sync

After every file edited or created: update `CONTEXT.md` section "Files Touched (session)."
Never leave TODO or FIXME without registering in `CONTEXT.md` section "Open Pendencies."

### R7 — Git Clean on Exit

When ending any session: verify `git status`.
PROHIBITED to end with uncommitted modified files.
If a file was touched → commit. If it should not be committed → justify in CONTEXT.md §Open Pendencies.

---

## ABEX PROTOCOL (Quality Gate)

After completing any implementation that modifies code, run **3 mandatory passes:**

| Pass | Mindset | What to check |
|------|---------|---------------|
| **1 — Security** | "I am an attacker" | SQL injection, XSS, CSRF, auth bypass, empty catch blocks, unvalidated input, command injection, path traversal |
| **2 — User** | "I am a real user" | UX flow, error messages, accessibility, mobile responsiveness, edge cases, empty states |
| **3 — Performance** | "I am a Core Web Vitals auditor" | N+1 queries, DOM size, CLS, LCP, unnecessary re-renders, unbounded loops, missing pagination |

**No ABEX = task not completed.** Report findings by severity: CRITICAL → HIGH → MEDIUM → INFO.

---

## SECURITY LOCKS

| Lock | Rule |
|------|------|
| **LOCK 1 — SCOPE** | Only modify project source files. NEVER modify: `CLAUDE.md`, `.github/workflows/`, `vendor/`, `node_modules/`, `venv/`, `.env`, `tao.config.json` (without explicit approval). |
| **LOCK 2 — BRANCH** | Only `dev` (or as defined in `tao.config.json` → `branch`). NEVER `git push origin main`, `git push --force`, `git reset --hard`. |
| **LOCK 3 — DESTRUCTIVE** | NEVER `rm -rf`, `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` without WHERE clause. |
| **LOCK 4 — SCHEMA** | Any `CREATE TABLE`, `ALTER TABLE`, `DROP COLUMN` → STOP → document the SQL → register as checkpoint. |
| **LOCK 5 — PAUSE** | If `.tao-pause` exists in project root → **IMMEDIATE STOP**. Report status and halt all operations. |

---

## PHASE WORKFLOW

Phases follow the TAO execution pipeline:

```
1. Brainstorm → DISCOVERY.md + DECISIONS.md  (Opus only — @Wu agent)
2. Synthesize → BRIEF.md                      (Opus only — maturity gate ≥ 5/7)
3. Plan       → PLAN.md                       (Opus only — @Wu or @Shen-Architect)
4. Status     → STATUS.md with task table      (any agent)
5. Tasks      → tasks/ folder, one .md per task
6. Execute    → "execute" trigger in Copilot Chat → task loop
7. Each task  → individual commit (atomic)
8. Update     → CONTEXT.md + CHANGELOG.md after each task
```

**Triggers:**
- `"execute"` / `"executar"` / `"continue"` → enter task loop (reads STATUS.md, picks next ⏳ task)
- `"next task"` / `"task NN"` → execute ONE task and stop
- `"brainstorm"` / `"discuss"` → ideation session (Opus only)
- `"plan phase"` / `"create plan"` → plan creation (Opus only)
- `"review"` / `"audit"` → ABEX 3× passes

---

## COMMIT CONVENTIONS

```
type(scope): short imperative description
```

**Types:** `feat` · `fix` · `refactor` · `docs` · `chore` · `hotfix` · `test`

**Scopes:** defined per project in `tao.config.json` → `commit_scopes`. Common examples: `api`, `auth`, `db`, `ui`, `core`, `deploy`.

**Rules:**
- Imperative mood: "add feature" not "added feature"
- Max 72 chars in subject line
- Never `git add -A` — always `git add <specific-files>`
- Always `git push origin dev` after every commit

---

## CHANGELOG FORMAT

New entries always at the **TOP** of the file. Max 15 lines per entry.

```markdown
## [YYYY-MM-DD HH:MM] type(scope): descriptive title

- **Model:** [agent model] | **Phase:** X — Name
- **Files:** `path/file.ext`, `path/other.ext`
- What was done (action + result)
- Non-obvious decisions and why
```

---

## CONTEXT.md — Required Fields

Every `CONTEXT.md` MUST contain these fields:

| # | Field | Description |
|---|-------|-------------|
| 1 | **Active Phase** | Which phase is currently executing |
| 2 | **Last Action** | What was done (1 sentence) |
| 3 | **Next Action** | What to do next session (1 sentence) |
| 4 | **Files Touched (session)** | List of files created/edited this session |
| 5 | **Open Pendencies** | TODOs, FIXMEs, known issues |
| 6 | **Locked Decisions** | Decisions that CANNOT be revised without approval |

---

## HANDOFF FORMAT

Every session that modifies code MUST end with a handoff block.

```
---
## 🔄 HANDOFF — ORDER for next agent

**Designated agent:** OPUS | SONNET
**Justification:** [1 sentence explaining WHY this agent]

### EXECUTION ORDER:

> [Imperative prompt — 3-10 lines. What was done, what to DO,
> which files to read, which action to execute. Tone: ORDER, not suggestion.]
```

### Designation Criteria

| Criterion | → OPUS | → SONNET |
|-----------|--------|----------|
| Deep reasoning / architecture | ✅ | ❌ |
| Complex debugging | ✅ | ❌ |
| Security audit | ✅ | ❌ |
| Systemic-impact decisions | ✅ | ❌ |
| Routine implementation (CRUD, views) | ❌ | ✅ |
| Execution of a validated plan | ❌ | ✅ |
| High-volume / repetitive tasks | ❌ | ✅ |
| Documentation / changelog | ❌ | ✅ |

**Rule:** If the task fits Sonnet, NEVER use Opus.

---

## AUTONOMY RULES

- **Respect what CONTEXT.md says.** If it says "phase complete," do NOT look for more work.
- **NEVER suggest next steps proactively.** The user defines priorities.
- **NEVER ask "can I do X?" or "want me to do Y?".** Execute what was asked. Period.
- **When ending a session:** report ONLY what was done. No unsolicited advice.

---

## CODE PATTERNS

> Define your project-specific code patterns below.
> These are populated during installation based on your stack.
> Reference `tao.config.json` → `stack` for language-specific conventions.

```
<!-- PROJECT-SPECIFIC PATTERNS -->
<!-- Add your coding standards, naming conventions, and patterns here. -->
<!-- Examples: -->
<!--   - SQL: always use prepared statements                          -->
<!--   - Output: always escape with appropriate function              -->
<!--   - Auth: check permissions on first line of handler             -->
<!--   - Error responses: use consistent format (ok/error helpers)    -->
```

---

## SESSION CHECKLIST

### Before any action (even trivial)
- [ ] Read `CLAUDE.md` (this file)
- [ ] Read `CONTEXT.md` (current state)
- [ ] Consulted `CHANGELOG.md` (last 5 entries)
- [ ] Checked `.github/skills/INDEX.md` (if exists)

### After any session
- [ ] Timestamp obtained via `date '+%Y-%m-%d %H:%M'` (R4)
- [ ] Updated `CONTEXT.md` with timestamp
- [ ] Registered entry in `CHANGELOG.md` with HH:MM
- [ ] Handoff generated (see §HANDOFF)
- [ ] Lint/compile check on ALL modified files (R1)
- [ ] Atomic commit with standardized message
- [ ] `git push origin dev` after each commit
- [ ] `git status` verified — PROHIBITED to end with uncommitted files (R7)
