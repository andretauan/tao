# DECISIONS.md — TAO Validation Gates

> Format: IBIS (Kunz & Rittel 1970). Consumer: Executor.
> Created: 2026-03-27 12:31
> Decisions: 10

---

## Decision Index

| # | Issue | Decision | Status |
|---|-------|----------|--------|
| DV1 | Where do scripts live? | scripts/ (utilities, not hooks) | ACTIVE |
| DV2 | How to parse markdown? | Python3 embedded via sys.argv | ACTIVE |
| DV3 | How to extract decisions from BRIEF? | Regex D\d+ excluding SUPERSEDED lines | ACTIVE |
| DV4 | How to extract must-haves? | Backtick-wrapped names in §7 area | ACTIVE |
| DV5 | How to extract file tree from PLAN? | Unicode box-drawing chars (── pattern) | ACTIVE |
| DV6 | Bilingual support | Regex alternation for EN+PT-BR headers | ACTIVE |
| DV7 | Integration points | Manual + agent loop integration | ACTIVE |
| DV8 | Superseded decisions | Excluded from validation (~~D{N}~~ pattern) | ACTIVE |
| DV9 | Phase directory detection | Arg > config > auto-detect latest | ACTIVE |
| DV10 | Strictness levels | V1-V6/E1-E6 = BLOCK, V7-V8/E7-E8 = WARNING | ACTIVE |

---

### Issue DV1 — Where do validation scripts live?

**Context:** TAO has `hooks/` for git hooks and `scripts/` for utilities.

**Positions:**
1. `hooks/` — alongside pre-commit.sh
2. `scripts/` — alongside new-phase.sh, i18n-diff.sh
3. Standalone in root

**Decision:** P2 — `scripts/validate-plan.sh` + `scripts/validate-execution.sh`
**Rationale:** These are utilities invoked manually or by agents, not git lifecycle hooks. They validate PHASE boundaries, not COMMIT validity. Consistent with existing scripts like `i18n-diff.sh`.
**Would invalidate if:** Validation needs to be mandatory on every commit (then hooks integration needed).

---

### Issue DV2 — How to parse markdown content?

**Context:** Need to extract structured data (decisions, tasks, file trees) from markdown.

**Positions:**
1. Pure bash (grep, sed, awk)
2. Python3 with markdown library
3. Python3 embedded via `python3 -c` with sys.argv (TAO pattern)

**Decision:** P3 — Python3 embedded
**Rationale:** Consistent with TAO's established pattern (tao.sh, pre-commit.sh, lint-hook.sh all use python3 -c). No external dependencies. sys.argv pattern avoids bash variable injection (BUG #19 lesson). Regex in Python is more powerful than bash.
**Would invalidate if:** Python3 becomes unavailable on target systems (unlikely — it's already a TAO requirement).

---

### Issue DV3 — How to identify decisions in BRIEF?

**Context:** BRIEF references decisions as D1, D3, D5-D20. Some are superseded (D2, D12).

**Positions:**
1. Parse §3 "Key Decisions" table only
2. Scan entire BRIEF for D\d+ pattern
3. Parse DECISIONS.md directly

**Decision:** P2 — Scan entire BRIEF for `D\d+`, excluding lines with `SUPERSEDED` or `~~`
**Rationale:** The BRIEF is the synthesis document — it should contain ALL active decisions. Scanning full text catches decisions referenced anywhere (§3, §7, §4). Excluding superseded lines handles the D2/D12 case. More robust than relying on specific table format.
**Would invalidate if:** BRIEFs start mentioning decision numbers in non-decision context (e.g., "we had D12 options" — number collision).

---

### Issue DV4 — How to identify must-have artifacts?

**Context:** BRIEF §7 lists mandatory artifacts with backtick-wrapped filenames.

**Positions:**
1. Parse numbered list items
2. Extract backtick-wrapped text in §7 area
3. Look for specific keywords ("must", "required", "obrigatório")

**Decision:** P2 — Extract backtick text between section §7 boundary and next section
**Rationale:** Backticks consistently wrap filenames in both template and real BRIEF. Section boundary detection with bilingual headers (`must_haves|Artefatos obrigatórios|Mandatory`). Handles both `1. \`install.sh\`` and `- \`install.sh\`` formats.
**Would invalidate if:** Must-haves stop using backtick format, or include non-filename backtick content.

---

### Issue DV5 — How to parse expected file structure?

**Context:** PLAN contains a tree diagram of expected repository structure.

**Positions:**
1. Parse `── filename` lines (Unicode box chars)
2. Parse indentation-based tree
3. Skip file tree, only check must-haves

**Decision:** P1 — Parse `── ` (box-drawing) followed by filename
**Rationale:** The tree format uses `├──`, `└──`, `│` consistently. Extracting the filename after `── ` captures all expected files. Filter lines ending with `/` as directories (not file checks). Handles comments after `#` in tree lines.
**Would invalidate if:** Projects use different tree formats, or the PLAN doesn't include a file tree section (then graceful skip).

---

### Issue DV6 — How to handle bilingual templates?

**Context:** TAO is EN + PT-BR. Section headers differ by language.

**Decision:** Regex alternation `(Maturity|Maturidade)`, `(Out of Scope|NÃO Implementar)`, etc.
**Rationale:** Both languages are well-defined. The regex set is small (≤10 alternations). No runtime language detection needed — just match both.
**Would invalidate if:** 3rd language added with completely different header patterns (unlikely for v0.1).

---

### Issue DV7 — How to integrate into TAO workflow?

**Positions:**
1. Manual only (user runs when they want)
2. Mandatory in agent loop
3. Both — manual + agent integration

**Decision:** P3 — Both
**Rationale:** Manual allows standalone use. Agent integration makes it a hard gate. Execute-Tao.agent.md gains 2 new steps: validate-plan after PLAN creation, validate-execution when all ✅.
**Would invalidate if:** Agent loop becomes too slow with validation steps (unlikely — scripts are fast).
**Impacts:** Execute-Tao.agent.md (EN + PT-BR), Brainstorm-Wu.agent.md (validate after PLAN generation)

---

### Issue DV8 — How to handle superseded decisions?

**Decision:** Superseded decisions (~~D{N}~~ or SUPERSEDED on same line) are EXCLUDED from coverage check. If they DO have tasks, emit WARNING (not BLOCK) — indicates possible confusion.
**Rationale:** Superseded decisions purposefully don't need tasks. But having tasks for them isn't critically wrong.
**Would invalidate if:** Superseded decisions start being reused (shouldn't happen in IBIS).

---

### Issue DV9 — How to find phase directory?

**Positions:**
1. Always require explicit argument
2. Auto-detect from config
3. Argument > config > auto-detect

**Decision:** P3 — Cascade: (1) CLI arg, (2) tao.config.json phases_dir + latest phase, (3) docs/brainstorm/ fallback
**Rationale:** Flexible for all use cases. Standalone brainstorms (like TAO's own) use docs/brainstorm/. Per-phase brainstorms use phases/phase-NN/brainstorm/.
**Would invalidate if:** Projects use non-standard brainstorm locations (script supports explicit arg for this).

---

### Issue DV10 — What blocks vs what warns?

**Decision:** Two severity levels:
- **BLOCK** (exit 1): Missing BRIEF/PLAN/STATUS, maturity < 5, uncovered decisions, uncovered must-haves, incomplete tasks, missing artifacts, placeholders found
- **WARNING** (logged but exit 0): Superseded with tasks, scope-out overlap, shell syntax issues, unverifiable completion criteria

**Rationale:** BLOCK for things that PROVE the pipeline is broken. WARNING for things that MIGHT indicate problems. False-positive BLOCKs destroy trust in the tool.
**Would invalidate if:** Warnings consistently turn out to be real problems (then promote to BLOCK).

---

## Deferred
- **Deep content verification** (checking if task CONTENT matches requirements, not just existence) — Reason: requires task-specific knowledge, massive maintenance. Revisit if superficial checks prove insufficient.
- **CI/CD integration** (run validators in GitHub Actions) — Reason: TAO doesn't have CI yet. Revisit in v0.2.
- **Incremental validation** (validate one task at a time during execution) — Reason: overkill for MVP. Validate at phase boundaries is sufficient.
