# TAO-DNA — The Patterns Behind the Framework

> **This document describes the universal patterns, principles, and design decisions that make TAO work.** It is IDE-agnostic, tool-agnostic, and model-agnostic. Anyone who understands these patterns can build a TAO-compatible system for any environment — VS Code, Cursor, Cline, Windsurf, Claude Code, a desktop app, or something that doesn't exist yet.
>
> TAO-DNA is not documentation of _how to use TAO_. It's documentation of _how to think TAO_.

*Version: 1.0.0 — 2026-03-28*

---

## Table of Contents

1. [The Core Problem](#1-the-core-problem)
2. [The Seven Invariants](#2-the-seven-invariants)
3. [Pattern 1 — The Autonomous Loop](#3-pattern-1--the-autonomous-loop)
4. [Pattern 2 — Cognitive Separation of Concerns](#4-pattern-2--cognitive-separation-of-concerns)
5. [Pattern 3 — Model Routing by Capability](#5-pattern-3--model-routing-by-capability)
6. [Pattern 4 — Deterministic Guardrails](#6-pattern-4--deterministic-guardrails)
7. [Pattern 5 — Context Persistence](#7-pattern-5--context-persistence)
8. [Pattern 6 — Injectable Knowledge](#8-pattern-6--injectable-knowledge)
9. [Pattern 7 — Self-Healing Pipeline](#9-pattern-7--self-healing-pipeline)
10. [Pattern 8 — Structured Deliberation](#10-pattern-8--structured-deliberation)
11. [Anti-Patterns](#11-anti-patterns)
12. [Translation Map](#12-translation-map)
13. [Design Principles](#13-design-principles)

---

## 1. The Core Problem

Every AI coding system hits the same wall:

**The operator babysits the agent.** They prompt task by task, manually choose models, forget to lint, lose context between sessions, skip planning, and pay premium prices for work that a cheaper model could handle. The AI has no memory, no plan, no discipline, and no awareness of its own limits.

The result is a human reduced to a mid-level project manager for an amnesiac intern. This is the opposite of leverage.

**What TAO solves:** The operator says one word — _execute_ — and the system enters an autonomous loop. It reads its own plan, picks the next task, evaluates its difficulty, delegates to the right capability tier, implements, validates, commits, and loops. Not once. Not five times. Until every task in the phase is done.

The operator returns to find atomic commits, one per task, all traceable to a plan, all lint-clean, all on the right branch. This is leverage.

---

## 2. The Seven Invariants

These are the laws of the system. Every pattern, every agent, every hook exists to enforce one of these. If an implementation violates any of these, it is not TAO-compatible.

| # | Invariant | Why it exists |
|---|-----------|--------------|
| **I1** | **The loop never asks.** The system executes, delivers, and reports. It never pauses for human confirmation during routine work. Autonomy is not a convenience — it's the core mechanism. A system that asks is a chat assistant, not an orchestrator. | Asking breaks flow. Every pause costs context, time, and cognitive load on the operator. |
| **I2** | **Thinking and doing are separated.** The entity that decides _what_ to build is forbidden from deciding _how_ to build each piece. Planning requires deep reasoning. Execution requires cost efficiency. These are opposing pressures and must live in different components. | A cheap model that plans creates bad plans. An expensive model that does CRUD wastes money. Both are worse than separation. |
| **I3** | **Every task has a predetermined capability tier.** Before execution begins, the plan specifies whether a task needs high capability, standard capability, or domain-specific capability. The executor does not improvise — it reads the assignment. | Without pre-assignment, the orchestrator always routes to itself (path of least resistance) or always escalates (path of least risk). Both waste resources. |
| **I4** | **What can be checked deterministically must not be checked by LLM.** Syntax errors, file existence, branch protection, config validation, placeholder detection — these have binary ground truth. Using an LLM to verify them is wasted cost and probabilistic where certainty is available. | Every LLM call costs money and time. Deterministic checks are free, instant, and 100% reliable. |
| **I5** | **Context survives sessions.** The system writes its state to disk after every meaningful action. A new session reads the state and knows: what phase is active, what was done, what's pending, what decisions were locked. The LLM's context window is ephemeral. Disk is permanent. | Without persistence, every session starts cold. The operator re-explains the project, the agent re-reads files it already read, and subtle decisions from prior sessions are silently lost. |
| **I6** | **Every commit is atomic and traceable.** One task = one commit. The commit message references the phase and task number. The task file references the plan. The plan references the brief. The brief references the brainstorm decisions. No orphan changes. | Traceability is how you debug not just code, but _decisions_. "Why was this built this way?" is always answerable by following the chain backwards. |
| **I7** | **The system fails loudly, never silently.** If a lint check fails, the commit is blocked. If a plan doesn't trace to the brainstorm, execution is blocked. If context is stale, a warning fires. No gate is skippable. | Silent failures compound. A skipped lint today becomes a broken deploy in three sessions. The cost of catching an error grows exponentially with time-to-detection. |

---

## 3. Pattern 1 — The Autonomous Loop

### Abstract Pattern

```
STATE = read_persistent_state()

LOOP {
  1. CHECK_KILL_SWITCH    → if active → STOP
  2. READ_TASK_QUEUE      → parse queue for next pending task
  3. VALIDATE_PREREQUISITES → plan exists? brainstorm exists? gates pass?
  4. SELECT_TASK           → first pending in priority order
  5. ROUTE_TO_CAPABILITY   → evaluate task → assign to capability tier
  6. EXECUTE_TASK           → implement (directly or via delegation)
  7. VALIDATE_OUTPUT        → run deterministic checks
  8. PERSIST_RESULT         → commit + update state
  9. MARK_COMPLETE          → update queue
  10. → GOTO 1              (immediately, no pause)
}

WHEN QUEUE_EMPTY {
  RUN_EXIT_GATES           → full validation pipeline
  ADVANCE_TO_NEXT_PHASE    → or STOP if project complete
}
```

### Key Characteristics

- **Unbounded by default.** The loop runs until there are no more tasks, not until some arbitrary limit. The kill switch (step 1) is the escape hatch.
- **Queue-driven, not prompt-driven.** The loop reads a structured task queue (STATUS.md in TAO), not natural language instructions. This makes it deterministic — same queue always produces the same execution order.
- **Self-recovering.** If a task fails validation 3 times, it's marked as skipped (not blocked forever). The loop continues.
- **Phase-aware.** When the current phase is complete, the loop doesn't stop — it advances to the next phase if one exists.

### Why This Matters

Without the loop, every task requires a human prompt. N tasks require N prompts, N context switches, N opportunities for the operator to lose focus. The loop reduces this to 1 prompt: "execute."

### Primitives Required

To implement the autonomous loop, you need these primitives in your target platform:

| Primitive | What it does | VS Code implementation |
|-----------|-------------|----------------------|
| **Persistent state read** | Read structured files from disk | `readFile` tool |
| **Persistent state write** | Write structured files to disk | `editFiles` / `createFile` tools |
| **Task delegation** | Invoke another agent/model for a specific task | `runSubagent` tool |
| **Command execution** | Run shell commands (lint, git, scripts) | `runInTerminal` tool |
| **File search** | Find files by path or content | `fileSearch` / `textSearch` tools |
| **Kill switch check** | Test for file existence | `runInTerminal` → `test -f` |

---

## 4. Pattern 2 — Cognitive Separation of Concerns

### Abstract Pattern

The system divides AI work into three cognitive tiers, each forbidden from doing the other's job:

```
┌─────────────────────────────────────────────┐
│  TIER 1 — DELIBERATION (Think)              │
│  • Generates ideas, explores alternatives    │
│  • Evaluates trade-offs                      │
│  • Produces structured decisions             │
│  • MUST use deep reasoning capability        │
│  • FORBIDDEN from writing code               │
├─────────────────────────────────────────────┤
│  TIER 2 — PLANNING (Plan)                   │
│  • Decomposes decisions into executable tasks│
│  • Assigns capability requirements per task  │
│  • Defines acceptance criteria               │
│  • MUST use deep reasoning capability        │
│  • FORBIDDEN from writing code               │
├─────────────────────────────────────────────┤
│  TIER 3 — EXECUTION (Do)                    │
│  • Implements tasks as specified             │
│  • Delegates tasks above its capability      │
│  • Follows quality gates                     │
│  • Uses cheapest model that satisfies the    │
│    task's capability requirement             │
│  • FORBIDDEN from changing the plan          │
└─────────────────────────────────────────────┘
```

### Enforcement Mechanisms

Cognitive separation is not a suggestion. It must be enforced architecturally:

1. **Model constraint.** The deliberation tier uses the highest-capability model available. The execution tier uses the most cost-efficient model. They are different models (or at minimum, different configurations). If you use one model for everything, you've collapsed the tiers.

2. **Tool restriction.** The deliberation component has no access to code-editing tools. It can read code (for context) but cannot write it. This prevents it from "just quickly implementing" something during brainstorming.

3. **Artifact boundaries.** Deliberation produces decisions. Planning produces task specs. Execution produces code. Each tier writes only its own artifact type.

4. **Anti-escalation.** The executor cannot decide that a simple task is actually complex and escalate it. The plan pre-assigns complexity. The executor follows the assignment.

### Why This Matters

The most expensive failure mode in AI-assisted development is not a bug — it's a _bad plan_. A bad plan executed perfectly still produces the wrong software. And a cheap model can't tell you the plan is bad because it lacks the reasoning depth to evaluate it in the first place.

Conversely, using an expensive model for every CRUD endpoint is economic waste. The separation ensures the expensive model is used only where it adds value.

### The "Sonnet Never Plans" Principle

This is the canonical expression of cognitive separation. Expressed abstractly:

> A model optimized for speed/cost is **prohibited** from: generating ideas, deciding trade-offs, evaluating plan completeness, or synthesizing decisions. It may _transcribe_ decisions already made and _execute_ plans already validated. It may not _think_ about whether those decisions or plans are correct.

The name comes from TAO's VS Code implementation (Claude Sonnet is the fast/cheap model), but the principle is universal. If your system uses GPT-4o-mini as the executor, the rule is "4o-mini Never Plans." If it uses Gemini Flash, the rule is "Flash Never Plans."

---

## 5. Pattern 3 — Model Routing by Capability

### Abstract Pattern

```
FOR each task in queue:
  capability_required = task.executor_assignment    // from plan
  
  ROUTING_MATRIX:
    IF capability_required == "high"           → deep_reasoning_model
    IF capability_required == "domain_specific" → specialized_model (or free tier)
    IF capability_required == "standard"        → cost_efficient_model
    
    // Dynamic escalation (overrides plan):
    IF task involves security/crypto/auth       → deep_reasoning_model
    IF task failed 3× at current tier           → escalate one tier
    IF task is first in a new phase (planning)  → deep_reasoning_model

  FALLBACK_CHAIN:
    IF primary_model rate-limited → try next in chain
    IF all models rate-limited → STOP + report
```

### The Economic Insight

Not all tasks are equal. In a typical project phase:

- ~20% of tasks require deep reasoning (architecture, security, complex logic)
- ~60% of tasks are routine (CRUD, forms, endpoints, tests, CSS)
- ~20% of tasks are mechanical (git operations, migrations, config changes)

Without routing, all tasks go through the most expensive model. With routing:

| Without routing | With routing |
|----------------|-------------|
| 10 tasks × expensive model = 10 × 3x = **30x cost** | 2 expensive (6x) + 6 standard (6x) + 2 free (0x) = **12x cost** |

This is a ~60% reduction for the same output quality — because the 60% of routine tasks produce identical results on a cheaper model.

### Capability Tiers (Abstract)

| Tier | Used for | Characteristic |
|------|---------|----------------|
| **Deep reasoning** | Architecture, security, planning, complex debugging | Highest capability, highest cost. Used sparingly. |
| **Standard execution** | CRUD, features, tests, views, bug fixes | Good quality, low cost. The workhorse. |
| **Domain-specific / Free** | Database operations, git operations, deploy | Specialized or zero-cost. For predictable tasks. |

### Fallback Chains

Every model has a fallback. If the primary is rate-limited or unavailable, the system degrades gracefully:

```
deep_reasoning → standard_execution → STOP (planning can't degrade further)
standard_execution → free_tier → STOP
domain_specific → (already cheapest) → STOP
```

The loop **never pauses** for rate limits if a fallback exists. It continues at reduced capability.

---

## 6. Pattern 4 — Deterministic Guardrails

### Abstract Pattern

Guardrails are validation checks that run at specific lifecycle points. The key insight: **guardrails are layered by cost, from free to expensive.**

```
LAYER 0 — FILE-LEVEL (cost: 0)
  • Syntax check via CLI linter (by file extension)
  • Runs after EVERY file edit
  • Catches errors at the moment of introduction
  • Completely deterministic — no LLM involvement

LAYER 1 — COMMIT-LEVEL (cost: 0)
  • Pre-commit pipeline: lint all staged files
  • Branch protection: block commits to protected branches
  • Context freshness: verify state file was updated
  • Runs before EVERY commit

LAYER 2 — TASK-LEVEL (cost: LLM — standard tier)
  • Executor self-review (compliance check)
  • Skills-based verification
  • Runs after EVERY task completion

LAYER 3 — PHASE-LEVEL (cost: 0 + LLM — deep tier)
  • Script-based validation: plan coverage, execution fidelity, artifact integrity
  • Deep analytical review: logic gaps, boundary conditions, cross-file consistency
  • Runs ONLY at phase completion
  • Most expensive checks — justified because they run least frequently
```

### The Layering Principle

Checks are ordered by frequency × cost:

| Check | Frequency | Cost | Total cost over 50 tasks |
|-------|-----------|------|--------------------------|
| Lint (Layer 0) | Every file edit (~200) | 0 | **0** |
| Pre-commit (Layer 1) | Every commit (~50) | 0 | **0** |
| Self-review (Layer 2) | Every task (~50) | ~1 standard req | **~50 standard** |
| Phase gates (Layer 3) | Every phase (~5) | ~3 deep reqs | **~15 deep** |

This is dramatically cheaper than "run a deep review after every file edit" (200 × 3 deep requests = 600 deep requests).

### Kill Switch

A file on disk (`.tao-pause` in TAO) that the operator can create at any time. The loop checks for it on every iteration. If present, immediate stop.

This is the simplest possible mechanism — no API calls, no network, no permissions. `touch .tao-pause` from any terminal stops the system. `rm .tao-pause` resumes it.

### Anatomy of a Deterministic Gate Script

A gate script follows this contract:

```
INPUT:  path to phase directory
OUTPUT: human-readable findings to stdout
EXIT:   0 = PASS, 1 = BLOCK

INTERNALS:
  1. Read config file → extract project settings
  2. Locate relevant files (plan, status, tasks, source)
  3. Run checks (file exists? content matches? patterns found?)
  4. Accumulate findings
  5. Report
```

Gate scripts use **no LLM**. They parse files with `grep`, `wc`, `python3 -c`, and basic text processing. They are fast, free, and reliable.

---

## 7. Pattern 5 — Context Persistence

### Abstract Pattern

```
PERSISTENT STATE (always on disk):
  ├── Active Phase        → "which unit of work is current"
  ├── Task Queue/Status   → "what's done, what's pending, what's blocked"
  ├── Locked Decisions     → "what was already decided and must not be revisited"
  ├── Session Log          → "what happened in each session"
  ├── Codebase Patterns    → "conventions discovered while working"
  └── Change History       → "what changed, when, by which agent"

SESSION LIFECYCLE:
  START:
    1. Read ALL persistent state
    2. Inject state summary into agent context (automatically, not manually)
    3. Verify state consistency (no orphan tasks, no stale references)
  
  DURING:
    4. After every task: update task queue + session log
    5. After every file edit: update active phase state
    6. After every decision: record in locked decisions
  
  END:
    7. Write handoff summary for next session
    8. Commit all state changes
    9. Verify no uncommitted changes remain
```

### The Handoff Protocol

When a session ends (or when a different agent takes over), the current agent writes a handoff: what was accomplished, what's next, what's unresolved. The next session reads this handoff.

If a session ended without writing a handoff (crash, timeout, rate limit), the system detects this ("orphaned session") and warns the new session. This is the audit trail — if a handoff is missing, something went wrong.

### Why Files, Not Memory APIs

Many platforms offer "memory" features (Claude's projects, ChatGPT's memory, etc.). TAO uses plain files instead. Why:

1. **Portable.** Files work everywhere. Memory APIs are platform-locked.
2. **Inspectable.** The operator can read, edit, and version-control state files with regular tools.
3. **Debuggable.** When something goes wrong, `cat CONTEXT.md` is instant. Debugging a memory API requires platform-specific tools.
4. **Versioned.** State files are in the git repo. You can `git log CONTEXT.md` to see how state evolved.

---

## 8. Pattern 6 — Injectable Knowledge

### Abstract Pattern

```
KNOWLEDGE TYPES:
  ├── Always Active        → rules injected on every interaction
  ├── File-Scoped         → rules injected only when specific file types are edited
  ├── Context-Triggered   → deep knowledge loaded when task context matches
  └── Project-Specific    → operator's custom rules and conventions

LAYERING (from broadest to most specific):
  1. Global instructions    → universal rules (security, compliance, workflow)
  2. Project rules          → coding standards, architecture conventions
  3. File-type rules        → "when editing tests, follow test pyramid"
  4. Task-specific skills   → "this is a database migration, here's how to do it safely"

INJECTION MECHANISM:
  - Rules 1-3: injected AUTOMATICALLY by the IDE/platform
  - Rule 4: injected AUTOMATICALLY when context matches (no user action)
  - Total user action required: ZERO
```

### The No-Slash Principle

Knowledge that requires the user to invoke it (via `/commands`, manual prompts, or explicit references) will eventually be forgotten. The more skills you add, the more the user has to remember.

The correct approach: **the system discovers and loads knowledge automatically.** The user doesn't know skills exist — they just notice the agent writes better code.

Implementation strategies by platform:

| Platform | Auto-injection mechanism |
|----------|------------------------|
| VS Code Copilot | `.instructions.md` with `applyTo` glob patterns + `.github/skills/` auto-discovery |
| Cursor | `.cursorrules` file + `.cursor/rules/*.md` with glob patterns |
| Cline | `.clinerules` file + custom instructions in config |
| Claude Code | `CLAUDE.md` + project instructions |
| Windsurf | `.windsurfrules` + cascading rules |
| Custom system | Config-driven rule injection per file pattern |

### Skill Anatomy (Abstract)

A skill is a unit of expert knowledge with:

```
METADATA:
  - name          → unique identifier (prefixed to avoid conflicts)
  - description   → one-line summary (used for matching)
  - auto-invocable → false (never require user action)

CONTENT:
  - When to apply  → conditions/triggers
  - What to do     → step-by-step instructions
  - What NOT to do → anti-patterns
  - Checklist      → verification steps
```

The key constraint: **skills must be self-contained.** An agent that loads a skill should not need to load 3 other files to understand it. Everything needed is in the skill file.

---

## 9. Pattern 7 — Self-Healing Pipeline

### Abstract Pattern

When a validation gate fails, the system does **not stop and ask the operator**. It diagnoses the failure, routes the fix to the appropriate capability tier, applies the fix, and re-runs the gate.

```
GATE_PIPELINE {
  attempt = 0
  
  LOOP {
    attempt += 1
    
    // Phase 1: deterministic gates (free, fast)
    FOR each script_gate:
      result = run_gate(script)
      IF BLOCK:
        classify_issue(result)
        IF simple → fix directly (standard model)
        IF complex → delegate to deep reasoning model
        GOTO LOOP  (re-run all gates)
    
    // Phase 2: analytical review (expensive, deep)
    issues = deep_review(all_changed_files)
    IF issues found:
      FOR each issue:
        classify_and_fix(issue)
      GOTO LOOP  (re-run from Phase 1)
    
    // Phase 3: documentation check
    doc_result = validate_docs()
    IF BLOCK: fix directly → re-run Phase 3
    
    ALL PASSED → EXIT
    
    // Escalation after repeated failures
    IF attempt > 3 AND issues persist:
      escalate_to_deep_model(all_accumulated_failures)
      attempt = 0  (reset after deep intervention)
      GOTO LOOP
  }
}
```

### The False Positive Detection

The most dangerous failure mode in a self-healing pipeline is: **the model claims it fixed the issue, but it didn't.** The next gate run catches the same error, and the model "fixes" it again — infinite loop.

TAO solves this with **fix tracking:**

```
fix_history = {}

FOR each fix applied:
  signature = (file, error_pattern)
  IF signature IN fix_history:
    // Same error appeared before — previous fix was fake
    IMMEDIATELY escalate to deep reasoning model
    // The cheaper model can't fix this — it already failed
  ELSE:
    fix_history[signature] = (agent, attempt)
```

This pattern ensures the system never gets stuck in a "fix → re-fail → fix → re-fail" loop. After one false positive, the issue jumps to the most capable model.

### The Three-Mentality Audit

Beyond script-based gates, TAO runs a three-mentality audit at phase boundaries:

| Mentality | Persona | Checks for |
|-----------|---------|-----------|
| **Naive user** | "I've never seen this software" | Does it work on first attempt? Are instructions clear? Are errors helpful? |
| **Experienced developer** | "I know what good looks like" | Consistency, traceability, completeness, naming conventions |
| **Malicious attacker** | "I want to break this" | Injection, auth bypass, input manipulation, secret exposure |

Each mentality catches failures the others miss. A security expert might miss bad UX. A UX expert might miss SQL injection. The overlap is minimal, making the cost justified.

---

## 10. Pattern 8 — Structured Deliberation

### Abstract Pattern

Brainstorming is not "let the AI ramble." It follows a formal protocol based on IBIS (Issue-Based Information System, Kunz & Rittel, 1970):

```
BRAINSTORM LIFECYCLE:

  DIVERGE → Generate alternatives, question assumptions
    │       Minimum: 2 meaningfully different approaches
    │       Record dead ends (they prevent future rework)
    │
  CONVERGE → Evaluate trade-offs via structured argumentation
    │        Each decision follows IBIS format:
    │          Issue (question to resolve)
    │          └── Position 1 (option A)
    │              ├── Argument FOR
    │              └── Argument AGAINST
    │          └── Position 2 (option B)
    │              ├── Argument FOR
    │              └── Argument AGAINST
    │          └── Decision: P[N]
    │          └── Invalidation condition
    │
  SYNTHESIZE → Compress into actionable brief
    │          Only when maturity ≥ 5/7
    │
  PLAN → Decompose brief into tasks
           Each task traces to a decision
```

### The Maturity Gate

A brief is not ready to become a plan until at least 5 of 7 conditions are met:

| # | Condition |
|---|-----------|
| 1 | Problem/objective is clearly stated |
| 2 | ≥2 alternatives were explored |
| 3 | Trade-offs were evaluated (≥1 IBIS issue with arguments) |
| 4 | Every decision has an invalidation condition |
| 5 | Relevant reference material was consulted |
| 6 | Scope is defined (in and out) |
| 7 | Existing codebase patterns were considered |

The maturity gate prevents premature planning. Without it, the system plans after the first idea — and reworks after discovering the better idea it didn't explore.

### Invalidation Conditions

Every decision in the brainstorm includes: **"This decision would become wrong if..."**

This is not a formality. Invalidation conditions serve as future triggers:

- If a condition is met later, the team knows which decisions to revisit
- If conditions are vague ("if requirements change"), the decision is effectively permanent — a design smell
- Good conditions are specific and testable: "if p95 latency exceeds 500ms under 100 concurrent users"

### Why Dead Ends Matter

The brainstorm explicitly records approaches that were considered and rejected, with reasons. This prevents:

1. **Re-exploration.** A future session won't waste time exploring an approach already proven unviable.
2. **Ungrounded disagreement.** "Why didn't you use X?" has a documented answer.
3. **Decision erosion.** Without recorded rationale, decisions erode over time as people forget why they were made.

---

## 11. Anti-Patterns

Patterns that look reasonable but produce consistently bad outcomes:

### Anti-Pattern 1: "One Model for Everything"

**Symptom:** Using the most capable model for all tasks.
**Why it fails:** 60% cost waste on routine work. Rate limits hit faster. Operator runs out of budget mid-project.
**Fix:** Route by capability tier. Cheap model for routine, expensive for complex, free for mechanical.

### Anti-Pattern 2: "The Agent Decides What to Do"

**Symptom:** Giving the agent a vague goal ("build the authentication system") instead of a structured plan.
**Why it fails:** The agent improvises. Without a plan, it makes architectural decisions on the fly using whatever model happens to be running. Sonnet designing auth is a security risk.
**Fix:** Deliberation → Plan → Execute. The plan is created by the deep reasoning model. The executor follows it.

### Anti-Pattern 3: "LLM Validates LLM"

**Symptom:** Using an LLM to check if code has syntax errors, if files exist, or if branches are correct.
**Why it fails:** LLMs hallucinate. A model might say "syntax is valid" when it isn't. A deterministic linter never lies.
**Fix:** Deterministic checks for deterministic questions. LLM only for judgment-based checks (logic, design, security reasoning).

### Anti-Pattern 4: "Trust the First Fix"

**Symptom:** A validation gate fails, the agent fixes it, and the system moves on without re-running the gate.
**Why it fails:** The "fix" might be cosmetic. The agent might have suppressed the error instead of resolving it. Without re-validation, the failure persists invisibly.
**Fix:** Always re-run the full gate pipeline after any fix. Track fix history to detect false positives.

### Anti-Pattern 5: "Chat as Memory"

**Symptom:** Relying on conversation history for project context. "We decided in the previous message to use PostgreSQL."
**Why it fails:** Context windows are finite. Sessions end. Agents get rate-limited and replaced. Conversations are not searchable.
**Fix:** Write every decision, every state change, every pattern to disk. The conversation is ephemeral. Disk is permanent.

### Anti-Pattern 6: "Skippable Quality Gates"

**Symptom:** A flag like `--no-verify` or a config to disable lint, disable pre-commit, or bypass validation.
**Why it fails:** If a gate can be skipped, it _will_ be skipped — by the agent optimizing for speed, by the operator in a hurry, by a future contributor who doesn't know the convention.
**Fix:** No bypass mechanism. Gates are architectural constraints, not suggestions. The only way past a gate is to satisfy it.

### Anti-Pattern 7: "Planning Without Deliberation"

**Symptom:** Going directly from "we need a feature" to a task list, without exploring alternatives or evaluating trade-offs.
**Why it fails:** The first plan is rarely the best plan. Without deliberation, the system commits to an approach without knowing what it's leaving on the table. Rework cost: 6-10x the cost of deliberating upfront.
**Fix:** Maturity gate. The plan cannot be created until the brainstorm meets 5/7 criteria.

---

## 12. Translation Map

How TAO's patterns translate to different platforms:

### Agent System

| TAO concept | VS Code Copilot | Cursor | Cline | Claude Code | Custom system |
|-------------|-----------------|--------|-------|-------------|---------------|
| Agent definition | `.agent.md` with YAML frontmatter | Agent modes in `.cursor/agents/` | Custom modes in config | Project instructions | JSON/YAML agent config |
| Model override per agent | `model:` in frontmatter | Model selection per mode | Model in config | Not natively supported; use separate projects | API `model` parameter |
| Subagent invocation | `runSubagent` tool | Not natively supported; simulate via prompts | Task delegation via modes | Tool use → different project | Internal function call |
| Tool restriction | `tools:` in frontmatter | Not natively supported | Tool allow/deny lists | Not natively supported | API tool filtering |

### Guardrails

| TAO concept | VS Code Copilot | Cursor | Cline | Claude Code | Custom system |
|-------------|-----------------|--------|-------|-------------|---------------|
| Post-edit lint | `PostToolUse` hook → shell script | `.cursorrules` instruction to lint | Auto-lint rules in config | `CLAUDE.md` instruction to lint | Webhook/callback after edit API call |
| Session context injection | `SessionStart` hook → shell script | `.cursorrules` auto-read instructions | Auto-start rules | `CLAUDE.md` with reading order | Pre-prompt injection in API calls |
| Pre-commit pipeline | Git `pre-commit` hook → shell script | Same (git hooks) | Same (git hooks) | Same (git hooks) | Same (git hooks) |
| Kill switch | `.tao-pause` file check | Same pattern (file check) | Same pattern | Same pattern | Database flag or file check |

### Knowledge Injection

| TAO concept | VS Code Copilot | Cursor | Cline | Claude Code | Custom system |
|-------------|-----------------|--------|-------|-------------|---------------|
| Global instructions | `.github/copilot-instructions.md` | `.cursorrules` | `.clinerules` | `CLAUDE.md` | System prompt |
| File-scoped rules | `.instructions.md` with `applyTo` | `.cursor/rules/*.md` with glob | Per-file rules in config | Not natively supported | Conditional system prompt per file type |
| Auto-discovered skills | `.github/skills/*/SKILL.md` | `.cursor/rules/` with descriptions | Custom instructions | Not natively supported | Skill database with context matching |
| Project conventions | `CLAUDE.md` (read by agents) | `.cursorrules` | `.clinerules` | `CLAUDE.md` | Config file or database |

### Persistence

| TAO concept | VS Code Copilot | Cursor | Cline | Claude Code | Custom system |
|-------------|-----------------|--------|-------|-------------|---------------|
| Active phase state | `CONTEXT.md` (markdown on disk) | Same pattern | Same pattern | Same pattern | Database or JSON state file |
| Task queue | `STATUS.md` (markdown with emoji status) | Same or JSON file | Same or JSON file | Same or Markdown | Database table or queue |
| Decision log | `DECISIONS.md` (IBIS format) | Same pattern | Same pattern | Same pattern | Structured database |
| Session handoff | Handoff file in `.tao-session/` | Same pattern | Same pattern | Same pattern | Session table with handoff field |

---

## 13. Design Principles

The meta-principles that guided every design decision in TAO. Use these to evaluate whether a new feature or modification is TAO-compatible.

### Principle 1: Zero Configuration for Default Behavior

The system must work out of the box. Configuration exists for customization, not for basic operation. If the operator has to configure something before the first run, the default is wrong.

### Principle 2: Cost of a Bad Plan > Cost of Planning

Always invest in the deep reasoning model for planning. A $0.30 brainstorm that prevents 6 hours of rework is not expensive — it's the cheapest investment in the system.

### Principle 3: Deterministic Over Probabilistic

If a check can be performed without an LLM, it must be. Deterministic checks are free, instant, and never hallucinate. Use LLMs only for judgment — never for fact-checking.

### Principle 4: Loud Failures Over Silent Ones

Every gate blocks on failure. No warning-only modes. No "continue anyway" options. The cost of detecting a failure grows exponentially with time-to-detection.

### Principle 5: Files Over APIs

State goes to disk as human-readable files, not to platform-specific memory APIs. Files are portable, inspectable, debuggable, and version-controllable.

### Principle 6: Prefix Everything

All framework-provided files use a consistent prefix (`tao-` in TAO). This prevents namespace collisions with user-defined files and makes framework artifacts instantly recognizable.

### Principle 7: The Loop is Sacred

The autonomous loop is the core innovation. Every design decision must preserve loop continuity. A component that pauses the loop for human input is not compatible unless it's the kill switch.

### Principle 8: Trace Everything

Every commit traces to a task. Every task traces to a plan. Every plan traces to a brief. Every brief traces to decisions. This chain is how you answer "why was this built this way?" six months later.

### Principle 9: The Cheapest Correct Model

For any given task, use the cheapest model that produces correct results. "Correct" means: passes all gates, meets acceptance criteria, follows conventions. If a cheaper model satisfies all three, the more expensive model is waste.

### Principle 10: Self-Healing Over Self-Reporting

When a gate fails, the system should fix the issue — not just report it. A system that reports failures to a human is a linter. A system that fixes them is an agent.

---

> _"The Tao that can be told is not the eternal Tao."_ — Lao Tzu
>
> But the Tao that can be _patterned_ can be rebuilt anywhere.
