# Task T05 — RULES.md: Fix auto_push Contradiction

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P1

---

## Objective

Fix the contradiction where RULES.md says "must always push after commit" but tao.config.json has `auto_push: false`. Make RULES.md reference the config as source of truth.

## Context

RULES.md template (both EN and PT-BR) currently states agents must always push after commit. But tao.config.json has `git.auto_push` which defaults to `false`. When auto_push is false and the agent pushes anyway (following RULES.md), it violates the user's configuration. Config must be the single source of truth.

## Files to Read (BEFORE editing)

- `templates/en/RULES.md` — find the push-related rule
- `templates/pt-br/RULES.md` — same rule in Portuguese

## Files to Create/Edit

- `templates/en/RULES.md` — change "always push" to "push according to config"
- `templates/pt-br/RULES.md` — same change in Portuguese

## Implementation Steps

1. Read both RULES.md templates
2. Find the rule about pushing after commit
3. Replace with config-aware language:
   - EN: "Push behavior follows `tao.config.json → git.auto_push`. If `true`, push after each commit. If `false`, batch commits locally — push only when explicitly requested."
   - PT-BR: "Comportamento de push segue `tao.config.json → git.auto_push`. Se `true`, push após cada commit. Se `false`, commits locais em lote — push apenas quando explicitamente solicitado."
4. Verify no other references to "always push" exist in templates

## Acceptance Criteria

- [ ] EN RULES.md references tao.config.json → git.auto_push
- [ ] PT-BR RULES.md references tao.config.json → git.auto_push
- [ ] No hardcoded "always push" language remains
- [ ] Both files are syntactically valid Markdown

## Notes / Gotchas

- This is a TEMPLATE file, not an installed file. Changes affect new installations only.
- Existing installations need manual update or re-install.
- The rule may be in LOCK 6 (commit rules section) — find exact location.

---

**Expected commit:** `fix(phase-01): T05 — RULES.md references config for auto_push`
