---
name: tao-architecture-decision
description: "Architecture Decision Record (ADR) writing with trade-off analysis matrix and decision evaluation framework. Use when making architectural decisions, choosing technologies, or documenting design decisions."
user-invocable: false
---
# TAO Architecture Decision Records

## When to use
Use when making technology choices, designing system architecture, or evaluating design alternatives.

## ADR Template
```markdown
# ADR-NNN — [Decision Title]

**Date:** YYYY-MM-DD
**Status:** PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED by ADR-XXX
**Deciders:** [who was involved]

## Context
[What is the issue? What forces are at play?]

## Options Considered

### Option A — [Name]
- **Pros:** ...
- **Cons:** ...
- **Cost:** ...

### Option B — [Name]
- **Pros:** ...
- **Cons:** ...
- **Cost:** ...

## Decision
[Which option was chosen and WHY]

## Consequences
### Positive
- ...
### Negative
- ...
### Risks
- ...
```

## Trade-Off Analysis Matrix
Score each option 1-5 on weighted criteria:

| Criteria | Weight | Option A | Option B | Option C |
|----------|--------|----------|----------|----------|
| Performance | 3 | 4 (12) | 3 (9) | 5 (15) |
| Maintainability | 4 | 5 (20) | 3 (12) | 2 (8) |
| Team expertise | 2 | 3 (6) | 5 (10) | 1 (2) |
| Cost | 3 | 4 (12) | 3 (9) | 2 (6) |
| **Total** | | **50** | **40** | **31** |

## Decision Evaluation Criteria
Before accepting a decision, verify:
- [ ] At least 2 alternatives were evaluated
- [ ] Trade-offs are explicit and quantified
- [ ] Reversibility is assessed (one-way door vs two-way door)
- [ ] Team capability is considered
- [ ] Migration/adoption cost is estimated
- [ ] Decision is documented in a searchable format

## Architecture Review Questions
1. Does this scale to 10x current load?
2. What happens when this component fails?
3. Can we replace this component without rewriting?
4. How do we monitor and debug this in production?
5. What's the cost at scale? (compute, storage, licenses)
