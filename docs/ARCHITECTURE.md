# TAO Architecture — Three Layers + Guardrails

> **Master architecture document.** An agent that reads this document can replicate the entire system in any project with full accuracy.

*Version: 0.1.0*

---

## 1. Overview

TAO (道 — Trace · Align · Operate) is an AI agent orchestration system for autonomous software development using GitHub Copilot's Agent Mode. It provides:

- **Three-layer workflow:** Think → Plan → Execute
- **Intelligent model routing** via VS Code Custom Agents and YAML frontmatter
- **Deterministic hooks** (0 LLM cost) for quality gates
- **Cost optimization** of GitHub Copilot premium requests
- **Bilingual support** (EN + PT-BR) with cultural adaptation

### The Problem TAO Solves

Without TAO: operators manually choose models, switch agents, remember to lint, lose context between sessions, and skip planning.

With TAO: the operator says **"execute"** and the system:
1. Reads the active phase automatically (SessionStart hook)
2. Selects the correct model per task (routing matrix)
3. Delegates complex tasks to Opus via subagent
4. Runs quality gates automatically (PostToolUse hook)
5. Commits each task individually
6. Advances to the next phase when complete

---

## 2. System Components

### 2.1 File Structure

After installation, a TAO project contains:

```
project/
├── tao.config.json                      ← Central config (models, paths, lint, git)
├── CLAUDE.md                            ← Rules for all agents
├── CONTEXT.md                           ← Active phase, state, decisions
├── CHANGELOG.md                         ← Structured change log
├── .github/
│   ├── copilot-instructions.md          ← Minimal pointer to CLAUDE.md
│   ├── agents/
│   │   ├── Tao.agent.md                 ← Orchestrator (Sonnet)
│   │   ├── Wu.agent.md                  ← Brainstorm & planning (Opus)
│   │   ├── Shen.agent.md               ← Complex worker (Opus) — subagent only
│   │   ├── Shen-Architect.agent.md      ← Direct access (Opus) — user-invocable
│   │   ├── Di.agent.md                  ← Database (GPT-4.1) — subagent only
│   │   └── Qi.agent.md                 ← Deploy (GPT-4.1) — subagent only
│   └── hooks/
│       └── hooks.json                   ← PostToolUse + SessionStart config
├── scripts/
│   ├── lint-hook.sh                     ← PostToolUse — lint after file edit
│   ├── context-hook.sh                  ← SessionStart — inject context
│   ├── install-hooks.sh                 ← Git hook installer
│   └── pre-commit.sh                   ← Modular pre-commit pipeline
└── docs/phases/{phase_prefix}XX/
    ├── PLAN.md
    ├── STATUS.md
    ├── progress.txt
    ├── brainstorm/
    │   ├── DISCOVERY.md
    │   ├── DECISIONS.md
    │   └── BRIEF.md
    └── tasks/NN-name.md
```

### 2.2 tao.config.json — Centralized Configuration

All project-specific values live in `tao.config.json`. No manual find-and-replace needed.

```json
{
  "project": {
    "name": "MyProject",
    "description": "One-line description",
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
    ".php": "php -l {file}",
    ".py": "python3 -m py_compile {file}",
    ".ts": "npx tsc --noEmit",
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

### 2.3 Custom Agents (VS Code)

Custom Agents are defined by `.agent.md` files with YAML frontmatter. VS Code loads them automatically and shows them in the Copilot Chat dropdown.

**Reference:** https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents

#### Required Frontmatter

```yaml
---
name: AgentName                          # Shown in dropdown as @AgentName
description: "What this agent does"      # Tooltip
model: Claude Sonnet 4.6 (copilot)      # Fixed model (overrides session)
tools: [list, of, tools]                 # Permitted tools
agents: [Subagent1, Subagent2]          # Invocable subagents
user-invocable: true                     # false = only callable as subagent
---
```

#### Key Fields

| Field | Effect |
|---|---|
| `model:` | **Overrides session model.** The specified model is used whenever this agent runs. |
| `agents:` | **Restricts subagents.** `[]` = cannot invoke any. Requires `agent` in `tools:`. |
| `user-invocable: false` | **Hidden from dropdown.** Only callable as subagent by another agent. |
| `tools:` | **Permitted tools.** Use `agent` (not `agent/runSubagent`) when `agents:` is set. |

#### Model Strings

| String | Model | Cost (premium requests) |
|---|---|---|
| `Claude Opus 4.6 (copilot)` | Opus 4.6 | 3x |
| `Claude Sonnet 4.6 (copilot)` | Sonnet 4.6 | 1x |
| `GPT-4.1 (copilot)` | GPT-4.1 | **0x (free)** |
| `o4-mini (copilot)` | o4-mini | 1x |
| `Gemini 2.5 Pro (copilot)` | Gemini 2.5 Pro | 1x |

**Source:** https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests

#### Model Fallback

Use an array for automatic fallback:
```yaml
model:
  - Claude Sonnet 4.6 (copilot)
  - GPT-4.1 (copilot)
```
If Sonnet hits rate limits, GPT-4.1 is used automatically.

### 2.4 Subagents

Subagents are invoked by another agent via `runSubagent`. Characteristics:

- **Context-isolated:** Do NOT inherit parent conversation, instructions, or copilot-instructions.md
- **Model override:** Use the model from their own `.agent.md`
- **Own toolset:** Defined in their frontmatter
- **Synchronous:** Parent waits for subagent to finish

**Critical implication:** Since subagents don't inherit context, the parent's prompt must contain EVERYTHING the subagent needs (phase, task, files, decisions). The `.agent.md` must contain project information inline.

### 2.5 Hooks

Hooks are executables that run at specific points in the Copilot lifecycle. They are **deterministic** (no LLM) and cost **0 premium requests**.

**Reference:** https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_hooks

#### Hook Types

| Hook | When | Use in TAO |
|---|---|---|
| `PostToolUse` | After EACH tool call | Auto-lint after file edits |
| `SessionStart` | Start of new chat session | Inject TAO context (phase, branch, tasks) |

#### Hook Scope

Hooks are defined at workspace level in `.github/hooks/*.json`.

**Required VS Code setting:**
```json
{
  "chat.useCustomAgentHooks": true
}
```

#### Hook Script I/O

**Input:** JSON via stdin
```json
{
  "tool_name": "editFiles",
  "tool_input": { "filePath": "/path/to/file.py" },
  "tool_response": "..."
}
```

**Output:** JSON via stdout
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Message injected into agent conversation"
  }
}
```

Silent mode: `exit 0` with no output.

### 2.6 Instructions Stacking

VS Code combines ALL these instruction sources:

1. `.github/copilot-instructions.md` — **Always on** (all agents/modes)
2. `CLAUDE.md` — Referenced as workspace instructions
3. `.agent.md` of the active agent — Content below frontmatter
4. Hook output — `additionalContext` injected at runtime

**Consequence:** `copilot-instructions.md` must be **slim** (universal rules only), because it's read by ALL agents including subagents that have their own instructions.

---

## 3. Agent Hierarchy

### 3.1 Diagram

```
User
 ├── @Tao (Sonnet 4.6 — 1x) ─────── Orchestrator (execution loop)
 │   ├── Shen (Opus 4.6 — 3x)        │ Subagent for complex tasks
 │   ├── Di (GPT-4.1 — 0x)           │ Subagent for database
 │   └── Qi (GPT-4.1 — 0x)           │ Subagent for git/deploy
 │
 ├── @Wu (Opus 4.6 — 3x) ──────────── Brainstorm & planning (IBIS)
 │
 └── @Shen-Architect (Opus 4.6 — 3x)  Direct access outside the loop
     ├── Di (GPT-4.1 — 0x)
     └── Qi (GPT-4.1 — 0x)
```

### 3.2 Agent Roles

| Agent | Invoked By | When |
|---|---|---|
| **@Tao** | User (dropdown) | "execute", "continue" — task loop |
| **Shen** | Tao (subagent) | Complex tasks, security-critical, architecture |
| **@Wu** | User (dropdown) | "brainstorm phase 01", "plan phase 01" |
| **@Shen-Architect** | User (dropdown) | Debugging, architecture decisions outside the loop |
| **Di** | Tao or Shen-Architect (subagent) | Migrations, schema, query performance |
| **Qi** | Tao or Shen-Architect (subagent) | Git commit, push, merge |

### 3.3 Routing Matrix

The @Tao orchestrator evaluates each task and decides:

| Criterion | Action |
|----------|------|
| STATUS.md "Executor: Architect" | → Shen subagent (3x) |
| High complexity + design trade-offs | → Shen subagent (3x) |
| Security: auth, HMAC, crypto | → Shen subagent (3x) |
| New phase plan or STATUS.md | → Shen subagent (3x) |
| System prompt / LLM rewrite | → Shen subagent (3x) |
| "Executor: DBA" | → Di subagent (0x) |
| Bug failed 3x without resolution | → Shen subagent (3x) |
| CRUD, views, routine features | → Tao direct (Sonnet, 1x) |
| Everything else | → Tao direct (Sonnet, 1x) |

---

## 4. Model Economics

### 4.1 Cost per Request

| Model | Multiplier | Used By |
|---|---|---|
| Opus 4.6 | 3x | Shen, Shen-Architect, Wu |
| Sonnet 4.6 | 1x | Tao |
| GPT-4.1 | **0x (free)** | Di, Qi, fallback |

### 4.2 Typical Session Calculation

**Without TAO** (Opus for everything):
- 6 tasks × ~8 turns × 3x = **~144 premium requests**
- Monthly: ~300 / 144 = **~2 sessions/month**

**With TAO:**
- 4 tasks Sonnet × ~8 turns × 1x = 32
- 2 tasks Opus subagent × ~10 turns × 3x = 60
- Di/Qi calls × 0x = 0
- **Total: ~92 → ~3.2 sessions/month (+60%)**

**Best case** (mostly CRUD):
- 5 Sonnet × 8 × 1x = 40
- 1 Opus × 10 × 3x = 30
- **Total: ~70 → ~4.3 sessions/month (+115%)**

### 4.3 Zero-Cost Operations

- Hooks (lint, context injection) = **0 premium requests** (deterministic)
- Di subagent (GPT-4.1) = **0 premium requests**
- Qi subagent (GPT-4.1) = **0 premium requests**
- Tao fallback to GPT-4.1 = **0 premium requests** (if Sonnet rate-limited)

---

## 5. The Three Layers

### Layer 1 — Think (Brainstorm)

**Agent:** @Wu (Opus)
**Protocol:** IBIS (Issue-Based Information System, Kunz & Rittel 1970)

1. **DIVERGE** — Explore ideas, question assumptions, generate alternatives
2. **CONVERGE** — Evaluate trade-offs, apply counterfactual reasoning
3. **CAPTURE** — Persist to disk (DISCOVERY.md + DECISIONS.md)
4. **SYNTHESIZE** — Compress into BRIEF.md (only when maturity ≥ 5/7)
5. **RESUME** — Load previous state and continue

**Artifacts:**
| File | Format | Content |
|---|---|---|
| `DISCOVERY.md` | By topic (Tulving — Encoding Specificity) | Insights, alternatives, exploration |
| `DECISIONS.md` | IBIS format | Issue → Positions → Arguments → Decision + "Would invalidate if..." |
| `BRIEF.md` | Maturity checklist (7 items) | Compressed synthesis — bridge to PLAN.md |

**Maturity Gate (7/7):**
1. Problem/objective is clear
2. ≥2 alternatives explored
3. Trade-offs evaluated (≥1 IBIS issue with positions + arguments)
4. Decisions have invalidation conditions
5. Relevant docs consulted
6. Scope defined (in/out)
7. Codebase patterns considered

### Layer 2 — Plan

**Agent:** @Wu (Opus) — Sonnet is forbidden from planning (see "Sonnet Never Plans")
**Input:** BRIEF.md (maturity ≥ 5/7)
**Output:** PLAN.md + STATUS.md + individual task files

Each task file contains:
- Description of what to implement
- Files to read before editing
- Files to create/edit
- Acceptance criteria
- Executor designation (Sonnet / Opus / DBA)
- Complexity rating

### Layer 3 — Execute

**Agent:** @Tao (Sonnet) + subagents
**Input:** STATUS.md with task table

**Execution Loop (pseudocode):**
```
TRIGGER: user says "execute" to @Tao

LOOP {
  1. CHECK_PAUSE   → .tao-pause exists → STOP
  2. READ_STATUS   → parse task table
  3. PICK_TASK     → first ⏳ in recommended order
  4. ROUTE_TASK    → routing matrix → Sonnet direct OR subagent
  5. NO ⏳         → PHASE COMPLETE → ADVANCE_PHASE → LOOP or STOP
  6. READ_TASK     → read full task spec
  7. READ_FILES    → read ALL listed files
  8. EXECUTE       → implement (or delegate via subagent)
  9. QUALITY_GATE  → lint via hooks + manual checks
  10. COMMIT       → git add <specific> → commit → push
  11. MARK_DONE    → STATUS.md: ⏳→✅, progress.txt: append
  12. GOTO 1       → immediately, no stopping
}
```

### Guardrails (Transversal)

Guardrails operate across all three layers:

| Gate | When | How |
|---|---|---|
| Pre-commit hooks | Every commit | Modular lint pipeline (reads tao.config.json) |
| PostToolUse hooks | Every file edit | Auto-lint by extension (0 LLM cost) |
| SessionStart hooks | Every new session | Inject phase, branch, task count |
| Compliance check | Every code-modifying response | Skills read, files read, context verified |
| ABEX 3× audit | After task completion | Security → User → Performance passes |
| Skill check | Before any code task | Read relevant skills from INDEX.md |
| Context persistence | Every session | CONTEXT.md updated, progress.txt appended |
| Kill switch | Anytime | `.tao-pause` file stops the loop |

---

## 6. Hook Specifications

### 6.1 lint-hook.sh (PostToolUse)

**Purpose:** Auto-lint after any file edit, language-agnostic.

**Flow:**
1. Receive JSON via stdin with `tool_name` and `tool_input`
2. Filter by tool: `editFiles`, `create_file`, `replace_string_in_file`, `multi_replace_string_in_file`
3. Extract `filePath`
4. Read `tao.config.json` → `lint_commands` → match by extension
5. Run lint command with `{file}` placeholder replaced
6. If error: output JSON with `additionalContext` containing the error
7. If ok: `exit 0` silent

**Cost:** 0 premium requests.

### 6.2 context-hook.sh (SessionStart)

**Purpose:** Inject TAO context at session start, eliminating 2-3 roundtrips of file reading.

**Flow:**
1. Read `tao.config.json` → extract phase prefix, paths
2. Read `CONTEXT.md` → extract active phase number
3. Read `git branch` → current branch
4. Read `STATUS.md` → count ⏳ and ✅ tasks
5. Check `.tao-pause` → paused state
6. Output JSON with consolidated `additionalContext`

**Cost:** 0 premium requests.

---

## 7. VS Code Settings

```json
{
  "chat.useCustomAgentHooks": true
}
```

Add to `.vscode/settings.json` or global user settings.

---

## 8. Subagent Prompt Format

When @Tao invokes Shen, the prompt must contain:

```
Phase {XX}, Task T{NN}: {title}

Context:
- Branch: {dev_branch from config}
- Phase: {description}
- Locked decisions: {from CONTEXT.md}

Full task spec:
{complete content of the task file}

Files to read before editing:
{list}

On completion:
1. Commit: git add <files> && git commit -m "type(phase-XX): TNN — description" && git push
2. Return: list of files created/edited + commit hash
```

---

## 9. "Sonnet Never Plans" Rule

> The cost of a bad plan >>> the cost of using Opus to plan.

| Activity | Model | Why |
|----------|-------|-----|
| Explore ideas (DIVERGE) | **Opus** | Requires counterfactual reasoning |
| Decide trade-offs (CONVERGE) | **Opus** | Judgment — where Sonnet fails catastrophically |
| Transcribe decisions (CAPTURE) | **Sonnet** | Mechanical — records what was decided |
| Synthesize into BRIEF (SYNTHESIZE) | **Opus** | Compression with judgment |
| Load context (RESUME) | **Sonnet** | Mechanical — read files and present state |
| Create PLAN.md | **Opus** | Planning = deciding decomposition and dependencies |
| Review PLAN.md | **Opus** | Evaluating completeness = judgment |
| Execute PLAN.md | **Sonnet** | Following clear instructions from a validated plan |

---

## 10. Validation Tests

### Structural (verify before use)

| # | Test | How |
|---|---|---|
| E1 | Agents appear in dropdown | VS Code → Copilot Chat → agent dropdown |
| E2 | Shen/Di/Qi NOT in dropdown | Verify `user-invocable: false` hides them |
| E3 | Lint hook executes | Edit a file with syntax error → should get error message |
| E4 | Context hook injects | Open chat with @Tao → should see phase/branch/tasks |
| E5 | Scripts are executable | `ls -la scripts/*.sh` → should have `x` permission |

### Functional

| # | Test | Expected |
|---|---|---|
| F1 | `@Tao execute` with 1 ⏳ task | Executes, commits, marks ✅ |
| F2 | Task marked "Executor: Architect" | Tao invokes Shen subagent |
| F3 | Task "Executor: DBA" | Tao invokes Di subagent |
| F4 | Edit file with syntax error | Hook injects correction message |
| F5 | `@Shen-Architect` with hard problem | Uses Opus, resolves |
| F6 | All phases complete | Tao reports "PROJECT COMPLETE" |
| F7 | `.tao-pause` exists | Tao stops at next iteration |
| F8 | All tasks ✅ | Tao reports "PHASE COMPLETE", advances |

---

## 11. Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| Agent not in dropdown | Invalid YAML frontmatter | Check indentation, quotes, `---` delimiters |
| Hook not executing | Script not executable | `chmod +x scripts/*.sh` |
| Hook not running at all | Setting disabled | `chat.useCustomAgentHooks: true` |
| Subagent lacks project context | Context-isolated | Include project info in `.agent.md` inline |
| Wrong model activated | Incorrect model string | Use exact string: `Claude Sonnet 4.6 (copilot)` |
| `agent` tool error | `agents:` set without `agent` in `tools:` | Add `agent` to tools list |
| Lint command not found | CLI tool not installed | Install the linter for your language |
| Context hook empty | No CONTEXT.md found | Run installer or create CONTEXT.md manually |

---

## 12. References

- [VS Code Custom Agents](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_custom-agents)
- [VS Code Agent Hooks](https://code.visualstudio.com/docs/copilot/chat/chat-agent-mode#_hooks)
- [GitHub Premium Requests](https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests)
- [IBIS — Kunz & Rittel (1970)](https://en.wikipedia.org/wiki/Issue-based_information_system)
