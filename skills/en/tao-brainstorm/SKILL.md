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
1. ✅ Issue is clearly defined (not vague)
2. ✅ At least 2 positions explored
3. ✅ Each position has both pros and cons
4. ✅ Trade-offs are explicit (not hidden)
5. ✅ Decision is justified with rationale
6. ✅ Risks of chosen approach are acknowledged
7. ✅ Actionable next steps are listed

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
