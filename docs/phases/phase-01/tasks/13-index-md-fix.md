# Task T13 — Fix INDEX.md Descriptions + R3 Matching Algorithm (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P2-TEXT (L2)
**Depends on:** None

---

## Objective

Complete all 14 skill descriptions in INDEX.md (currently truncated) and document the R3 skill matching algorithm.

## Gaps Fixed

- G24: INDEX.md truncated descriptions
- G26: R3 skill check impossible (no matching algorithm)

## Files to Read

- `templates/en/INDEX.md` — current descriptions
- `templates/pt-br/INDEX.md` — current descriptions
- `templates/shared/tao.instructions.md` — skill routing table (reference)
- All 14 SKILL.md files for accurate descriptions

## Files to Edit

- `templates/en/INDEX.md` — complete descriptions + add R3 section
- `templates/pt-br/INDEX.md` — complete descriptions + add R3 section

## Changes

### 1. Complete all skill descriptions
Each skill must have a 1-2 sentence description that tells the agent WHEN to use it.

### 2. Add R3 matching algorithm section

Add at top of INDEX.md:
```markdown
## How to Match Skills (R3 Algorithm)

When editing a file, check which skills apply:

1. **Always active** (every code task): tao-clean-code, tao-security-audit, tao-code-review, tao-git-workflow
2. **By file extension**: match the file you're editing against the instruction applyTo patterns:
   - `.test.{js,ts,py}` or `/tests/` → tao-test-strategy
   - Routes/controllers/handlers → tao-api-design
   - `.sql` / migrations / models → tao-database-design
3. **By task type**: match the task description:
   - Refactoring mentioned → tao-refactoring
   - Bug investigation → tao-debug-investigation
   - Performance work → tao-performance-audit
   - Architecture decision → tao-architecture-decision
   - Planning → tao-plan-writing
   - Brainstorming → tao-brainstorm

List all matching skills in the compliance check.
```

## Acceptance Criteria

- [ ] All 14 skill descriptions complete (not truncated) in EN
- [ ] All 14 skill descriptions complete in PT-BR
- [ ] R3 matching algorithm documented in both INDEX.md files
- [ ] Algorithm is concrete (file extension → skill, not vague)
