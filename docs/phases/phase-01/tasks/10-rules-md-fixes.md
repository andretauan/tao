# Task T10 — Fix RULES.md: auto_push + novo_projeto + ABEX (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P2-TEXT (L2)
**Depends on:** T09 (canonical compliance already rewritten)

---

## Objective

Fix 3 issues in RULES.md templates (both EN and PT-BR): "always push" contradiction, missing novo_projeto exception, and ambiguous ABEX definition.

## Gaps Fixed

- G16: "always push" contradicts auto_push: false
- G19: novo_projeto contradicts "NUNCA pergunte"
- G25: ABEX 3 different definitions

## Files to Read

- `templates/en/RULES.md` — full file
- `templates/pt-br/RULES.md` — full file

## Files to Edit

- `templates/en/RULES.md` — 3 changes
- `templates/pt-br/RULES.md` — 3 changes

## Changes

### 1. Fix "always push" (2 locations per file)

In COMMIT CONVENTIONS section, change:
```
- Always `git push origin dev` after every commit
```
To:
```
- Push according to `git.auto_push` in `.github/tao/tao.config.json`. If `auto_push: true`, push after every commit. If `false`, commit only — push when ready.
```

In SESSION CHECKLIST section, change:
```
- [ ] `git push origin dev` after every commit
```
To:
```
- [ ] Push to dev if `git.auto_push: true` (check .github/tao/tao.config.json)
```

### 2. Add novo_projeto exception to AUTONOMY RULES

After "NUNCA pergunte" / "NEVER ask", add:
```
**Exception:** When CONTEXT.md status is `novo_projeto` / `new_project`, the @Execute-Tao agent
MAY ask ONE question to identify the project scope (see onboarding flow). This is the ONLY
exception and fires ONCE per project lifetime.
```

### 3. Unify ABEX definition

In ABEX PROTOCOL section, add at the end:
```
**Automation:** `abex-gate.sh` performs automated pattern detection for Pass 1 (Security).
Runs automatically via pre-commit hook and PostToolUse hook. Agents perform the 3 manual
passes for thorough review. The automated scan catches obvious patterns; the manual review
catches subtle issues.
```

## Acceptance Criteria

- [ ] EN RULES.md: "always push" replaced with config reference (2 locations)
- [ ] PT-BR RULES.md: "sempre push" replaced with config reference (2 locations)
- [ ] EN RULES.md: novo_projeto exception added to autonomy rules
- [ ] PT-BR RULES.md: novo_projeto exception added
- [ ] EN RULES.md: ABEX section mentions abex-gate.sh automation
- [ ] PT-BR RULES.md: ABEX section mentions abex-gate.sh automation
