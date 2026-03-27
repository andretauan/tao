# DISCOVERY.md — TAO Validation Gates

> Pipeline integrity enforcement: BRIEF→PLAN and PLAN→EXECUTION.
> Created: 2026-03-27 12:31

## References
- `docs/brainstorm/BRIEF.md` — real TAO BRIEF (maturity 7/7, 20 decisions)
- `docs/brainstorm/PLAN.md` — real TAO PLAN (48 tasks, 7 sprints)
- `docs/brainstorm/STATUS.md` — real TAO STATUS (48/48 ✅)
- `phases/shared/BRIEF.md.template` — BRIEF template format
- `phases/en/PLAN.md.template` — PLAN template format
- `phases/en/STATUS.md.template` — STATUS template format
- `hooks/pre-commit.sh` — existing modular hook pipeline (pattern reference)

---

## Problem Statement

The TAO pipeline has 3 transformations, all trust-based:

```
DISCOVERY + DECISIONS → BRIEF → PLAN → STATUS → disk
```

**No transformation is verified.** The agent that creates PLAN can silently drop BRIEF decisions. The agent that executes can deliver incomplete artifacts. Result: **silent drift** — what was decided ≠ what was planned ≠ what was executed.

**Concrete evidence from TAO's own build:**
- PT-BR CONTEXT.md template: 0 references to onboarding mode (D14 requires `status: new_project`)
- Qi.agent.md: 0 references to CLAUDE.md (D11 requires all agents reference CLAUDE.md)
- Both were caught manually. Without validation gates, future phases WILL have worse drift.

---

## Topic: Parseable Patterns in TAO Documents

### What We Know

**BRIEF.md format (both template and real):**
- Maturity checklist: lines matching `- [x]` or `- [ ]` under "Maturity" section
- Decisions: `D{N}` pattern throughout text. Superseded marked with `~~D{N}~~` or "SUPERSEDED"
- Must-haves: backtick-wrapped filenames (`` `filename.ext` ``) in §7 section
- Scope out: bullet list under "NÃO Implementar" / "Out of Scope"
- Both EN and PT-BR sections headers exist in practice

**PLAN.md format:**
- Tasks: `**T{NN}**` followed by description. Decision refs inline: `(D16)` or `(D16, D20)`
- Decision mapping table: `| D{N} | T{NN} list |` format
- File structure: tree with `── filename` lines
- Completion criteria: `- [ ]` checklist items
- Source line: "Source:" referencing BRIEF

**STATUS.md format:**
- Tables with `| T{NN} | task name | ⏳/✅/❌ |`
- Groups by priority (P0, P1, P2) or sprint (S1-S7)
- Real TAO STATUS also has Executor, Complexity, Commit columns

**DECISIONS.md format (reference):**
- `## D{N} — Title`
- `~~D{N} — SUPERSEDED by D{M}~~`
- IBIS structure: Issue, Positions, Arguments, Decision, "Would invalidate if"

### What We Don't Know
- How much format variation will exist across projects (different users may customize templates)
- Whether future templates will change section headers

### Conclusion
Parsing should be REGEX-based, not header-based. Look for `D\d+`, `**T\d+**`, `` `filename` ``, `[x]`/`[ ]` patterns. These are structural markers unlikely to change. Support both EN and PT-BR section headers for section boundary detection.

---

## Topic: validate-plan.sh Design

### Extraction Strategy

| Source | Pattern | What to extract |
|--------|---------|----------------|
| BRIEF §maturity | `- [x]` count | Maturity score (need ≥5) |
| BRIEF §decisions | `D\d+` excluding `~~` and SUPERSEDED lines | Active decision IDs |
| BRIEF §must_haves | `` `[^`]+` `` in §7 area | Required artifact filenames |
| BRIEF §scope_out | Bullets under OUT section | Exclusion list |
| PLAN source | "Source:" line | BRIEF provenance |
| PLAN tasks | `\*\*T\d+\*\*` + surrounding text | Task IDs + descriptions |
| PLAN decision refs | `(D\d+)` or `D\d+` in task text | Which decisions each task covers |
| PLAN mapping table | `\| D\d+ \|` rows | Explicit decision→task mapping |
| PLAN file tree | `── \S+` lines | Expected final file structure |

### Validation Logic

```
1. BRIEF exists? → no → BLOCK (critical)
2. BRIEF maturity ≥ 5? → no → BLOCK (critical)
3. PLAN exists? → no → BLOCK (critical)
4. PLAN references BRIEF? → no → BLOCK (high)
5. For each active D{N} in BRIEF:
   → D{N} appears in PLAN tasks or mapping? → no → BLOCK (high)
6. For each must-have artifact in BRIEF §7:
   → artifact name appears in PLAN tasks? → no → BLOCK (high)
7. For each scope-out item in BRIEF §5:
   → Check no task explicitly implements it → yes → WARNING
8. For each superseded D{N}:
   → Has dedicated task? → yes → WARNING (not BLOCK)
```

### Discarded Alternative: AST Parsing
Considered using a proper markdown parser (python-markdown, mistune). Rejected because:
- Adds dependency (TAO is zero-dep bash+python3)
- Regex on well-defined patterns is simpler and more robust against markdown variations
- BRIEF/PLAN have structural patterns (D{N}, T{NN}, backticks) that are harder to extract from AST than from regex

---

## Topic: validate-execution.sh Design

### Extraction Strategy

| Source | Pattern | What to extract |
|--------|---------|----------------|
| PLAN tasks | `\*\*T\d+\*\*` | All task IDs + names |
| PLAN file tree | `── \S+` lines | Expected files on disk |
| PLAN completion | `- [ ]` items | Completion criteria |
| STATUS tables | `\| T?\d+ \|.*\| [⏳✅❌] \|` | Task ID → status mapping |

### Validation Logic

```
1. PLAN exists? → no → BLOCK
2. STATUS exists? → no → BLOCK
3. For each T{NN} in PLAN:
   → T{NN} exists in STATUS? → no → BLOCK (task missing from tracking)
   → T{NN} status is ✅? → no → BLOCK (task not completed)
4. For each file in PLAN's expected structure:
   → File exists on disk? → no → BLOCK (artifact missing)
5. Scan all delivered files (excluding templates/, brainstorm/, .git/):
   → Contains [SUBSTITUIR], [REPLACE], [TODO], [XX], [Phase Name]? → yes → BLOCK
6. For each .sh file (excluding templates/):
   → bash -n passes? → no → WARNING
7. For each verifiable completion criterion:
   → Met? → no → WARNING
```

### Discarded Alternative: Deep Content Verification
Considered verifying task CONTENT (e.g., "did T09 actually add ABEX to CLAUDE.md?"). Rejected because:
- Requires task-specific knowledge (what "adding ABEX" means varies)
- Would need task → expected-content mapping (massive maintenance burden)
- The evidence check (artifacts exist, syntax valid, no placeholders) catches 80% of failures
- Deep content verification is the AGENT's job (ABEX), not a script's job

### Discarded Alternative: Hook Integration
Considered making validate-execution.sh a pre-commit hook. Rejected because:
- It validates PHASE completion, not COMMIT validity — different lifecycle event
- A commit can be valid (syntax OK) while the phase is incomplete
- Better as manual gate invoked by agent or user at phase boundary

---

## Topic: Integration Points

### Where in the TAO Loop

**validate-plan.sh:**
- Tao.agent.md: step 2b (PLAN_CHECK) should include `bash scripts/validate-plan.sh [phase-dir]`
- Wu.agent.md: after generating PLAN.md, run validation before handing to executor
- Can also run standalone: `bash scripts/validate-plan.sh docs/phases/phase-01`

**validate-execution.sh:**
- Tao.agent.md: when all STATUS tasks are ✅, run before declaring phase complete
- Step 4 (SEM ⏳ = FASE CONCLUÍDA): add validation gate
- Can also run standalone: `bash scripts/validate-execution.sh docs/phases/phase-01`

### Agent Template Changes Needed

In Tao.agent.md (both EN + PT-BR), add to the loop:
```
After PLAN creation:
  Run: bash scripts/validate-plan.sh [phase-dir]
  If exit 1 → BLOCK — fix plan before executing

When all tasks ✅:
  Run: bash scripts/validate-execution.sh [phase-dir]
  If exit 1 → BLOCK — fix gaps before declaring complete
```

---

## Topic: Bilingual Section Header Support

The scripts need to detect sections in both languages. Key mappings:

| Concept | EN Header | PT-BR Header |
|---------|-----------|-------------|
| Maturity | "Maturity Checklist", "Maturity:" | "Maturidade", "Checklist" |
| Decisions | "Key Decisions", "Decisions" | "Decisões Travadas", "Decisões" |
| Must-haves | "must_haves", "Mandatory Artifacts" | "must_haves", "Artefatos obrigatórios" |
| Scope out | "Out of Scope", "NOT" | "NÃO Implementar", "Scope Out" |
| File structure | "Repository Structure", "Structure" | "Estrutura Final", "Estrutura" |
| Completion | "Completion Criteria" | "Critério de Conclusão" |

Strategy: use regex alternation `(EN_pattern|PT_BR_pattern)` for section detection.

---

## ⚠️ Invalidated
None yet.
