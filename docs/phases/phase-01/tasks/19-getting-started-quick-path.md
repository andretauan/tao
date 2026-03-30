# Task T19 — GETTING-STARTED.md Quick Path

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P4-DOCS
**Depends on:** T15

---

## Objective

Add a "Quick Start" section to GETTING-STARTED.md that gets a user from zero to first task execution in under 5 minutes.

## Gaps Fixed

- G39: GETTING-STARTED.md lacks a quick path — too much detail before actionable steps

## Files to Read

- `docs/GETTING-STARTED.md` — current content

## Files to Edit

- `docs/GETTING-STARTED.md` — add Quick Start section at top

## Changes

### 1. Add Quick Start at the very top

```markdown
## Quick Start (5 minutes)

### Prerequisites
- VS Code with GitHub Copilot (Agent Mode)
- Git repository initialized

### Steps

1. **Install TAO:**
   ```bash
   bash /path/to/TAO/install.sh
   ```

2. **Open VS Code Agent Mode:** `Ctrl+Shift+I` (or `Cmd+Shift+I` on Mac)

3. **Start your first task:**
   ```
   @Executar-Tao executar
   ```

4. **The agent will:**
   - Read your project's STATUS.md
   - Pick the next task
   - Execute it with full compliance

That's it. For detailed configuration and customization, read on.

---
```

### 2. Ensure existing content flows after Quick Start

The detailed sections should come AFTER the quick path, not replace them.

## Acceptance Criteria

- [ ] Quick Start section at top of GETTING-STARTED.md
- [ ] 3-step path: install → open VS Code → say "executar"
- [ ] Existing detailed content preserved below quick start
- [ ] Tested: a new user can follow the 3 steps without prior TAO knowledge
