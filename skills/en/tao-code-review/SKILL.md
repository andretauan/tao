---
name: tao-code-review
description: "Structured 6-axis code review covering correctness, security, performance, readability, tests, and patterns. Use when reviewing code, doing pull request reviews, or checking code quality."
argument-hint: "Describe what to review or paste the code"
---
# TAO Code Review (6-Axis)

## When to use
Use for code reviews, PR reviews, or quality checks on any code modification.

## The 6 Axes

### Axis 1 — Correctness
- Does the code do what it claims?
- Are edge cases handled? (null, empty, boundary values)
- Are error paths correct? (try/catch, fallbacks, error propagation)
- Are race conditions possible? (async, concurrency, shared state)

### Axis 2 — Security
- Input validation at system boundaries?
- SQL injection: parameterized queries only?
- XSS: output encoding/sanitization?
- Authentication: permissions checked before data access?
- Secrets: no hardcoded credentials? (.env only)
- File uploads: real MIME type validation?

### Axis 3 — Performance
- N+1 queries? (batch fetches instead)
- Unnecessary loops inside loops? (O(n²) → O(n))
- Unbounded lists? (pagination, limits)
- Missing indexes on frequently queried columns?
- Memory leaks? (unclosed connections, listeners)

### Axis 4 — Readability
- Clear naming? (functions = verbs, variables = nouns)
- Functions under ~30 lines?
- Nesting depth ≤ 3? (early returns, guard clauses)
- No magic numbers? (named constants)
- Comments explain WHY, not WHAT?

### Axis 5 — Tests
- Are new features tested?
- Are edge cases covered?
- Are tests independent? (no shared mutable state)
- Are assertions specific? (not just "no error thrown")
- Is coverage adequate for critical paths?

### Axis 6 — Patterns
- Consistent with project conventions? (read CLAUDE.md)
- No unnecessary abstractions for one-time code?
- Error handling follows project pattern?
- File structure follows project conventions?

## Review Output Format
```
## Code Review — [file/feature]

### ✅ Passed
- [axis]: [what's good]

### ⚠️ Suggestions
- [axis]: [improvement with rationale]

### 🚫 Blockers
- [axis]: [must fix before merge]

### Verdict: APPROVE | REQUEST CHANGES | COMMENT
```

## Review Etiquette
- Be specific: "line 42: missing null check" > "handle errors better"
- Suggest solutions, not just problems
- Distinguish nitpicks from blockers
- Acknowledge good code, not just bad
