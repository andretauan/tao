# Guardrails — TAO Quality Enforcement System

> TAO's guardrails operate across all three layers (Think, Plan, Execute) to prevent errors, enforce quality, and maintain context persistence. This document describes every gate in the system.

---

## Overview

Guardrails are not a separate layer — they're **transversal**, running throughout the entire workflow. They exist to ensure that AI agents:

1. Don't lose context between sessions
2. Don't skip planning
3. Don't commit broken code
4. Don't ignore security concerns
5. Don't make decisions above their reasoning tier

---

## The 7 Guardrail Categories

### 1. Compliance Check (R0)

**When:** Every response that modifies code
**Enforced by:** CLAUDE.md template, agent instructions

Every code-modifying response must begin with:

```
📋 COMPLIANCE CHECK
├─ Skills consulted: [list]
├─ Files read before editing: [list]
├─ CONTEXT.md read: YES
├─ CHANGELOG.md consulted: YES
├─ Doc sync: [checked / N/A]
└─ Date/time: YYYY-MM-DD HH:MM
```

If the block is missing, the response is invalid. The agent must stop and restart with the block.

---

### 2. Skill Check (R3)

**When:** Before ANY code-modifying task
**Enforced by:** Instruction files with `applyTo` patterns + agent instructions in CLAUDE.md

TAO uses a **two-layer auto-enforcement** system — no user action required:

**Layer 1 — Instruction files** (`.github/instructions/tao-*.instructions.md`):
VS Code injects these rules automatically based on the file being edited:

| File | Activates on | What it enforces |
|------|-------------|------------------|
| `tao-code` | All code files (`.py`, `.ts`, `.go`, etc.) | Clean code + OWASP security + 6-axis self-review |
| `tao-test` | Test files (`*.test.*`, `*.spec.*`, `test_*`) | Test pyramid + edge cases + AAA pattern |
| `tao-api` | Route/controller files (`routes/`, `api/`, etc.) | REST conventions + status codes + error format |
| `tao-db` | SQL/model/migration files | Schema rules + index strategy + migration safety |

**Layer 2 — Skills** (`.github/skills/tao-*/SKILL.md`):
All 14 TAO skills are `user-invocable: false` (auto-only). VS Code auto-discovers them and loads full instructions when context matches. No `/slash` commands exist.

**Gate:** The compliance check block includes `Skills consulted: [list]`. If empty when skills apply, the response is invalid.

---

### 3. ABEX 3× Audit (R1, R7)

**When:** After completing a code task
**Enforced by:** Agent instructions, compliance check

Three mandatory review passes after each implementation:

| Pass | Mindset | What to Check |
|---|---|---|
| **1 — Security** | "I'm an attacker" | SQL injection, XSS, CSRF, auth bypass, empty catches, input validation |
| **2 — User** | "I'm a real visitor" | UX flow, copy quality, accessibility, mobile responsiveness |
| **3 — Performance** | "I'm a Core Web Vitals auditor" | N+1 queries, DOM size, CLS, LCP, unnecessary re-renders |

ABEX is judgment-based (not a script) — it's a protocol in the agent's instructions, not an automated tool. The agent performs the three passes mentally and reports findings.

---

### 4. Pre-Commit Hooks

**When:** Every `git commit`
**Enforced by:** `hooks/pre-commit.sh` + `hooks/install-hooks.sh`

The pre-commit hook is a modular pipeline:

```
git commit triggered
  → pre-commit.sh reads tao.config.json → lint_commands
  → for each staged file:
      → extract file extension
      → look up lint command for that extension
      → replace {file} placeholder
      → run lint command
      → if FAIL → block commit, show error
  → all pass → commit proceeds
```

**Language-agnostic:** Works with any language that has a CLI linter. Configure in `tao.config.json`:

```json
"lint_commands": {
  ".php": "php -l {file}",
  ".py": "python3 -m py_compile {file}",
  ".ts": "npx tsc --noEmit",
  ".js": "node --check {file}",
  ".rb": "ruby -c {file}",
  ".go": "go vet {file}",
  ".rs": "cargo check"
}
```

---

### 5. VS Code Hooks (PostToolUse + SessionStart)

**Enforced by:** `.github/hooks/hooks.json` + hook scripts
**Cost:** 0 premium requests (deterministic, no LLM)

#### PostToolUse — Auto Lint

Runs after every file edit tool call (editFiles, create_file, replace_string_in_file, etc.):

1. Reads `tao.config.json` → `lint_commands`
2. Matches file extension to lint command
3. Runs lint
4. If error → injects error message into agent conversation
5. Agent sees the error and fixes it immediately

**Effect:** Catches syntax errors the moment they're introduced, before the agent moves on.

#### SessionStart — Context Injection

Runs at the start of every new chat session:

1. Reads `tao.config.json` → paths, phase prefix
2. Reads CONTEXT.md → active phase
3. Reads STATUS.md → task counts (done/pending)
4. Checks git branch
5. Checks `.tao-pause` → kill switch state
6. Injects all of this as context into the conversation

**Effect:** Eliminates 2-3 roundtrips of "read CONTEXT.md, read STATUS.md, check branch" that every session would otherwise start with.

---

### 6. Context Persistence

**When:** Every session
**Enforced by:** CLAUDE.md rules, agent instructions

| Document | Purpose | Updated When |
|---|---|---|
| `CONTEXT.md` | Active phase, last action, next action, touched files, open issues | End of every session |
| `CHANGELOG.md` | Structured change log with timestamps | Every commit |
| `progress.txt` | Per-phase session log, codebase patterns | After each task |
| `STATUS.md` | Task status table (⏳/✅/❌) | After each task |

**Rules:**
- CONTEXT.md must be read at session start (R0)
- CHANGELOG.md must be updated with every commit
- progress.txt must be appended after every completed task
- Session must not end with uncommitted changes

---

### 7. Planning Guards

**When:** During brainstorm and plan creation
**Enforced by:** Wu agent instructions, BRIEF maturity gate

#### "Sonnet Never Plans" Rule

Sonnet is **forbidden** from:
- Generating ideas or exploring approaches
- Deciding trade-offs between alternatives
- Evaluating plan completeness
- Synthesizing conversations into decision documents

Sonnet is **allowed** to:
- Transcribe decisions already made by Opus
- Load context (read files, present state)
- Execute a validated plan
- Commit, push, format, changelog

#### BRIEF Maturity Gate (7/7)

A BRIEF.md (plan input) is only valid when at least 5 of 7 criteria are met:

| # | Criterion |
|---|---|
| 1 | Problem/objective is clear |
| 2 | ≥2 alternatives explored |
| 3 | Trade-offs evaluated (≥1 IBIS issue with positions + arguments) |
| 4 | Decisions have invalidation conditions |
| 5 | Relevant docs consulted |
| 6 | Scope defined (what's in, what's out) |
| 7 | Codebase patterns from previous phases considered |

**Gate:** BRIEF with maturity < 5/7 → cannot generate PLAN.md. More brainstorming required.

#### Plan Provenance

Every PLAN.md must reference its source BRIEF.md. Plans without provenance are invalid — they indicate planning was done without proper deliberation.

---

## Kill Switch

Create a `.tao-pause` file in the workspace root to stop the execution loop:

```bash
touch .tao-pause    # Stop — @Execute-Tao checks this at every iteration
rm .tao-pause       # Resume
```

Or use the CLI:
```bash
./tao.sh pause      # Creates .tao-pause
./tao.sh unpause    # Removes .tao-pause
```

The kill switch is checked at the START of each loop iteration, before task selection.

---

## Security Locks

These are hard limits that agents cannot override:

| Lock | Rule |
|---|---|
| **Scope** | Agents only modify project source, CONTEXT.md, CHANGELOG.md, docs |
| **Branch** | Only dev branch. Never push to main, force push, or hard reset |
| **Destructive** | Never `rm -rf`, `DROP TABLE/DATABASE`, `TRUNCATE`, `DELETE` without WHERE |
| **Schema** | Any `CREATE/ALTER TABLE` → STOP → document SQL → checkpoint |
| **External** | Zero HTTP requests outside localhost. No package downloads without approval |

---

## Gate Summary

| # | Gate | Type | Cost | Blocks |
|---|---|---|---|---|
| 1 | Compliance Check | Prompt protocol | 0 | Responses without the block |
| 2 | Skill Check | Prompt protocol | 0 | Execution without reading skills |
| 3 | ABEX 3× Audit | Prompt protocol | 0 | Tasks without security/UX/perf review |
| 4 | Pre-Commit Hook | Git hook | 0 | Commits with lint errors |
| 5 | PostToolUse Lint | VS Code hook | 0 | File edits with syntax errors (auto-fix) |
| 6 | SessionStart Context | VS Code hook | 0 | Sessions without context |
| 7 | Maturity Gate | Prompt protocol | 0 | Plans from immature briefs |
| 8 | "Sonnet Never Plans" | Prompt protocol | 0 | Sonnet doing planning work |
| 9 | Context Persistence | Prompt protocol | 0 | Sessions ending without updates |
| 10 | Kill Switch | File-based | 0 | Runaway execution loops |
| 11 | Security Locks | Prompt protocol | 0 | Destructive/unsafe operations |

**Total overhead cost: 0 premium requests.** All guardrails are either prompt-based protocols or deterministic hooks.
