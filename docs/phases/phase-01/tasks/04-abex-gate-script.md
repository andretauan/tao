# Task T04 — Create abex-gate.sh: Security Scanner

**Phase:** 01 — Enforcement Architecture
**Complexity:** High
**Executor:** Architect (Opus)
**Priority:** P0-HARD (L0)
**Depends on:** None (this is a dependency for T01 and T07)

---

## Objective

Create abex-gate.sh — a regex-based security scanner that detects common vulnerability patterns. Exit 1 = BLOCK. Called by pre-commit (T01) and abex-hook (T07).

## Gaps Fixed

- G06: No ABEX automation (entirely prompt-based)

## Files to Read

- `scripts/validate-plan.sh` — TAO script conventions (exit codes, output format, colors)
- `templates/en/RULES.md` — ABEX section (3 passes: Security, User, Performance)
- `templates/pt-br/RULES.md` — same

## Files to Create

- `scripts/abex-gate.sh` — NEW: automated security scanner

## Detection Patterns

| Category | Pattern | Severity | Language |
|----------|---------|----------|----------|
| SQL Injection | `"SELECT.*" +` / `f"SELECT` / `query(..$var..)` | BLOCK | All |
| SQL Injection | Non-parameterized query construction | BLOCK | PHP, Python, JS |
| XSS | `innerHTML =` without sanitize | WARN | JS/TS |
| Code Injection | `eval(` / `exec(` with variable input | BLOCK | All |
| Command Injection | backtick execution with variables, `os.system($var)` | BLOCK | All |
| Hardcoded Secrets | `password = "`, `api_key = "`, `secret = "` | BLOCK | All |
| Missing Error Handling | `catch {}` (empty catch block) | WARN | JS/TS/Java |
| Path Traversal | `../` in file open with user input | WARN | All |

## Implementation Notes

- Input: single file path OR directory
- Scan only code files (skip .md, .json, .txt)
- Skip files in node_modules/, vendor/, .git/
- Output: severity + file:line + pattern found
- Exit 0 = clean, Exit 1 = BLOCK findings
- Use TAO color conventions (RED/GREEN/YELLOW)
- Read compliance.abex_enabled from config (if false, exit 0 immediately)

## Acceptance Criteria

- [ ] Detects SQL injection concatenation patterns
- [ ] Detects eval/exec with variable input
- [ ] Detects hardcoded secrets (password=, api_key=)
- [ ] Detects innerHTML without sanitization
- [ ] Exits 1 for BLOCK patterns, 0 for clean
- [ ] Works when called from pre-commit.sh
- [ ] Works when called from abex-hook.sh
- [ ] Follows TAO script conventions (colors, header, exit codes)
