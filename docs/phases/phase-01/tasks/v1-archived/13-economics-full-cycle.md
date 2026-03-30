# Task T13 — ECONOMICS.md: Document Full-Cycle Costs

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P3

---

## Objective

Add brainstorming (Wu/Opus) and planning costs to ECONOMICS.md so the savings model reflects the full development cycle, not just execution.

## Context

ECONOMICS.md currently models only the execution phase (Sonnet vs Opus for task execution). But TAO also uses Opus for brainstorming (Wu) and planning, which can be significant costs. The document should show the complete picture so users can make informed decisions about their budget.

## Files to Read (BEFORE editing)

- `docs/ECONOMICS.md` — full file

## Files to Create/Edit

- `docs/ECONOMICS.md` — add full-cycle cost model

## Implementation Steps

1. Read ECONOMICS.md completely
2. Add a "Full Development Cycle" section that includes:
   ```markdown
   ## Full Development Cycle Costs
   
   TAO's development cycle has three cost phases:
   
   | Phase | Model Used | Typical Usage | Cost Profile |
   |-------|-----------|---------------|-------------|
   | **Brainstorm** (Wu) | Opus (required) | 2-5 sessions × ~100K tokens | High per-session |
   | **Planning** (Wu→Plan) | Opus (required) | 1-2 sessions × ~50K tokens | Medium per-session |
   | **Execution** (Tao) | Sonnet (60%) + Opus (40%) | 10-30 tasks × ~20K tokens each | Optimized routing |
   
   ### Where the "60% savings" applies
   
   The 60% savings estimate applies to the **execution phase only**, where TAO routes 
   simple tasks to Sonnet ($3/MTok) instead of Opus ($15/MTok). 
   
   Brainstorming and planning phases ALWAYS use Opus — this is by design, 
   as these phases require deep reasoning that Sonnet cannot provide reliably.
   
   ### Realistic total cost example
   
   For a medium project (15 tasks):
   
   | Phase | Without TAO (all Opus) | With TAO |
   |-------|----------------------|----------|
   | Brainstorm | $X (Opus) | $X (Opus — same) |
   | Planning | $X (Opus) | $X (Opus — same) |
   | Execution | $X (all Opus) | $X (60% Sonnet + 40% Opus) |
   | **Total** | **$X** | **$X (Y% savings overall)** |
   
   > Note: Actual costs depend on conversation length, project complexity, and 
   > how many brainstorm iterations are needed. The execution phase is where 
   > TAO's routing provides the most value.
   ```
3. Add a note about context window costs (long conversations = more tokens)
4. Keep existing content, just extend it

## Acceptance Criteria

- [ ] Full development cycle table shows all three phases
- [ ] Clear statement that brainstorm/planning = Opus only
- [ ] "60% savings" is explicitly scoped to execution phase
- [ ] Realistic cost example with all phases
- [ ] Context window cost note included
- [ ] Existing execution-phase analysis preserved
- [ ] Tone is honest but not discouraging

## Notes / Gotchas

- Don't invent exact dollar amounts — use relative costs or token estimates
- The actual savings percentage will be lower than 60% when including all phases
- This is a documentation task — no code changes
- Be honest about costs without making TAO seem expensive

---

**Expected commit:** `docs(phase-01): T13 — ECONOMICS.md documents full-cycle costs`
