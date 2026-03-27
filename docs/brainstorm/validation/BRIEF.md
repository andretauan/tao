# BRIEF.md — TAO Validation Gates

> Synthesis of validation/ brainstorm. Input for executor.
> Created: 2026-03-27 12:31
> Source: DISCOVERY.md (7 topics) + DECISIONS.md (10 decisions)

## Maturity: 7/7
- [x] Problem/objective clear — silent drift between BRIEF→PLAN and PLAN→execution
- [x] ≥2 alternatives explored — AST parsing vs regex, hooks vs scripts, deep vs surface verification
- [x] Trade-offs evaluated — 10 IBIS decisions with positions + arguments
- [x] Decisions have invalidation conditions — all 10 have "Would invalidate if"
- [x] Reference docs consulted — all 6 template files, 3 real brainstorm artifacts, existing hooks
- [x] Scope defined — 2 scripts, manual + agent integration, no deep content verification
- [x] Codebase patterns integrated — python3 -c with sys.argv, bash orchestration, color output

---

## §1 Problem Statement

TAO's pipeline (BRIEF → PLAN → STATUS → disk) has ZERO automated verification at transformation boundaries. Decisions from brainstorm can be silently dropped when creating the plan. Tasks in the plan can be incompletely executed. Two BLOCK-gate scripts are needed to enforce pipeline integrity.

---

## §2 Priorities

1. **Hard gates, not suggestions** — exit 1 blocks, not "consider fixing"
2. **Zero dependencies** — bash + python3 only (TAO pattern)
3. **Works on real TAO data** — tested against actual BRIEF/PLAN/STATUS (20 decisions, 48 tasks)
4. **Bilingual** — supports EN + PT-BR section headers
5. **Integrated in agent loop** — not just standalone scripts

---

## §3 Decisions Locked (10 IBIS decisions)

| # | Decision | Rationale |
|---|----------|-----------|
| DV1 | Scripts live in `scripts/` | Utilities, not git hooks — validate phases, not commits |
| DV2 | Python3 embedded parsing | Consistent with TAO pattern, sys.argv for safety |
| DV3 | Regex D\d+ for decisions | Scans full BRIEF, excludes SUPERSEDED lines |
| DV4 | Backtick extraction for must-haves | Robust against format variations (numbered, bulleted) |
| DV5 | Box-drawing chars for file tree | `── filename` pattern from PLAN's repo structure |
| DV6 | Regex alternation for bilingual | Both EN + PT-BR headers supported with `(EN|PT)` |
| DV7 | Manual + agent integration | Standalone use + Tao/Wu agent loop gates |
| DV8 | Superseded = excluded | ~~D{N}~~ and SUPERSEDED lines skipped in coverage |
| DV9 | Cascading phase detection | arg > config > auto-detect latest phase |
| DV10 | BLOCK vs WARNING levels | Critical gaps = BLOCK (exit 1), soft issues = WARNING (exit 0) |

---

## §4 Technical Context

### Existing patterns to follow:
- `pre-commit.sh` — Python3 embedded parsing of tao.config.json via sys.argv
- `i18n-diff.sh` — Utility script in scripts/, colored output, comparison logic
- `tao.sh` — Config reading helper, `read_config()` function pattern
- BUG #19 fix — ALL python3 -c calls use sys.argv, never $variable inside python

### Document formats (parser contract):
- **BRIEF decisions**: `D\d+` pattern, superseded via `~~` or `SUPERSEDED`
- **BRIEF must-haves**: `` `filename` `` in §7 area
- **PLAN tasks**: `**T\d+**` followed by description, `(D\d+)` refs inline
- **PLAN file tree**: `── filename` lines (├──, └──, │── variants)
- **STATUS tasks**: `| T?\d+ |` in tables, status column with ⏳/✅/❌

---

## §5 NOT Implementing (Scope Out)

- Deep content verification (checking if task content matches requirements)
- CI/CD integration (no GitHub Actions yet)
- Incremental per-task validation during execution
- Automatic PLAN repair (fix missing items)
- DECISIONS.md → BRIEF.md validation (that's Wu's maturity gate)
- Template format enforcement (that's i18n-diff.sh's job)

---

## §6 Escape Conditions

- If real-world BRIEFs diverge too much from patterns → add configurable regex overrides
- If false-positive BLOCKs destroy trust → promote some BLOCKs to WARNING
- If agent integration is too slow → make it opt-in via tao.config.json flag
- If bilingual headers prove insufficient → accept explicit section markers (e.g., `<!-- tao:decisions -->`)

---

## §7 must_haves

### Invariable truths
1. validate-plan.sh BLOCKS if any active decision from BRIEF is not covered in PLAN
2. validate-execution.sh BLOCKS if any PLAN task is not ✅ in STATUS
3. Both scripts use python3 -c with sys.argv (never bash variable interpolation in python)
4. Both scripts support explicit phase-dir argument AND auto-detection
5. Exit 0 = PASS, Exit 1 = BLOCK — no other exit codes

### Mandatory artifacts
1. `scripts/validate-plan.sh` — BRIEF→PLAN coverage gate
2. `scripts/validate-execution.sh` — PLAN→STATUS→disk verification gate

### Connections
- Both scripts READ tao.config.json for phase directory paths
- Tao.agent.md (EN + PT-BR) must reference validate-plan.sh in PLAN_CHECK step
- Tao.agent.md (EN + PT-BR) must reference validate-execution.sh in phase completion step
- Wu.agent.md (EN + PT-BR) should run validate-plan.sh after generating PLAN

---

## §8 Risks

| Risk | Probability | Mitigation |
|------|-------------|------------|
| Format variation across projects | Medium | Regex-based, not header-based parsing |
| False positive BLOCKs | Low | BLOCK only for critical gaps, WARNING for soft issues |
| Python3 not available | Very Low | Already a TAO requirement |
| BRIEF format changes | Low | Patterns (D\d+, backticks) are structural, unlikely to change |

---

## §9 Skills for execution

- `get-shit-done` — execution workflow
- `clean-code` — script quality
- `find-bugs` — testing edge cases

---

## BRIEF QUALITY CHECK

```
📋 BRIEF QUALITY CHECK
├─ Maturity checklist: 7/7
├─ Decisions with IBIS: 10/10
├─ Deferred items: 3
├─ must_haves: 5 truths, 2 artifacts, 4 connections
├─ Reference docs consulted: 9 files
├─ Skills for execution: 3
├─ Escape conditions: 4
└─ User priorities preserved: YES (5 priorities)
```
