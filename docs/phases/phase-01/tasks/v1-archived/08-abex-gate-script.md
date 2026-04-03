# Task T08 — Create abex-gate.sh Script

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** High
**Executor:** Architect (Opus)
**Priority:** P2

---

## Objective

Create a new `abex-gate.sh` script that performs lightweight automated security scanning via regex pattern matching. This replaces the current honor-system ABEX check with an actual automated gate.

## Context

ABEX (Automated Boundary Enforcement eXtension) is currently just a compliance checkbox that agents self-report. There's no actual scanning. This script provides basic automated detection of common security anti-patterns: SQL injection vectors, eval/exec usage, innerHTML without sanitization, hardcoded secrets, and missing error handling at system boundaries.

## Files to Read (BEFORE editing)

- `scripts/validate-plan.sh` — reference for TAO script conventions (exit codes, output format)
- `scripts/validate-execution.sh` — reference for file scanning patterns
- `hooks/lint-hook.sh` — reference for how hooks interact with tao.config.json
- `templates/en/RULES.md` — ABEX section to understand current definition
- `templates/pt-br/RULES.md` — same

## Files to Create/Edit

- `scripts/abex-gate.sh` — NEW: automated security scanning script

## Implementation Steps

1. Read reference files for conventions
2. Create `scripts/abex-gate.sh` with:

   **Header:**
   ```bash
   #!/usr/bin/env bash
   # abex-gate.sh — Automated Boundary Enforcement eXtension
   # Lightweight regex-based security scanning
   # Exit 0 = PASS, Exit 1 = FAIL (blocking issues found)
   ```

   **Input:** Takes a directory path (or defaults to current dir)

   **Patterns to detect:**

   | Category | Pattern | Severity |
   |----------|---------|----------|
   | SQL Injection | String concatenation in SQL queries (`"SELECT.*"+`, `f"SELECT`, `$"SELECT`) | BLOCK |
   | SQL Injection | Non-parameterized queries (`query(.*\+.*\$)`) | WARN |
   | XSS | `innerHTML =` without sanitization | WARN |
   | Command Injection | `eval(`, `exec(`, `system(`, backtick execution | WARN |
   | Hardcoded Secrets | `password\s*=\s*["']`, `api_key\s*=\s*["']`, `secret\s*=\s*["']` | BLOCK |
   | Missing Auth | `TODO.*auth`, `FIXME.*permission` | WARN |

   **Exclusions:**
   - Skip `node_modules/`, `vendor/`, `venv/`, `.git/`, `__pycache__/`
   - Skip `.md`, `.txt`, `.json`, `.yaml`, `.yml` files
   - Skip files > 1MB

   **Output format:**
   ```
   🔒 ABEX Security Scan
   ─────────────────────
   Scanning: /path/to/project
   Files checked: 42
   
   ❌ BLOCK: SQL injection vector
      src/db/users.php:23 — "SELECT * FROM users WHERE id=" + $id
   
   ⚠️  WARN: innerHTML without sanitization
      src/ui/render.js:45 — element.innerHTML = userInput
   
   ─────────────────────
   Result: FAIL (1 blocking, 1 warning)
   ```

   **Exit codes:**
   - `0` — PASS (no blocking issues, warnings OK)
   - `1` — FAIL (at least one blocking issue)

3. Make executable: `chmod +x scripts/abex-gate.sh`
4. Test on tao-test project (should pass — no code yet)
5. Test with a deliberately insecure file to verify detection

## Acceptance Criteria

- [ ] Script exists at `scripts/abex-gate.sh`
- [ ] Detects SQL concatenation patterns (PHP, Python, JS/TS)
- [ ] Detects hardcoded secrets
- [ ] Detects eval/exec/system calls
- [ ] Detects innerHTML without sanitization
- [ ] Skips vendor/node_modules/venv directories
- [ ] Skips non-code files (.md, .json, etc.)
- [ ] Exit 0 on pass, exit 1 on blocking issues
- [ ] Output is clear and shows file:line for each finding
- [ ] No false positives on comments mentioning these patterns in .md files
- [ ] Works on macOS (BSD grep) and Linux (GNU grep)

## Notes / Gotchas

- Use `grep -rn` with `--include` patterns for code files only
- BSD grep (macOS) doesn't support `-P` (Perl regex) — use extended regex `-E` instead
- This is a LIGHTWEIGHT scan — not a replacement for proper SAST tools
- Pattern matching will have false positives — that's OK for a first pass
- Hardcoded secret detection should ignore test files and fixtures
- The script should be self-contained (no dependencies beyond bash + grep)

---

**Expected commit:** `feat(phase-01): T08 — create abex-gate.sh automated security scanner`
