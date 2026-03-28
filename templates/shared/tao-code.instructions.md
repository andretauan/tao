---
applyTo: "**/*.{py,js,ts,jsx,tsx,vue,svelte,java,go,rs,rb,php,c,cpp,cs,swift,kt,scala,lua,sh,bash,zsh}"
---
# TAO Code Standards — Auto-enforced on every code file

## Clean Code (mandatory)
- SOLID: single responsibility, depend on abstractions
- Functions: max ~30 lines, max 3 params, max 3 nesting levels
- Naming: functions = verb+noun, booleans = is/has/can, constants = UPPER_SNAKE
- DRY: extract at third repetition, not before
- No premature abstraction — minimum complexity for current task

## Security (mandatory — OWASP)
- SQL: parameterized queries ONLY — zero string concatenation
- Input: validate at system boundaries (user input, external APIs)
- Output: sanitize/escape before rendering
- Secrets: `.env` only — never hardcode credentials
- Auth: check permissions BEFORE processing
- No user input in shell commands, templates, or dynamic queries

## Self-Review (mandatory before committing)
Every code change is auto-reviewed on 6 axes:
1. **Correctness** — edge cases (null, empty, boundary), error paths, race conditions
2. **Security** — injection, XSS, auth bypass, secrets exposure
3. **Performance** — N+1 queries, O(n²) loops, unbounded lists, missing indexes
4. **Readability** — clear names, short functions, no magic numbers
5. **Tests** — new code has tests, edge cases covered, assertions specific
6. **Patterns** — consistent with project conventions (read CLAUDE.md)

If ANY axis fails → fix before committing. No exceptions.
