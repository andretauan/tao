---
applyTo: "**/*.test.{py,js,ts,jsx,tsx},**/*.spec.{py,js,ts,jsx,tsx},**/test_*.py,**/tests/**,**/__tests__/**"
---
# TAO Test Standards — Auto-enforced on test files

## Test Pyramid (mandatory)
- Unit tests (80%+): pure functions, business logic, calculations
- Integration tests (key paths): API endpoints, DB queries, external services
- E2E tests (critical flows): login, checkout, data submission

## Structure: AAA (Arrange → Act → Assert)
- One assertion concept per test
- Tests are independent — no shared mutable state
- Tests don't depend on execution order
- Naming: `[unit]_[scenario]_[expected_result]`

## Edge Cases (always test these)
1. Empty/null — null, undefined, empty string, empty array, 0
2. Boundary — min-1, min, max, max+1, negative
3. Type coercion — string where number expected
4. Unicode — accents, emojis, very long strings
5. Concurrent — simultaneous requests, race conditions
6. State — first use, after error, after timeout

## Anti-Patterns (never do)
- Testing implementation details (brittle)
- Mocking everything (tests nothing real)
- No assertions (test "passes" but verifies nothing)
- Asserting too many things in one test

## When to Write Tests
- New feature → tests in same commit
- Bug fix → write failing test FIRST, then fix
- Refactor → ensure tests exist BEFORE refactoring
