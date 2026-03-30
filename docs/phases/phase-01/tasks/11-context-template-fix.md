# Task T11 — Fix CONTEXT.md Templates: Placeholders + Typos (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P2-TEXT (L2)
**Depends on:** None

---

## Objective

Fix CONTEXT.md templates: replace unparseable `[XX — Nome da Fase]` placeholder with `01 — Pending Definition`, fix "Open Pendencies" typo in EN version.

## Gaps Fixed

- G17: CONTEXT.md `[XX — Nome]` placeholder breaks context-hook phase parsing
- G18: "Open Pendencies" inconsistency in EN

## Files to Read

- `templates/en/CONTEXT.md` — full file
- `templates/pt-br/CONTEXT.md` — full file

## Files to Edit

- `templates/en/CONTEXT.md` — replace placeholder + fix typo
- `templates/pt-br/CONTEXT.md` — replace placeholder

## Changes

### EN template
1. Change `**Phase:** [XX — Phase Name]` → `**Phase:** 01 — Pending Definition`
2. Change `## Open Pendencies` → `## Open Issues`
3. Change `- [ ] [Pendency 1] — [context]` → `- [ ] [Issue 1] — [context]`

### PT-BR template
1. Change `**Fase:** [XX — Nome da Fase]` → `**Fase:** 01 — Definição Pendente`

## Acceptance Criteria

- [ ] EN CONTEXT.md has parseable phase number (01)
- [ ] PT-BR CONTEXT.md has parseable phase number (01)
- [ ] EN CONTEXT.md uses "Open Issues" not "Open Pendencies"
- [ ] context-hook.sh can extract phase "01" from both templates
