# Task T06 — CONTEXT.md Templates: Fix Placeholders

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P1

---

## Objective

Replace the unhelpful `[XX — Phase Name]` placeholder in CONTEXT.md templates with a useful default that reflects reality after install.

## Context

After install, CONTEXT.md shows `[XX — Phase Name]` as the active phase. This is meaningless — the user doesn't know what XX is or what to put there. Since install.sh now creates phase 01 (Task T03), the template should reflect this. The phase name stays as "Awaiting Definition" / "Aguardando Definição" since the user hasn't described their project yet.

## Files to Read (BEFORE editing)

- `templates/en/CONTEXT.md` — find the active phase section
- `templates/pt-br/CONTEXT.md` — same in Portuguese

## Files to Create/Edit

- `templates/en/CONTEXT.md` — replace `[XX — Phase Name]` with `01 — Awaiting Definition`
- `templates/pt-br/CONTEXT.md` — replace `[XX — Nome da Fase]` with `01 — Aguardando Definição`

## Implementation Steps

1. Read both CONTEXT.md templates
2. Find all instances of the placeholder pattern `[XX — ...]`
3. Replace with:
   - EN: `01 — Awaiting Definition`
   - PT-BR: `01 — Aguardando Definição`
4. Verify the rest of the template still makes sense with this default

## Acceptance Criteria

- [ ] EN CONTEXT.md shows `01 — Awaiting Definition` as active phase
- [ ] PT-BR CONTEXT.md shows `01 — Aguardando Definição` as active phase
- [ ] No `[XX` placeholders remain in phase-related fields
- [ ] Both files are valid Markdown

## Notes / Gotchas

- The placeholder may appear in multiple places (active phase header, phase list, etc.)
- Keep `[brackets]` only for fields the user truly needs to fill (e.g., project description)
- This depends on T03 (install creates phase 01) for logical consistency

---

**Expected commit:** `fix(phase-01): T06 — CONTEXT.md templates show phase 01 default`
