---
name: tao-test-strategy
description: "Test pyramid strategy with coverage analysis, edge case identification, and test planning. Use when planning tests, improving coverage, identifying edge cases, or writing test specifications."
argument-hint: "Describe the feature or module to test"
---
# TAO Test Strategy

## When to use
Use when planning tests, writing test specs, improving coverage, or identifying edge cases.

## Test Pyramid
```
        ╱╲
       ╱ E2E ╲         Few (critical user flows)
      ╱────────╲
     ╱Integration╲     Medium (API/service boundaries)
    ╱──────────────╲
   ╱   Unit Tests    ╲  Many (pure functions, business logic)
  ╱════════════════════╲
```

## Coverage Targets
| Layer | Target | Focus |
|-------|--------|-------|
| Unit | 80%+ | Business logic, calculations, transformations |
| Integration | Key paths | API endpoints, DB queries, external services |
| E2E | Critical flows | Login, checkout, data submission |

## Edge Case Patterns
Always test these categories:
1. **Empty/null** — null, undefined, empty string, empty array, 0
2. **Boundary** — min-1, min, max, max+1, negative
3. **Type coercion** — string where number expected, boolean edge cases
4. **Unicode** — accents, emojis, RTL text, very long strings
5. **Concurrent** — simultaneous requests, race conditions
6. **State** — first use, repeated use, after error, after timeout

## Test Structure (AAA)
```
// Arrange — set up test data and context
// Act — execute the code under test  
// Assert — verify the expected outcome
```

## Test Naming Convention
`[unit]_[scenario]_[expected_result]`
- `createUser_withValidEmail_returnsUserId`
- `createUser_withDuplicateEmail_throwsConflictError`
- `getOrder_withInvalidId_returns404`

## Anti-Patterns to Avoid
- ❌ Testing implementation details (brittle tests)
- ❌ Shared mutable state between tests
- ❌ Tests that depend on execution order
- ❌ Asserting too many things in one test
- ❌ Mocking everything (test nothing real)
- ❌ No assertions (test "passes" but verifies nothing)

## When to Write Tests
- New feature → tests in same PR
- Bug fix → write test that reproduces bug FIRST, then fix
- Refactor → ensure tests exist BEFORE refactoring
