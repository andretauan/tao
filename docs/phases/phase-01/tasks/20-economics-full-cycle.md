# Task T20 — ECONOMICS.md Full-Cycle Costs

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P4-DOCS
**Depends on:** None

---

## Objective

Add real full-cycle cost data to ECONOMICS.md: what a complete phase costs across agent types, including the brainstorm→plan→execute→verify cycle.

## Gaps Fixed

- G40: ECONOMICS.md only shows per-query costs, not full-cycle costs

## Files to Read

- `docs/ECONOMICS.md` — current content

## Files to Edit

- `docs/ECONOMICS.md` — add full-cycle cost section

## Changes

### 1. Add Full-Cycle Cost Estimates

```markdown
## Full-Cycle Cost Estimates

### Typical Phase Cost (16-task phase)

| Stage | Agent | Model | Queries | Est. Cost |
|-------|-------|-------|---------|-----------|
| Brainstorm | Wu | Opus | 3-5 | $1.50-2.50 |
| Planning | Wu | Opus | 2-3 | $1.00-1.50 |
| Execution | Tao | Sonnet | 16-32 | $0.80-1.60 |
| Verification | Tao | Sonnet | 3-5 | $0.15-0.25 |
| **Total** | | | **24-45** | **$3.45-5.85** |

### Cost Optimization Tips

1. **Wu (Opus) is expensive but prevents rewrite cycles.** A $2 brainstorm saves $10+ in rework.
2. **Sonnet handles execution efficiently.** Don't use Opus for task execution.
3. **Batch small tasks.** Grouping related changes in one session reduces context-loading overhead.
4. **Rate limits matter.** Opus has lower rate limits — plan brainstorm sessions to avoid hitting them.

### When NOT to Use TAO

- Single-file bug fixes (overhead > value)
- Prototyping / throwaway code
- Projects with < 3 files
```

## Acceptance Criteria

- [ ] Full-cycle cost table added with realistic estimates
- [ ] Cost optimization tips included
- [ ] "When NOT to use" section added (honesty about overhead)
- [ ] Estimates match actual model pricing (Opus ~$0.50/query, Sonnet ~$0.05/query)
