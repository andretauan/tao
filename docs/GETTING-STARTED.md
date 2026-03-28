# Getting Started with TAO (道)

**Trace · Align · Operate** — an AI-native development framework for GitHub Copilot Agent Mode.

TAO gives Copilot a disciplined operating system: think before you code, plan before you build, execute with guardrails. This guide takes you from zero to productive — fast.

---

## Prerequisites

Before installing TAO, make sure you have:

- **VS Code** with an active **GitHub Copilot** subscription
- **Copilot Chat** enabled with **Agent Mode** available
- **Git** initialized in your project (`git init`)
- **Python 3** (3.8+) — used by hooks and scripts for JSON parsing
- A language with a **CLI linter** (PHP, Python, TypeScript, Go, Ruby, Rust, etc.)

---

## Step 1 — Install TAO

### Clone the TAO repository

```bash
git clone https://github.com/andretauan/tao.git ~/TAO
```

### Run the installer in your project

```bash
cd /path/to/your-project
bash ~/TAO/install.sh .
```

The installer asks 5 quick questions:

1. **Language** — `en` (English) or `pt-br` (Brazilian Portuguese)
2. **Project name** — defaults to your folder name
3. **Description** — one-line summary
4. **Dev branch** — defaults to `dev`
5. **Primary lint stack** — file extension for pre-commit lint (`.py`, `.ts`, `.php`, etc.)

Then it generates your config, copies templates and agents, and installs git hooks. Everything is ready.

### Enable VS Code agent hooks

Open VS Code Settings (JSON) and add:

```json
"chat.useCustomAgentHooks": true
```

This enables TAO's automatic hooks — session context loading and post-edit linting.

<details>
<summary>🔧 L3: What each generated file does</summary>

After installation, your project contains:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Rules for all agents — your project context, stack, conventions |
| `.github/copilot-instructions.md` | Auto-loaded by Copilot every session — points agents to CLAUDE.md |
| `.github/instructions/tao.instructions.md` | TAO-specific instructions (auto-loaded by Copilot) |
| `.github/agents/Execute-Tao.agent.md` | @Execute-Tao — execution orchestrator |
| `.github/agents/Brainstorm-Wu.agent.md` | @Brainstorm-Wu — brainstorm & planning |
| `.github/agents/Shen.agent.md` | @Shen — complex worker (subagent, not user-invocable) |
| `.github/agents/Investigate-Shen.agent.md` | @Investigate-Shen — direct access to the complex worker |
| `.github/agents/Di.agent.md` | @Di — DBA (database operations) |
| `.github/agents/Qi.agent.md` | @Qi — deploy (git operations) |
| `.github/hooks/hooks.json` | VS Code PostToolUse & SessionStart hook definitions |
| `.github/tao/tao.config.json` | Central config — models, paths, lint commands, git settings |
| `.github/tao/CONTEXT.md` | Active phase, state, locked decisions — persists between sessions |
| `.github/tao/CHANGELOG.md` | Structured changelog with timestamps |
| `.github/tao/RULES.md` | Inviolable rules reference |
| `.github/tao/scripts/lint-hook.sh` | Runs linter automatically after every file edit |
| `.github/tao/scripts/enforcement-hook.sh` | Enforces R0/R5 via session state tracking |
| `.github/tao/scripts/context-hook.sh` | Loads context at session start + R2 handoff |
| `.github/tao/scripts/install-hooks.sh` | Installs git pre-commit hook |
| `.github/tao/scripts/pre-commit.sh` | Modular pre-commit lint pipeline |
| `.github/tao/scripts/validate-plan.sh` | Gate: validates PLAN.md decision coverage |
| `.github/tao/scripts/validate-execution.sh` | Gate: validates task execution completeness |
| `.github/tao/scripts/new-phase.sh` | Creates new phase directory structure |
| `.github/tao/scripts/faudit.sh` | Gate: 3-pass quality audit |
| `.github/tao/scripts/forensic-audit.sh` | Gate: deep 3-round forensic audit |
| `.github/tao/scripts/validate-brainstorm.sh` | Gate: brainstorm artifact validation |
| `.github/tao/scripts/doc-validate.sh` | Gate: documentation completeness check |
| `.github/tao/phases/` | Phase templates for creating new phases |

</details>

<details>
<summary>🏗️ L5: Manual installation</summary>

If you prefer to set things up by hand:

1. **Create `tao.config.json`** — copy from `TAO/tao.config.json.example` and fill in your values:

```bash
mkdir -p .github/tao
cp ~/TAO/tao.config.json.example ./.github/tao/tao.config.json
# Edit: project name, description, language, lint commands, branch names
```

2. **Copy templates** for your language (`en` or `pt-br`):

```bash
cp ~/TAO/templates/en/CLAUDE.md ./CLAUDE.md
mkdir -p .github/tao
cp ~/TAO/templates/en/CONTEXT.md ./.github/tao/CONTEXT.md
cp ~/TAO/templates/en/CHANGELOG.md ./.github/tao/CHANGELOG.md
cp ~/TAO/templates/en/RULES.md ./.github/tao/RULES.md
mkdir -p .github/instructions
cp ~/TAO/templates/shared/tao.instructions.md ./.github/instructions/tao.instructions.md
cp ~/TAO/templates/en/copilot-instructions.md ./.github/copilot-instructions.md
```

3. **Copy agents**:

```bash
mkdir -p .github/agents
cp ~/TAO/agents/en/*.agent.md .github/agents/
```

4. **Copy hooks and scripts**:

```bash
mkdir -p .github/hooks .github/tao/scripts
cp ~/TAO/templates/shared/hooks.json .github/hooks/hooks.json
cp ~/TAO/hooks/lint-hook.sh .github/tao/scripts/lint-hook.sh
cp ~/TAO/hooks/enforcement-hook.sh .github/tao/scripts/enforcement-hook.sh
cp ~/TAO/hooks/context-hook.sh .github/tao/scripts/context-hook.sh
cp ~/TAO/hooks/install-hooks.sh .github/tao/scripts/install-hooks.sh
cp ~/TAO/hooks/pre-commit.sh .github/tao/scripts/pre-commit.sh
cp ~/TAO/scripts/validate-plan.sh .github/tao/scripts/validate-plan.sh
cp ~/TAO/scripts/validate-execution.sh .github/tao/scripts/validate-execution.sh
cp ~/TAO/scripts/new-phase.sh .github/tao/scripts/new-phase.sh
cp ~/TAO/scripts/faudit.sh .github/tao/scripts/faudit.sh
cp ~/TAO/scripts/forensic-audit.sh .github/tao/scripts/forensic-audit.sh
cp ~/TAO/scripts/validate-brainstorm.sh .github/tao/scripts/validate-brainstorm.sh
cp ~/TAO/scripts/doc-validate.sh .github/tao/scripts/doc-validate.sh
chmod +x .github/tao/scripts/*.sh
```

5. **Copy phase templates**:

```bash
mkdir -p .github/tao/phases/en .github/tao/phases/shared
cp ~/TAO/phases/en/*.template .github/tao/phases/en/
cp ~/TAO/phases/shared/*.template .github/tao/phases/shared/
```

6. **Install git hooks**:

```bash
bash .github/tao/scripts/install-hooks.sh
```

7. **Enable VS Code hooks** — add `"chat.useCustomAgentHooks": true` to settings.

</details>

---

## Step 2 — Understand the Config

`.github/tao/tao.config.json` is the single source of truth for project-specific settings. Agents read it every session.

The key sections:

- **`project`** — name, description, language (`en` or `pt-br`)
- **`models`** — which AI models agents use (orchestrator, complex worker, free tier)
- **`git`** — dev/main branch names, auto-push toggle
- **`paths`** — where source code, docs, and phases live
- **`lint_commands`** — linter per file extension (used by hooks and agents)
- **`compliance`** — toggle guardrails (skill checks, context reads, changelog, ABEX audit)

<details>
<summary>⚙️ L3: Full config reference</summary>

```json
{
  "project": {
    "name": "MyProject",
    "description": "One-line project description",
    "language": "en"
  },
  "models": {
    "orchestrator": "Claude Sonnet 4.6 (copilot)",
    "complex_worker": "Claude Opus 4.6 (copilot)",
    "free_tier": "GPT-4.1 (copilot)"
  },
  "git": {
    "dev_branch": "dev",
    "main_branch": "main",
    "auto_push": true
  },
  "paths": {
    "source": "src/",
    "docs": "docs/",
    "phases": "docs/phases/",
    "phase_prefix": "phase-"
  },
  "lint_commands": {
    ".py": "python3 -m py_compile {file}",
    ".ts": "npx tsc --noEmit",
    ".php": "php -l {file}",
    ".js": "node --check {file}",
    ".rb": "ruby -c {file}",
    ".go": "go vet {file}",
    ".rs": "cargo check"
  },
  "compliance": {
    "require_skill_check": true,
    "require_context_read": true,
    "require_changelog": true,
    "abex_enabled": true
  },
  "doc_sync": {
    "enabled": false,
    "script": "scripts/doc-sync.sh"
  }
}
```

| Field | Description |
|-------|-------------|
| `project.name` | Used in templates, commit messages, and reports |
| `project.language` | `en` or `pt-br` — controls template language and i18n for `tao.sh` |
| `models.orchestrator` | Model for @Execute-Tao (routine tasks) — typically Sonnet (1x cost) |
| `models.complex_worker` | Model for @Shen and @Brainstorm-Wu (hard tasks) — typically Opus (3x cost) |
| `models.free_tier` | Model for @Di and @Qi — typically GPT-4.1 (free) |
| `git.dev_branch` | Working branch — agents commit here |
| `git.main_branch` | Production branch — agents never push here without explicit order |
| `git.auto_push` | If `true`, agents push after every commit |
| `paths.source` | Your source code directory |
| `paths.phases` | Where phase directories are created |
| `paths.phase_prefix` | Prefix for phase dirs — `phase-` (en) or `fase-` (pt-br) |
| `lint_commands` | Map of file extension → lint command. `{file}` is replaced with the file path |
| `compliance.require_skill_check` | Agents must check for applicable skills before coding |
| `compliance.require_context_read` | Agents must read CONTEXT.md before every session |
| `compliance.require_changelog` | Agents must update CHANGELOG.md after changes |
| `compliance.abex_enabled` | Enable 3-pass audit after task completion (security, UX, performance) |
| `doc_sync.enabled` | Enable documentation sync checks on commit |
| `doc_sync.script` | Path to doc-sync script (if enabled) |

</details>

---

## Step 3 — Create Your First Phase

TAO organizes work into **phases**. Each phase has a brainstorm, a plan, and individual task files.

```bash
bash scripts/new-phase.sh 01 "Project Setup"
```

This creates:

```
docs/phases/phase-01/
├── PLAN.md              # What to build (filled by @Brainstorm-Wu)
├── STATUS.md            # Task table with status tracking
├── progress.txt         # Session log + codebase patterns
├── brainstorm/
│   ├── DISCOVERY.md     # Exploration by topic
│   ├── DECISIONS.md     # IBIS-format decisions
│   └── BRIEF.md         # Compressed synthesis
└── tasks/               # Individual task specs (created by @Brainstorm-Wu)
```

The templates are pre-filled with structure — the agents know exactly what each file expects.

---

## Step 4 — Brainstorm with @Brainstorm-Wu

Open **Copilot Chat** in VS Code, select **@Brainstorm-Wu** from the agent dropdown, and say:

```
brainstorm phase 01
```

Wu explores the problem space, documents findings, and records structured decisions. It operates with total autonomy — no questions, no confirmations. You watch the analysis stream in real-time.

Wu produces three artifacts during brainstorm:

| File | What it contains |
|------|------------------|
| `DISCOVERY.md` | Exploration organized by topic — insights, alternatives, reasoning |
| `DECISIONS.md` | Structured decisions in IBIS format — each with invalidation conditions |
| `BRIEF.md` | Compressed synthesis — only generated when maturity reaches 5/7 |

You can guide the brainstorm with natural language:

- *"explore authentication approaches"* — Wu enters DIVERGE mode
- *"decide between JWT and sessions"* — Wu enters CONVERGE mode
- *"summarize what we have"* — Wu checks maturity and may SYNTHESIZE into a BRIEF

<details>
<summary>🧠 L3: The IBIS Protocol</summary>

Wu uses the **IBIS protocol** (Issue-Based Information System, Kunz & Rittel, 1970) for structured decision-making. Every decision follows this format:

```
Issue     → "Which auth strategy should we use?"
Positions → Option A (JWT), Option B (Sessions), Option C (OAuth only)
Arguments → For/against each position
Decision  → The chosen position + rationale
Invalidation → "Would invalidate if: [condition]"
```

The `DECISIONS.md` file accumulates these over a brainstorm session. Each decision is numbered (D1, D2, ...) and tracked in an index table.

**The invalidation condition is critical.** It records what would make the team reconsider. This prevents zombie decisions — choices that persist long after their assumptions have changed.

**The BRIEF and the 7/7 Maturity Gate:**

Wu only generates `BRIEF.md` (the compressed synthesis) when the brainstorm has reached sufficient maturity. The gate requires at least 5 of 7 criteria:

| # | Criterion |
|---|-----------|
| 1 | Problem/objective is clear |
| 2 | Alternatives explored (≥2 approaches) |
| 3 | Trade-offs evaluated (≥1 IBIS decision) |
| 4 | Decisions have invalidation conditions |
| 5 | Relevant reference docs consulted |
| 6 | Scope defined (in/out) |
| 7 | Existing codebase patterns considered |

The BRIEF is the bridge between brainstorm and plan — it's what @Brainstorm-Wu reads when creating PLAN.md.

</details>

<details>
<summary>📚 L5: Wu's 5 modes explained</summary>

Wu operates in 5 distinct modes, switching based on context:

### DIVERGE
**When:** Exploring ideas, angles, possibilities.
**What it does:** Generates alternatives, questions premises, seeks non-obvious angles. This is creative, expansive thinking — quantity over quality.

### CONVERGE
**When:** Deciding between options, evaluating trade-offs.
**What it does:** Evaluates pros/cons, applies counterfactual reasoning ("what if X fails?"), selects the best option. This is judgment — the mode where Sonnet would fail catastrophically, which is why Wu always runs on Opus.

### CAPTURE
**When:** Every substantive response.
**What it does:** Streams the full analysis in chat, then persists it to disk (DISCOVERY.md / DECISIONS.md). Ends with persistence and next-step blocks. Ensures nothing is lost between sessions.

### SYNTHESIZE
**When:** Compressing brainstorm into a BRIEF.
**What it does:** Judges what to preserve vs. discard. Takes the sprawling DISCOVERY and DECISIONS and condenses them into a focused BRIEF.md with maturity checklist. Only triggers when maturity ≥ 5/7.

### RESUME
**When:** Continuing a previous brainstorm session.
**What it does:** Reads DISCOVERY.md + DECISIONS.md, verifies consistency, presents current state, and picks up where the last session left off. This is context loading — the only mode where Sonnet would be acceptable (though Wu always uses Opus regardless).

</details>

---

## Step 5 — Plan with @Brainstorm-Wu

Once the brainstorm has a mature BRIEF (≥ 5/7), tell @Brainstorm-Wu:

```
plan phase 01
```

Wu reads the BRIEF and creates:

- **`PLAN.md`** — phase overview, task groups (P0 critical → P1 core → P2 polish), execution order, completion criteria
- **`STATUS.md`** — task table with status tracking (⏳ pending, ✅ done, ❌ blocked)
- **Individual task files** in `tasks/` — each with objective, context, files to read, implementation steps, and acceptance criteria

Every task traces back to a decision in the BRIEF. Nothing is implemented without a documented reason.

<details>
<summary>📋 L3: Task file anatomy</summary>

Each task file in `tasks/` follows a consistent structure that agents read and execute:

```markdown
# Task 03 — Create User Authentication

Phase: 01 — Project Setup
Complexity: High
Executor: OPUS
Priority: P1

## Objective
What this task must deliver. 2-3 clear sentences.

## Context
Why this task exists. Technical background.

## Files to Read (BEFORE editing)
- src/config/auth.ts — current auth config
- src/middleware/session.ts — session handling

## Files to Create/Edit
- src/controllers/auth.ts — create with login/logout handlers
- src/middleware/auth.ts — create auth middleware

## Implementation Steps
1. Read all files in "Files to Read"
2. Create auth controller with login endpoint
3. Add session middleware
4. Run lint: tsc --noEmit
5. Verify: curl -s http://localhost:3000/auth/login

## Acceptance Criteria
- [ ] Login endpoint returns 200 with valid credentials
- [ ] Invalid credentials return 401
- [ ] Lint passes without errors
- [ ] Commit made with correct message

## Notes / Gotchas
- Use bcrypt, not plain text
- Session TTL: 24 hours (from BRIEF D2)

Expected commit: feat(phase-01): T03 — create user authentication
```

**Key fields:**
- **Executor** — tells @Execute-Tao whether to handle it directly (SONNET) or route to @Shen (OPUS)
- **Files to Read** — agents MUST read these before editing anything. No guessing.
- **Acceptance Criteria** — verifiable conditions, not subjective opinions
- **Expected commit** — exact format for the commit message

</details>

---

## Step 6 — Execute with @Execute-Tao

Select **@Execute-Tao** from the agent dropdown and say:

```
execute
```

Tao runs an autonomous loop: pick a task, implement it, lint, commit, move to the next one. No questions, no pauses — it works until the phase is complete.

For a single task instead of the full loop:

```
next task
```

Or a specific one:

```
task 03
```

<details>
<summary>🔄 L3: The execution loop</summary>

Here's what @Execute-Tao does on each iteration:

```
1. CHECK_PAUSE  → Is .tao-pause present? → STOP
2. READ_STATUS  → Read STATUS.md → parse task table
3. PLAN_CHECK   → Does PLAN.md exist? Does BRIEF.md exist?
                  → If neither: STOP ("use @Brainstorm-Wu to brainstorm")
4. PICK_TASK    → First ⏳ task in recommended order
                  → If task needs Opus → route to @Shen subagent
5. NO ⏳ LEFT   → Phase complete → report → advance
6. READ_TASK    → Read the full task file
7. READ_FILES   → Read ALL files listed in "Files to Read"
8. EXECUTE      → Implement exactly what the task specifies
9. QUALITY_GATE → Run lint command from tao.config.json
                  → If fail → fix → re-run (max 3 attempts)
                  → If 3 fails → rollback → log in progress.txt
10. COMMIT      → git add <specific files> (never git add -A)
                  → git commit with standardized message
                  → git push (if auto_push is true)
11. MARK_DONE   → STATUS.md: ⏳ → ✅
                  → progress.txt: append entry with timestamp
12. LOOP        → Back to step 1 (immediately, no asking)
```

The loop continues until all tasks are ✅ or a pause file is detected.

**Phase advancement is automatic.** When all tasks in a phase are done, Tao reports completion and can continue to the next phase if one exists.

</details>

<details>
<summary>🤖 L4: Agent routing matrix</summary>

@Execute-Tao routes each task to the right agent based on these criteria (first match wins):

| # | Criterion | Routes to | Cost |
|---|-----------|-----------|------|
| 1 | Task file says `Executor: OPUS` | **@Shen** (Opus) | 3x |
| 2 | Task creates/reviews a plan | **@Brainstorm-Wu** (Opus) | 3x |
| 3 | Architecture decision (new module, multi-system integration) | **@Shen** (Opus) | 3x |
| 4 | Security-critical (auth, crypto, HMAC) | **@Shen** (Opus) | 3x |
| 5 | High complexity + design trade-offs | **@Shen** (Opus) | 3x |
| 6 | Task file says `Executor: DBA` | **@Di** (GPT-4.1) | free |
| 7 | Database migration, schema change | **@Di** (GPT-4.1) | free |
| 8 | Git operations (commit, push, merge) | **@Qi** (GPT-4.1) | free |
| 9 | Everything else (CRUD, views, fixes, tests) | **@Execute-Tao** directly (Sonnet) | 1x |

**The math:** A typical phase has ~10 tasks. Without routing, all 10 use Opus (30x). With TAO: 2 Opus (6x), 6 Sonnet (6x), 2 free (0x) = **12x total — a 60% reduction.**

</details>

<details>
<summary>🛡️ L5: Guardrails system</summary>

TAO wraps execution in multiple layers of protection:

### Pre-commit Hooks
The `scripts/pre-commit.sh` runs your configured linter against every changed file before allowing a commit. Syntax errors never reach the repo.

### Compliance Check
Every response that modifies code begins with a compliance block:

```
COMPLIANCE CHECK
├─ Skills consulted: [list]
├─ Files read before editing: [list]
├─ CONTEXT.md read: YES
├─ CHANGELOG.md consulted: YES
└─ Doc sync: [status]
```

If the block is missing, the response is invalid. This ensures agents always orient before acting.

### ABEX 3× Audit
After completing implementation, agents run three mental passes:

1. **Security** ("I am an attacker") — SQL injection, XSS, CSRF, auth bypass, empty catch blocks
2. **User** ("I am a real visitor") — UX, accessibility, copy, mobile behavior
3. **Performance** ("I am a Core Web Vitals auditor") — N+1 queries, DOM size, CLS, LCP

### Skill Checks
Before any technical task, agents consult the skills index (if present) and read applicable skill documents. This provides domain-specific knowledge — like security patterns for auth tasks, or optimization patterns for database work.

### Context Persistence
Session start hooks automatically load `CONTEXT.md` and `CLAUDE.md`. Every session ends by updating these files, so the next session starts with full context. Nothing is lost between conversations.

### Pause System
Create a kill switch at any time:

```bash
./tao.sh pause
```

This creates `.tao-pause` — all agents check for this file at the start of every loop iteration and stop immediately if found. Remove it with `./tao.sh unpause`.

</details>

---

## Step 7 — Monitor Progress

TAO includes `tao.sh` for monitoring from the terminal — no need to open VS Code.

### Check status of all phases

```bash
./tao.sh status
```

### Get a detailed report for a specific phase

```bash
./tao.sh report 01
```

### Simulate what agents would do (dry run)

```bash
./tao.sh dry-run 01
```

### Pause / unpause the execution loop

```bash
./tao.sh pause     # creates .tao-pause — agents stop at next check
./tao.sh unpause   # removes .tao-pause — say "execute" to resume
```

> **Note:** `tao.sh` is for monitoring only. All execution happens through Copilot agents in VS Code.

---

## The Complete Workflow

Here's the full cycle at a glance:

```
1. Install          bash ~/TAO/install.sh .
2. Create phase     bash scripts/new-phase.sh 01 "Feature Name"
3. Brainstorm       @Brainstorm-Wu → "brainstorm phase 01"
4. Plan             @Brainstorm-Wu → "plan phase 01"
5. Execute          @Execute-Tao → "execute"
6. Monitor          ./tao.sh status
7. Next phase       bash scripts/new-phase.sh 02 "Next Feature"
8. Repeat           @Brainstorm-Wu brainstorm → @Brainstorm-Wu plan → @Execute-Tao execute
```

---

## Tips & Troubleshooting

### Agents don't appear in the dropdown

- Verify `.github/agents/*.agent.md` files exist in your project
- Check that `chat.useCustomAgentHooks: true` is set in VS Code settings
- Restart VS Code after installing TAO

### Lint hook fails on every edit

- Check `lint_commands` in `tao.config.json` — make sure the command for your file extension is correct
- Test manually: run the lint command on a file to see if it works outside of TAO
- If you don't want lint hooks, set `lint_commands` to `{}` in config

### @Execute-Tao says "phase requires brainstorm"

- `PLAN.md` doesn't exist yet for the active phase
- Run `@Brainstorm-Wu → "plan phase XX"` first (brainstorm with BRIEF if you haven't already)
- Or create PLAN.md and STATUS.md manually if you prefer to skip brainstorming

### @Brainstorm-Wu won't generate a BRIEF

- The maturity gate requires ≥ 5/7 criteria met
- Tell Wu to `"check maturity"` to see which criteria are missing
- Address the gaps in DISCOVERY.md and DECISIONS.md, then try again

### Context seems lost between sessions

- Ensure `CONTEXT.md` exists and is being updated
- Check that `.github/hooks/hooks.json` is present — it triggers context loading on session start
- Verify `chat.useCustomAgentHooks: true` in VS Code settings

### Wrong agent is used for a task

- Check the `Executor` field in the task file (`tasks/NN-name.md`)
- `SONNET` = Tao handles it directly, `OPUS` = routed to Shen
- Edit the task file to change routing if needed

### Agents commit to the wrong branch

- Check `git.dev_branch` in `tao.config.json`
- Agents always use the configured dev branch — switch to it before starting execution

### Phase is stuck / need to restart

```bash
# Reset all tasks to pending
cd docs/phases/phase-01
# Edit STATUS.md: change ✅ or ❌ back to ⏳
# Then: @Execute-Tao → "execute"
```

---

## What's Next

- **Customize `CLAUDE.md`** — add your project's conventions, architecture decisions, and stack-specific rules
- **Add skills** — create `.github/skills/` with domain knowledge for your project
- **Explore the agents** — read the `.agent.md` files to understand each agent's full protocol
- **Set up doc-sync** — enable `doc_sync` in config if you want documentation drift detection
