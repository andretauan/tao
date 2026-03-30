# Task T18 — README Qualify Claims + Troubleshooting (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P4-DOCS
**Depends on:** None

---

## Objective

Replace absolute claims in README with qualified statements (framework's actual enforcement level), and add a Troubleshooting section.

## Gaps Fixed

- G37: README overpromises ("100% compliance") without qualification
- G38: No troubleshooting section for common issues

## Files to Read

- `README.md` — current claims
- `README.pt-br.md` — current claims

## Files to Edit

- `README.md` — qualify claims + add troubleshooting
- `README.pt-br.md` — qualify claims + add troubleshooting

## Changes

### 1. Qualify absolute claims

Find phrases like "ensures compliance", "guarantees", "100%", "always" and replace with qualified versions:

| Before | After |
|--------|-------|
| "ensures all rules are followed" | "enforces rules through pre-commit hooks and agent hooks, with text-based guidelines for subjective criteria" |
| "100% compliance" | "~98% enforcement coverage through layered defense (L0 deterministic + L1 hooks + L2 guidelines)" |
| "never allows" | "blocks at commit time via pre-commit hooks" |

### 2. Add Troubleshooting section

```markdown
## Troubleshooting

### Hooks not firing
- Verify `.vscode/settings.json` has `"chat.useCustomAgentHooks": true`
- Check VS Code version supports Agent Mode hooks

### Compliance check missing
- Ensure `tao.instructions.md` is loaded (check `.github/instructions/`)
- Verify agent mode is active (not regular Copilot chat)

### Lint errors on commit
- Check `lint_commands` in `tao.config.json` point to installed tools
- Run lint manually first: `bash .github/tao/scripts/lint-hook.sh`

### Agent ignores rules
- Pre-commit hooks catch violations at commit time
- If agent skips compliance check, the commit will be rejected
- Report persistent issues at [repo URL]/issues
```

## Acceptance Criteria

- [ ] No unqualified absolute claims remain in README.md
- [ ] No unqualified absolute claims remain in README.pt-br.md
- [ ] Troubleshooting section added to both READMEs
- [ ] Claims match actual enforcement architecture (L0/L1/L2)
