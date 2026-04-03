# Task T17 — Onboarding Flow in Execute-Tao Agents (EN+PT-BR)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P3-INSTALL
**Depends on:** T15

---

## Objective

Add a "first run" onboarding flow to Execute-Tao agents that detects when the project isn't configured and guides the user step-by-step.

## Gaps Fixed

- G36: No onboarding flow — new user says "executar" and agent has no guidance for unconfigured project

## Files to Read

- `agents/pt-br/Executar-Tao.agent.md` — current trigger definitions
- `agents/en/Execute-Tao.agent.md` — current trigger definitions
- `templates/shared/tao.instructions.md` — current compliance check

## Files to Edit

- `agents/pt-br/Executar-Tao.agent.md` — add onboarding trigger
- `agents/en/Execute-Tao.agent.md` — add onboarding trigger

## Changes

### 1. Add onboarding detection

At the START of the agent's session protocol (before reading STATUS.md), add:

```markdown
### Pre-flight Check (before any task execution)

1. Check if `.github/tao/tao.config.json` exists
   - **If NO** → enter ONBOARDING mode (see below)
   - **If YES** → proceed to normal session protocol

### ONBOARDING Mode

If tao.config.json is missing, the project hasn't been installed. Guide the user:

1. "⚠️ TAO não está configurado neste projeto."
2. "Execute no terminal: `bash /path/to/TAO/install.sh`"
3. "Depois volte e diga: @Executar-Tao executar"
4. STOP — do NOT try to execute tasks without config.
```

### 2. Add missing config detection

If tao.config.json exists but is incomplete (no lint_commands, no phases directory):

```markdown
### Incomplete Config Detection

After reading tao.config.json, verify:
- [ ] `phases` directory exists and has at least one phase
- [ ] `lint_commands` is non-empty
- [ ] `dev_branch` is set

If any missing → warn user with specific fix instructions.
```

## Acceptance Criteria

- [ ] Agent detects missing tao.config.json and enters onboarding mode
- [ ] Onboarding provides clear step-by-step instructions
- [ ] Agent does NOT attempt to execute tasks without config
- [ ] Incomplete config detected with specific warnings
- [ ] Both EN and PT-BR agents updated identically
