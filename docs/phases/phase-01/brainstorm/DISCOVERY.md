# DISCOVERY.md — Phase 01: Vibe Coder Promise Fulfillment

> Exploration of the gap between TAO's promises and reality for non-programmers.
> Created: 2026-03-29 — @Brainstorm-Wu (Opus)
> Source: Full audit of TAO v1.0 against "vibe coder who can't code" persona.

---

## Topic 1: Installation Experience

### What was explored
Simulated the experience of a non-programmer running `install.sh` for the first time.

### Findings
- **Terminal is alien:** The entire install flow requires CLI knowledge (git clone, cd, bash). A vibe coder who only knows VS Code's GUI has never opened a terminal.
- **Python 3 prerequisite is a wall:** "Install Python 3.8+" is an instruction a vibe coder cannot execute without googling for 20 minutes.
- **Q5 (lint stack) is a trap:** "Primary stack for lint: .php | .py | .ts | .js | .rb | .go | .rs | none" — a vibe coder doesn't know which language their AI-built project will use. Most will press Enter (selecting `none`), which disables ALL lint quality gates silently.
- **Auto-detection is trivial:** If `package.json` exists → `.ts/.js`. If `requirements.txt` → `.py`. If `composer.json` → `.php`. This eliminates the confusing question.
- **Tool existence is never verified:** Configuring `.ts: "npx tsc --noEmit"` without npm installed causes silent lint failures. The lint-hook exits 0 (success) when the tool is missing.

### Dead ends
- Considered removing terminal entirely (VS Code extension) — too heavy for v1.1, deferred.
- Considered GUI wizard — same, deferred to future.

### References
- `TAO/install.sh` lines 127-148 (Q5 lint question)
- `TAO/hooks/lint-hook.sh` lines 68-85 (lint execution, no tool check)

---

## Topic 2: The Fatal Gap — novo_projeto → First Execution

### What was explored
What happens when a user says "execute" on a freshly installed project with no phases.

### Findings
- **CONTEXT.md has invalid placeholders:** `Fase: [XX — Nome da Fase]` — the context-hook.sh tries to parse a phase number from this and gets `??`.
- **No phase directory exists:** `docs/phases/fase-01/` doesn't exist after install. There's nothing to execute.
- **The Tao agent's auto-resolve WOULD work IF:** it had a valid phase number. The agent tries to resolve missing BRIEF/PLAN automatically by invoking Wu/Shen. But with phase `??`, path resolution fails.
- **CONTRADICTION discovered:** CONTEXT.md template says "ajudar o usuário a planejar a primeira fase" but the agent's golden rule says "NUNCA faça perguntas ao usuário." These are mutually exclusive.
- **Solution is clear:** When `status == novo_projeto`, Tao needs a special onboarding flow BEFORE the main loop. This flow creates the first phase and kicks off brainstorm.

### Dead ends
- Considered making the agent silently brainstorm based on `project.description` — fails when description is generic ("My project").
- Considered always creating fase-01 in install.sh without the agent knowing — creates empty phase with no brainstorm, agent gets confused.

### Chain of reasoning
The correct solution is TWO changes working together:
1. `install.sh` creates fase-01 directory (with templates, ready for brainstorm)
2. `Executar-Tao.agent.md` detects `novo_projeto` → enters onboarding mode → asks ONE question (exception to "never ask") → invokes Wu → continues to loop

### References
- `TAO/templates/pt-br/CONTEXT.md` (placeholder)
- `TAO/agents/pt-br/Executar-Tao.agent.md` lines 26-27 (golden rule)
- `TAO/hooks/context-hook.sh` lines 72-85 (phase number extraction)

---

## Topic 3: Quality Gates — Real vs Decorative

### What was explored
Audited every quality gate to classify: code-enforced (real) vs prompt-instruction (honor system).

### Findings — Code-Enforced (REAL)
| Gate | Script | Enforcement |
|------|--------|-------------|
| Lint after edit | lint-hook.sh | Hard — runs on every PostToolUse |
| Read before edit | enforcement-hook.sh | Soft — warning only, not block |
| validate-brainstorm.sh | BRIEF ≥5/7, DISCOVERY ≥10 lines | Hard — exit 1 blocks |
| validate-plan.sh | BRIEF→PLAN coverage | Hard — exit 1 blocks |
| validate-execution.sh | All tasks ✅ | Hard — exit 1 blocks |
| forensic-audit.sh | 3-round structural audit | Hard — exit 1 blocks |
| faudit.sh | 3-mentality quality audit | Hard — exit 1 blocks |
| doc-validate.sh | Documentation completeness | Hard — exit 1 blocks |
| pre-commit.sh | Lint before commit | Hard — blocks commit |

### Findings — Prompt-Only (HONOR SYSTEM)
| Gate | Where | Enforcement |
|------|-------|-------------|
| ABEX 3-pass audit | Agent prompt instructions | Agent can claim "ABEX: PASSA" without doing it |
| R5 (read before edit) | enforcement-hook.sh | Warning only — agent can ignore |
| R0 Compliance check | Agent prompt instructions | Agent can skip the block |
| R7 Clean git | Agent prompt instructions | Agent can forget |

### Key insight
The pipeline gates (validate-*.sh, forensic-audit.sh, faudit.sh) are genuinely robust. But the per-task quality (ABEX, R5) is soft. Creating `abex-gate.sh` with even basic pattern detection (SQL concat, innerHTML, eval, hardcoded secrets) would make a meaningful difference.

### Dead ends
- Considered making ABEX fully automated with AST parsing — too complex for v1.1, regex patterns are sufficient for obvious issues.

---

## Topic 4: Economic Claims vs Reality

### What was explored
Calculated the FULL cost of a TAO phase including brainstorm + planning, not just execution.

### Findings
**README claims:** "60% cost reduction" based on 10 execution tasks only.

**Full-cycle calculation:**
- Brainstorm: 5-8 Opus turns × 3x = 15-24x
- Planning: 2-3 Opus turns × 3x = 6-9x
- Execution: 2 Opus + 6 Sonnet + 2 free = 12x
- Gate pipeline: 1-2 Opus turns × 3x = 3-6x
- **Total: 36-51x**

**Without TAO (pure vibe coding):** 10-15 Opus turns × 3x = 30-45x

**Conclusion:** TAO may cost the SAME or slightly MORE than vibe coding in raw model costs. The value is in QUALITY, not cost savings. The 60% figure is technically true for the execution phase alone but misleading as a headline claim.

### What should change
- Qualify the 60% claim: "60% savings during execution" not "overall"
- Reframe value proposition: quality + traceability, not just cost
- Full-cycle costs documented in ECONOMICS.md

---

## Topic 5: Contradictions Found

### auto_push: false vs "Sempre push após commit"
- `tao.config.json` default: `auto_push: false`
- `RULES.md`: "Sempre `git push origin dev` após cada commit"
- Agent Executar-Tao correctly reads config (conditional push)
- But RULES.md is read at session start and contradicts
- **Fix:** RULES.md must say "respeitando git.auto_push do tao.config.json"

### novo_projeto → "ajudar" vs "NUNCA pergunte"
- Already covered in Topic 2
- **Fix:** Explicit exception in golden rule and RULES.md

---

## Topic 6: VS Code Hooks Activation

### What was explored
The hooks system (context-hook, lint-hook, enforcement-hook) requires `chat.useCustomAgentHooks: true`.

### Findings
- Without this toggle, hooks DON'T run — no error, no warning
- The entire enforcement layer (R5, auto-lint, context injection) disappears silently
- A vibe coder configuring VS Code settings is unlikely
- **Solution:** install.sh should create `.vscode/settings.json` with the toggle enabled
- **Risk:** User may have existing .vscode/settings.json — must merge, not overwrite

---

## Topic 7: Rate Limit and Wu Fallback

### What was explored
What happens when Opus is rate-limited and user tries to brainstorm.

### Findings
- Wu has NO fallback model by design (README says "better to wait")
- For a dev who understands rate limits, this is acceptable
- For a vibe coder, the agent just fails with a confusing error
- Adding a Sonnet fallback for DIVERGE mode (exploration) is acceptable — the quality risk is limited to exploration, not decisions
- Alternatively: clear error message explaining what happened and what to do

### Decision: Clear error message (safer than fallback)
Adding a Sonnet fallback to Wu changes the fundamental quality guarantee. Better to show a clear, helpful message.
