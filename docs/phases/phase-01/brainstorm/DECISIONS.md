# DECISIONS.md — Phase 01: Vibe Coder Promise Fulfillment

> Structured decisions using IBIS protocol (Kunz & Rittel, 1970).
> Created: 2026-03-29 — @Brainstorm-Wu (Opus)

---

## Index

| # | Issue | Decision | Status |
|---|-------|----------|--------|
| D1 | How to handle novo_projeto first run | Onboarding exception + install creates phase 01 | Decided |
| D2 | How to handle lint stack selection | Auto-detect from project files + confirm | Decided |
| D3 | How to handle missing lint tools | Check at hook runtime + warn clearly | Decided |
| D4 | How to fix auto_push contradiction | Config is truth, RULES references config | Decided |
| D5 | How to enforce ABEX beyond prompt | Lightweight script for obvious patterns | Decided |
| D6 | How to handle hooks activation | install.sh creates .vscode/settings.json | Decided |
| D7 | How to improve context-hook output | Mini-dashboard with phase/tasks/lint status | Decided |
| D8 | How to handle Wu rate-limit | Clear error message, no model fallback | Decided |
| D9 | How to fix economic claims | Qualify 60% to execution-only, document full cycle | Decided |
| D10 | How to scope this work | TAO repo only, test in tao-test, all dev branch | Decided |

---

### Issue D1 — How to handle the first execution on a novo_projeto

**Positions:**
1. **Onboarding mode in Tao agent** — detect `novo_projeto`, ask one question, create phase, invoke Wu
2. **install.sh does everything** — creates phase + brainstorm + plan during install
3. **Do nothing** — document that user must brainstorm first

**Arguments:**
- For P1: Natural flow — user says "execute", agent guides them. One-time exception to "never ask" is acceptable.
- Against P1: Breaks the golden rule. Creates a special code path that may diverge from normal behavior.
- For P2: Zero friction at runtime — everything is ready after install. No rule-breaking needed.
- Against P2: install.sh can't brainstorm. It can create directory structure but not the content. User would get empty templates.
- For P3: Simplest change. Just add clearer docs.
- Against P3: The README says "you don't need to know programming." Requiring manual steps contradicts this.

**Decision:** P1 — Onboarding mode in Tao agent + install.sh creates phase directory
**Rationale:** The two changes complement each other. install.sh creates the directory (low-friction), and Tao detects `novo_projeto` and enters a guided flow. The one-question exception is justified because it only fires ONCE per project lifetime.
**Invalidaria se:** VS Code Copilot adds native project initialization flow that makes this redundant.

---

### Issue D2 — How to handle lint stack selection during install

**Positions:**
1. **Auto-detect from project files** — check for package.json, requirements.txt, composer.json, etc.
2. **Remove the question entirely** — default to `none`, let agents configure later
3. **Keep current question** — just improve the wording

**Arguments:**
- For P1: Eliminates a confusing question. Works for existing projects. Fallback to `none` for empty projects.
- Against P1: May detect wrong stack. Edge case: project has both package.json and requirements.txt.
- For P2: Simplest change. No detection logic.
- Against P2: `none` means no quality gates — the core promise breaks.
- For P3: Minimal change, low risk.
- Against P3: A vibe coder still won't understand the question regardless of wording.

**Decision:** P1 — Auto-detect with confirmation
**Rationale:** Detection covers 90% of cases. The confirmation prompt lets users override. Fallback to `none` with clear warning for empty projects.
**Invalidaria se:** TAO gains runtime lint detection (agent detects file type and runs appropriate linter without pre-configuration).

---

### Issue D3 — How to handle missing lint tools at runtime

**Positions:**
1. **Check at hook runtime** — lint-hook.sh verifies tool exists before running
2. **Check at install time only** — install.sh warns but hooks don't check
3. **Check at both times** — install warns, hooks also verify

**Arguments:**
- For P1: Catches the problem when it matters (during execution). Tools may be installed/removed between install and execution.
- Against P1: Adds overhead to every PostToolUse hook call (negligible — `command -v` is fast).
- For P2: Simpler hooks. Warning at install is sufficient for most users.
- Against P2: Users may install TAO before their project's toolchain. Install warning would be premature.
- For P3: Most robust. Catches issues at both boundaries.
- Against P3: Redundant checks. Overengineered.

**Decision:** P1 — Check at hook runtime only
**Rationale:** Hook check is authoritative (runs when lint actually matters). Install-time check is unreliable for new projects. The `command -v` check adds <1ms overhead.
**Invalidaria se:** Hook execution adds noticeable latency (>100ms) — but command -v is typically <1ms.

---

### Issue D4 — How to fix auto_push vs RULES.md contradiction

**Positions:**
1. **Config is truth** — RULES.md references config value
2. **RULES is truth** — always push, ignore config
3. **Remove auto_push** — always push (simpler)

**Arguments:**
- For P1: Config-over-convention is a TAO design principle. RULES should reference, not override.
- Against P1: Agent reads RULES at session start and may follow it before reading config.
- For P2: Simpler mental model. One rule.
- Against P2: Some users may not want auto-push (air-gapped environments, review workflows).
- For P3: Eliminates the contradiction entirely.
- Against P3: Removes flexibility. Some users need manual push control.

**Decision:** P1 — Config is truth, RULES references config
**Rationale:** TAO's design principle #2 is "config over convention." RULES.md should say "push according to git.auto_push setting" not "always push."
**Invalidaria se:** TAO design principles change to convention-over-config.

---

### Issue D5 — How to enforce ABEX beyond prompt instructions

**Positions:**
1. **Lightweight detection script** — regex patterns for common vulnerabilities
2. **Full AST-based analysis** — proper static analysis per language
3. **Keep prompt-only** — document it as a soft gate honestly

**Arguments:**
- For P1: Catches obvious issues (SQL concat, innerHTML, eval, hardcoded secrets). Low complexity. Matches TAO pattern (bash + python3).
- Against P1: Regex is incomplete. False positives/negatives. May give false sense of security.
- For P2: Comprehensive, accurate.
- Against P2: Requires per-language parsers. Massive scope. Better served by existing tools (ESLint, Bandit, etc.).
- For P3: Honest. No false promises.
- Against P3: README says "bulletproof quality" and "code-enforced guardrails." Having ABEX be prompt-only contradicts this.

**Decision:** P1 — Lightweight detection script
**Rationale:** Catching the TOP 5 obvious patterns (SQL injection, eval, innerHTML, hardcoded secrets, missing error handling) is better than catching nothing. False positives are acceptable — better to warn than miss. Clear documentation that this is a smoke test, not comprehensive analysis.
**Invalidaria se:** TAO integrates with proper linting tools (ESLint security plugin, Bandit, etc.) making the custom script redundant.

---

### Issue D6 — How to handle hooks activation

**Positions:**
1. **install.sh creates .vscode/settings.json** — auto-enable hooks
2. **Require manual activation** — better docs with screenshots
3. **Create VS Code extension** — proper UI with toggle

**Arguments:**
- For P1: Zero-friction for new projects. Safe merge for existing settings.json.
- Against P1: May conflict with user's existing settings. Must handle JSON merge carefully.
- For P2: No risk of breaking user settings.
- Against P2: Vibe coder won't follow docs. The most critical toggle is buried in settings.
- For P3: Best UX.
- Against P3: Massive scope for v1.1. Requires extension development expertise.

**Decision:** P1 — install.sh creates .vscode/settings.json with safe merge
**Rationale:** Safe JSON merge with python3 is trivial. Covers 95% of cases. Extension is future work.
**Invalidaria se:** VS Code changes the settings mechanism or hooks become default enabled.

---

### Issue D7 — How to improve context-hook dashboard

**Positions:**
1. **Mini-dashboard with box drawing** — phase, tasks, lint status in a visual box
2. **Simple key-value output** — current format but with more info
3. **Full HTML-style rich output** — leverage VS Code markdown rendering

**Arguments:**
- For P1: Visually clear. Easy to scan. Adds lint status visibility.
- Against P1: Box drawing may not render well in all terminals.
- For P2: Minimal change. Already works.
- Against P2: Current output is cryptic for vibe coders.
- For P3: Beautiful but hooks output is plain text, not markdown.

**Decision:** P1 — Mini-dashboard
**Rationale:** Hook output is plain text injected into chat context. Box drawing with ASCII characters is reliable. Adding lint status and hook status gives immediate visibility.
**Invalidaria se:** VS Code hooks gain markdown rendering support (then P3 becomes viable).

---

### Issue D8 — How to handle Wu rate-limited on Opus

**Positions:**
1. **Clear error message** — explain what happened, what to do
2. **Sonnet fallback for DIVERGE only** — lower quality but keeps working
3. **No change** — README already explains the design choice

**Arguments:**
- For P1: Honest, helpful. User knows what's happening and can act.
- Against P1: User is still blocked. Can't brainstorm.
- For P2: Unblocks user. DIVERGE quality hit is acceptable (exploration, not decisions).
- Against P2: Changes Wu's quality guarantee. May produce shallow exploration that leads to bad plans.
- For P3: Already documented as intentional.
- Against P3: A vibe coder won't read the README. They'll just see a failed agent.

**Decision:** P1 — Clear error message in Wu agent
**Rationale:** Quality of brainstorm is too important to compromise. A clear message ("Opus is temporarily unavailable. Wait X minutes or check your quota.") is better than a bad brainstorm that wastes execution cycles downstream.
**Invalidaria se:** GitHub Copilot provides a reliable way to check remaining quota programmatically — then we could show exact wait time.

---

### Issue D9 — How to fix economic claims

**Positions:**
1. **Qualify the 60% to execution-only** — add full-cycle numbers
2. **Remove the 60% claim entirely** — reframe around quality
3. **Recalculate including brainstorm** — find accurate overall number

**Arguments:**
- For P1: Honest. The 60% is real for execution. Context makes it clear.
- Against P1: Still leads with a number that's partially misleading.
- For P2: Cleanest. No number to dispute.
- Against P2: Cost savings IS a real benefit of model routing. Removing it hides legitimate value.
- For P3: Most accurate representation.
- Against P3: Hard to give a single number because brainstorm cost varies wildly (simple project = 2 turns, complex = 10).

**Decision:** P1 — Qualify to execution-only + document full-cycle
**Rationale:** The 60% execution savings is real and verifiable. Adding context ("during execution; full-cycle costs vary") is honest without hiding the benefit.
**Invalidaria se:** Model pricing changes make the routing irrelevant (all models same price).

---

### Issue D10 — Scope of this phase

**Positions:**
1. **TAO repo only** — all changes in /home/tauan/Apps/TAO, test in tao-test
2. **TAO + tao-test** — changes in both repos
3. **TAO repo + fresh install test** — clean room test

**Arguments:**
- For P1: Clean scope. TAO is the source. tao-test re-installs to verify.
- Against P1: Changes in installed project files (agents, templates) need to be reinstalled to test.
- For P2: Direct testing without reinstall.
- Against P2: Muddies the scope. Which repo is source of truth?
- For P3: Most thorough. Proves install.sh works end-to-end.
- Against P3: Extra setup step.

**Decision:** P1 — TAO repo only, reinstall to tao-test for testing
**Rationale:** TAO is the single source. Changes are made there. Testing is done by running install.sh on tao-test (or fresh dir).
**Invalidaria se:** TAO gains a development mode where changes in TAO are live-linked to projects.
