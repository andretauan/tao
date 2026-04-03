---
name: tao-brainstorm
description: "IBIS-based brainstorming methodology with structured issue-position-argument analysis and maturity scoring. Use when brainstorming, evaluating ideas, or writing BRIEF.md."
user-invocable: false
---
# TAO Brainstorm (IBIS Method)

## When to use
Auto-loaded during brainstorm sessions, BRIEF.md creation, and idea evaluation.

## IBIS Framework
Issue-Based Information System (IBIS) structures discussion into:
- **Issues** — Questions or problems to address
- **Positions** — Possible answers or approaches
- **Arguments** — Pros and cons for each position

## BRIEF.md Structure
```markdown
# BRIEF — [Topic]

## Issue
[Clear statement of the problem or decision]

## Positions

### Position A — [Name]
**Arguments for:**
- Pro 1
- Pro 2

**Arguments against:**
- Con 1

### Position B — [Name]
**Arguments for:**
- Pro 1

**Arguments against:**
- Con 1
- Con 2

## Decision
[Selected position with rationale]

## Maturity Score
[X/7] — see scoring criteria below
```

## Maturity Gate (7 criteria)
Score 1 point for each:
1. ✅ Problem/objective is clear (DISCOVERY has a "Core Problem" section defined)
2. ✅ Alternatives were explored (≥ 2 meaningfully different approaches registered)
3. ✅ Trade-offs were evaluated (≥ 1 IBIS issue in DECISIONS with positions + arguments)
4. ✅ Decisions have invalidation conditions (every decision has "Would invalidate if")
5. ✅ Relevant reference docs consulted (registered in DISCOVERY §References)
6. ✅ Scope is defined (what's IN and what's OUT explicitly stated)
7. ✅ Existing codebase patterns considered (patterns from previous phase progress.txt integrated)

**Minimum to proceed: 5/7**

## Brainstorm Anti-Patterns
- ❌ Single-position brainstorm (already decided before thinking)
- ❌ All pros, no cons (confirmation bias)
- ❌ Technical-only evaluation (ignoring maintenance, cost, team skills)
- ❌ Analysis paralysis (too many positions, no convergence)

## Convergence Signals
Move from brainstorm to plan when:
- One position clearly dominates on weighted criteria
- Team/stakeholder alignment exists
- Risks are understood and mitigatable
- Technical feasibility is confirmed
