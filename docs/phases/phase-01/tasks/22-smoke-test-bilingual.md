# Task T22 — Bilingual Smoke Test

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P5-VERIFY
**Depends on:** T01-T21 (all implementation tasks)

---

## Objective

Verify that ALL changes made in T01-T21 are consistent between EN and PT-BR versions. Every bilingual file must have identical structure and equivalent content.

## Gaps Fixed

- Verification task — ensures no bilingual drift

## Files to Read

All bilingual file pairs:
- `agents/en/*.agent.md` vs `agents/pt-br/*.agent.md` (6 pairs)
- `templates/en/INDEX.md` vs `templates/pt-br/INDEX.md`
- `templates/en/RULES.md` vs `templates/pt-br/RULES.md`
- `templates/en/CONTEXT.md` vs `templates/pt-br/CONTEXT.md`
- `phases/en/*.template` vs `phases/pt-br/*.template`
- `README.md` vs `README.pt-br.md`

## Verification Steps

### 1. Structure parity check

For each bilingual pair:
- Count sections (## headings) — must match
- Count tables — must match
- Count code blocks — must match
- Count list items — must match ±1

### 2. Content equivalence check

For each bilingual pair:
- Key terms must have correct translations
- Rule numbers (R0-R7) must match
- Config keys must be identical (not translated)
- File paths must be identical (not translated)

### 3. New content check

Specifically verify that changes from T10, T12, T13, T17, T18, T21 (which modify bilingual files) are present in BOTH languages.

## Acceptance Criteria

- [ ] All 6 agent pairs have same structure
- [ ] INDEX.md EN and PT-BR have same skills listed
- [ ] RULES.md EN and PT-BR have same rule set
- [ ] README and README.pt-br have same sections
- [ ] No EN-only or PT-BR-only content found
- [ ] Run `bash scripts/i18n-diff.sh` if available, report results
