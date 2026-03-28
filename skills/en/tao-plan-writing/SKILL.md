---
name: tao-plan-writing
description: "Expert task decomposition for creating TAO PLAN.md files. Breaks features into phases and tasks with acceptance criteria, effort estimates, and dependencies. Use when planning work, creating phases, or decomposing features."
user-invocable: false
---
# TAO Plan Writing

## When to use
Auto-loaded when creating or updating PLAN.md, decomposing features into tasks, or planning phases.

## Task Decomposition Principles
1. **One task = one commit** — if it needs multiple commits, split it
2. **Acceptance criteria are testable** — no vague "works correctly"
3. **Tasks are ordered by dependency** — blocked tasks come after their blockers
4. **Each task has estimated effort** — S (< 30 min), M (30-90 min), L (90+ min)

## PLAN.md Structure
```markdown
# Phase XX — [Phase Title]

**Goal:** One sentence describing what this phase achieves
**Prerequisite:** Phase XX-1 completed (or "none")

## Tasks

### T01 — [Task Name]
- **Scope:** What files/modules this touches
- **Acceptance criteria:**
  - [ ] Criterion 1 (testable)
  - [ ] Criterion 2 (testable)
- **Effort:** S | M | L
- **Model:** Sonnet | Opus | GPT-4.1
- **Dependencies:** none | T0X

### T02 — [Task Name]
...
```

## Model Routing Rules
| Task Type | Model | Cost |
|-----------|-------|------|
| Simple CRUD, config, boilerplate | GPT-4.1 | Free |
| Standard logic, tests, integration | Sonnet | Low |
| Complex architecture, security, debugging | Opus | High |

## Decomposition Heuristics
- **Database first** — schema before code that reads it
- **Interface first** — API contract before implementation
- **Tests alongside** — test task follows immediately after implementation task
- **Config last** — environment/deployment config after all code

## Red Flags (split the task if...)
- Task touches more than 3 files
- Task description uses "and" more than once
- Task scope crosses module boundaries
- Estimated effort is L — usually splittable

## Quality Gate
Before marking PLAN.md complete, verify:
- [ ] All tasks have acceptance criteria
- [ ] All tasks have effort estimates
- [ ] All tasks have model assignment
- [ ] Dependencies form a DAG (no circular)
- [ ] Task count is between 3-10 per phase
