# Task T12 — GETTING-STARTED.md: Add Quick Path

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P3

---

## Objective

Add a 5-step "Quick Path" section at the top of GETTING-STARTED.md that gives vibe coders the minimum viable instructions to start using TAO.

## Context

GETTING-STARTED.md currently has detailed explanations that are useful but overwhelming for a first-time user. A Quick Path at the top gives the "just tell me what to click" experience, with the detailed sections below for those who want to understand more.

## Files to Read (BEFORE editing)

- `docs/GETTING-STARTED.md` — full file

## Files to Create/Edit

- `docs/GETTING-STARTED.md` — add Quick Path section at top

## Implementation Steps

1. Read GETTING-STARTED.md completely
2. Add after the title but before existing content:
   ```markdown
   ## ⚡ Quick Path (5 steps)
   
   1. **Install TAO** in your project folder:
      ```bash
      bash /path/to/TAO/install.sh /path/to/your/project
      ```
   2. **Open the project** in VS Code
   3. **Open Copilot Chat** (Ctrl+Shift+I or Cmd+Shift+I)
   4. **Type:** `@Execute-Tao` (or `@Executar-Tao` for Portuguese)
   5. **Describe your project idea** — TAO handles the rest
   
   > That's it. TAO will create your project structure, plan tasks, and start building.
   > Read on for detailed explanations of each component.
   
   ---
   ```
3. Verify the rest of the document flows naturally after the Quick Path

## Acceptance Criteria

- [ ] Quick Path appears as the first section after the title
- [ ] Exactly 5 steps, each one line
- [ ] Step 1 shows the install command
- [ ] Step 4 shows both EN and PT-BR agent names
- [ ] Step 5 sets the right expectation (describe → TAO handles rest)
- [ ] Separator between Quick Path and detailed content
- [ ] Existing content unchanged

## Notes / Gotchas

- The install path in step 1 should use a generic placeholder — the actual path depends on where the user cloned TAO
- Keep it SHORT — this is for people who don't read documentation
- The Quick Path should work even if the user skips everything else

---

**Expected commit:** `docs(phase-01): T12 — GETTING-STARTED.md adds Quick Path`
