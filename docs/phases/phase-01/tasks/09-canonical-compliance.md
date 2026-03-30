# Task T09 — Canonical Compliance Check: Single Source + Prescriptive Protocol

**Phase:** 01 — Enforcement Architecture
**Complexity:** High
**Executor:** Architect (Opus)
**Priority:** P2-TEXT (L2)
**Depends on:** T05 (context-hook injects data referenced here)

---

## Objective

Define ONE canonical compliance check format and prescriptive execution SEQUENCE. Currently defined in 4 places with 3 different formats. Fix: RULES.md has the canonical definition, all other sources reference it.

## Gaps Fixed

- G15: Compliance check in 4 places, 3 formats
- G25: ABEX 3 different definitions
- G26: R3 skill check impossible (no algorithm)
- G27: Mandatory reading lists inconsistent

## Files to Read

- `templates/en/RULES.md` — current R0 section
- `templates/pt-br/RULES.md` — current R0 section
- `templates/shared/tao.instructions.md` — current compliance section
- `templates/pt-br/copilot-instructions.md` — current compliance section
- `templates/en/copilot-instructions.md` — current compliance section
- `agents/pt-br/Executar-Tao.agent.md` — 7-field compliance (most complete)
- `agents/en/Execute-Tao.agent.md` — 7-field compliance

## Files to Edit

- `templates/en/RULES.md` — rewrite R0 as prescriptive SEQUENCE
- `templates/pt-br/RULES.md` — same
- `templates/shared/tao.instructions.md` — replace compliance section with reference to RULES.md
- `templates/pt-br/copilot-instructions.md` — replace compliance section with reference to RULES.md
- `templates/en/copilot-instructions.md` — replace compliance section with reference to RULES.md
- `agents/pt-br/Executar-Tao.agent.md` — add note: "Format defined in RULES.md §R0"
- `agents/en/Execute-Tao.agent.md` — same

## New R0 Definition (canonical)

Replace current R0 in RULES.md with:

```markdown
### R0 — Compliance Check (PRESCRIPTIVE SEQUENCE)

> Before ANY code-modifying response, execute these steps IN ORDER.
> The SessionStart hook injects system-provided data. Use those values — DO NOT guess.

**SEQUENCE (every step mandatory):**

1. **CHECK** SessionStart context for system-provided data (timestamp, phase, skills, lint)
2. **READ** `.github/tao/CONTEXT.md` — verify phase, status, locked decisions
3. **READ** `.github/tao/CHANGELOG.md` — last 3 entries
4. **READ** `.github/tao/tao.config.json` — lint commands, branch config
5. **CHECK** `.github/skills/INDEX.md` — identify skills matching the file types you will edit
6. **EMIT** compliance block with REAL values from steps 1-5:

\```
📋 COMPLIANCE CHECK — Phase XX
├─ Agent: [name] ([model])
├─ Skills consulted: [list from step 5, or "none applicable — no matching file types"]
├─ Files read before editing: [list from steps 2-4]
├─ CONTEXT.md read: YES
├─ CHANGELOG.md consulted: YES
├─ ABEX: [PASS after 3 passes / N/A if no code changes]
└─ Timestamp: [from system-provided data, NOT invented]
\```

**PROHIBITED:**
- Emitting the block BEFORE completing steps 1-5
- Using placeholder values (00:00, "loading", "pending")
- Omitting any field
- Guessing timestamps
```

### Changes to other files

**tao.instructions.md, copilot-instructions.md:**
Replace their compliance section with:
```
Compliance check format and execution sequence: see `.github/tao/RULES.md` §R0.
```

**Executar-Tao agent files:**
Add above their compliance block:
```
> Canonical format defined in `.github/tao/RULES.md` §R0.
> SessionStart hook provides system data. Use THOSE values.
```

## Acceptance Criteria

- [ ] RULES.md (EN) has prescriptive SEQUENCE for R0
- [ ] RULES.md (PT-BR) has prescriptive SEQUENCE for R0
- [ ] tao.instructions.md references RULES.md §R0 (no duplicate format)
- [ ] copilot-instructions.md (EN+PT-BR) references RULES.md §R0
- [ ] Executar-Tao/Execute-Tao agents reference RULES.md §R0
- [ ] ABEX definition unified: 3 passes (Security, User, Performance) + automated via abex-gate.sh
- [ ] R3 algorithm documented: "match file extension against instruction applyTo patterns"
