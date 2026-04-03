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

---

## Topic 8: Enforcement Architecture — The 40-Gap Audit

> Added: 2025-07-15 — @Brainstorm-Wu (Opus)
> Source: Rigorous re-audit of ALL TAO source files after discovering text rules fail ~30% of the time.

### What was explored
After scientific audit revealed 16 systematic failures (F01-F16), user asked: "como garantir, 100%, de maneira FORÇADA e inflexível?" This led to a complete re-audit of all hooks, scripts, agents, templates, and install flow — specifically to identify what CAN be code-enforced vs what MUST remain text.

### Chain of reasoning

**Premise:** LLMs are probabilistic. Text rules → ~70% compliance. More emphasis? Still ~70%. The ONLY way to increase compliance is to move enforcement from text (L2) to code (L0/L1).

**Key insight:** Pre-commit hooks are the ultimate enforcement point because:
1. They run DETERMINISTICALLY (bash, not LLM)
2. Commit FAILS if hook fails — model HAS to fix
3. Model can't bypass them (no `--no-verify` allowed by LOCK 6)

**Architecture designed:**
- **L0 (pre-commit/commit-msg/pre-push):** 100% enforcement. If code says NO, commit/push fails. Period.
- **L1 (PostToolUse/SessionStart hooks):** ~95% enforcement. Fires after every tool call. Can warn strongly, inject context. Model SEES the warning. Can't block but creates friction.
- **L2 (improved text):** ~70-80%. Unified, non-contradictory, prescriptive sequence. Better than before but still probabilistic.

### Findings — 40 Gaps Identified

**Category: L0 — Pre-commit gaps (G01-G08)**
| Gap | What's missing | Impact |
|-----|----------------|--------|
| G01 | No destructive command scan (rm -rf, DROP TABLE, etc.) | LOCK 3 exists only in text |
| G02 | No `.tao-pause` check | LOCK 5 exists only in text |
| G03 | ABEX is prompt-only, no code check at commit time | Security claims unenforceable |
| G04 | No commit message format validation | LOCK 6 format rule is text-only |
| G05 | No pre-push hook exists at all | LOCK 2 "never push main" and "never force push" are text-only |
| G06 | No timestamp validation for R4 | CONTEXT.md could have stale timestamps |
| G07 | install-hooks.sh doesn't install commit-msg or pre-push | Only pre-commit + post-commit installed |
| G08 | `abex-gate.sh` doesn't exist yet | D5 decided to create it but it was never implemented |

**Category: L1 — PostToolUse/SessionStart gaps (G09-G18)**
| Gap | What's missing | Impact |
|-----|----------------|--------|
| G09 | context-hook.sh injects no real timestamp | Dashboard has no R4 data |
| G10 | context-hook.sh doesn't inject available skills | R3 skill check is impossible without data |
| G11 | context-hook.sh doesn't inject compliance pre-computed values | Agent fabricates objective facts |
| G12 | enforcement-hook.sh R5 is warning-only | Agent can edit unread files and just see a warning |
| G13 | enforcement-hook.sh doesn't read `compliance.*` config flags | tao.config.json compliance section is decorative |
| G14 | No terminal command interception in enforcement-hook | rm -rf in terminal isn't caught by PostToolUse |
| G15 | No ABEX PostToolUse hook exists | Security checks only happen if agent self-reports |
| G16 | lint-hook.sh doesn't verify tool exists | Missing lint tool → silent pass |
| G17 | No onboarding detection in hooks | First run with no config → confusing error |
| G18 | context-hook.sh doesn't inject lint status | User has no visibility into lint health |

**Category: L2 — Text instruction gaps (G19-G28)**
| Gap | What's missing | Impact |
|-----|----------------|--------|
| G19 | Compliance check format differs across 12 agent/instruction files | Agent picks random format, some fields wrong |
| G20 | RULES.md says "sempre push" but config says auto_push:false | Contradiction → agent picks one randomly |
| G21 | RULES.md doesn't mention novo_projeto exception | Agent stuck on "never ask" when onboarding needed |
| G22 | ABEX description differs between RULES.md and Executar-Tao agents | Agent does 1-pass or 3-pass randomly |
| G23 | CONTEXT.md template has broken placeholders | context-hook fails to parse phase number |
| G24 | INDEX.md descriptions are truncated | Agent can't match skills correctly |
| G25 | Agent reading lists differ across 12 files | Some agents miss RULES.md, some miss CHANGELOG |
| G26 | R3 skill check has no matching algorithm | "Check INDEX.md" but no HOW to match skills |
| G27 | Compliance check has no prescriptive SEQUENCE | Agent may report "SIM" without actually doing step |
| G28 | Wu agent has no rate-limit handling | Hits Opus limits silently, may degrade to Sonnet |

**Category: Install gaps (G29-G36)**
| Gap | What's missing | Impact |
|-----|----------------|--------|
| G29 | lint-hook.sh doesn't verify tool exists | Configured tool missing → silent pass |
| G30 | Q5 UX confusing (option number vs command name) | User selects "1" but sees "phpstan analyse" written |
| G31 | No phase-01 creation during install | First run has nothing to execute |
| G32 | No .vscode/settings.json created | Hooks silently don't fire |
| G33 | lint_commands may be empty without warning | All quality gates disabled |
| G34 | No .gitignore for TAO artifacts | .tao-pause, *.local files committed |
| G35 | No actionable output after install | User doesn't know what to do next |
| G36 | No onboarding flow in agents | Agent says "executar" but has no config |

**Category: Documentation gaps (G37-G40)**
| Gap | What's missing | Impact |
|-----|----------------|--------|
| G37 | README overpromises ("100% compliance") | Expectations don't match reality |
| G38 | No troubleshooting section | Vibe coder stuck on common issues |
| G39 | GETTING-STARTED.md has no quick path | Too much detail before first action |
| G40 | ECONOMICS.md lacks full-cycle costs | Only per-query costs, misleading |

### Dead ends explored
- **Full AST enforcement:** Considered running proper static analysis (ESLint security plugin, Bandit, phpstan --level=max) inside pre-commit. Rejected: too project-specific, TAO can't know which tools/configs to use. The lightweight regex approach (abex-gate.sh) catches TOP 5 patterns without project-specific setup.
- **Agent action logging:** Considered creating a PostToolUse hook that logs every tool call to a file for forensic analysis. Deferred: useful but not blocking — enforcement is more valuable than auditability for v1.
- **100% enforcement target:** Mathematically impossible with LLMs in the loop. ~2% of rules are irreducibly subjective (brainstorm depth, IBIS quality, documentation thoroughness). These can be mitigated by model selection (Opus for judgment tasks) but never eliminated.

### References
- All hook files: `hooks/pre-commit.sh`, `hooks/enforcement-hook.sh`, `hooks/context-hook.sh`, `hooks/lint-hook.sh`, `hooks/install-hooks.sh`
- All scripts: `scripts/validate-*.sh`, `scripts/forensic-audit.sh`, `scripts/faudit.sh`, `scripts/doc-validate.sh`
- All agents: `agents/pt-br/*.agent.md`, `agents/en/*.agent.md`
- Config: `tao.config.json.example`
- Install: `install.sh`
