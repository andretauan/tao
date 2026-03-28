---
name: tao-clean-code
description: "Clean code principles including SOLID, DRY, KISS, naming conventions, function design, and complexity management. Use when writing new code, reviewing for quality, or establishing coding standards."
user-invocable: false
---
# TAO Clean Code Principles

## When to use
Auto-loaded as background knowledge for all code writing and review tasks.

## Core Principles

### SOLID
- **S**ingle Responsibility — one reason to change per class/module
- **O**pen/Closed — open for extension, closed for modification
- **L**iskov Substitution — subtypes must be substitutable for base types
- **I**nterface Segregation — many specific interfaces > one general
- **D**ependency Inversion — depend on abstractions, not concretions

### DRY (Don't Repeat Yourself)
Duplicated LOGIC (not just similar code) should be extracted.
BUT: premature abstraction is worse than duplication. Rule of three: tolerate once, note twice, extract at three.

### KISS (Keep It Simple)
- Prefer simple solutions over clever ones
- If a junior developer can't understand it in 5 minutes, simplify
- No premature optimization

### YAGNI (You Aren't Gonna Need It)
- Don't build for hypothetical future requirements
- The right abstraction is the minimum for the current task

## Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Function | verb + noun | `getUserById()`, `calculateTotal()` |
| Boolean | is/has/can prefix | `isActive`, `hasPermission` |
| Constant | UPPER_SNAKE | `MAX_RETRIES`, `API_TIMEOUT` |
| Class | PascalCase noun | `UserService`, `OrderRepository` |
| Variable | descriptive noun | `activeUsers`, `totalAmount` |

## Function Design
- **Max parameters: 3** — use object/struct if more needed
- **Max lines: ~30** — extract if longer
- **Max nesting: 3** — use early returns
- **Single abstraction level** — don't mix high-level orchestration with low-level details
- **Side effects: declare in name** — `saveUser()` vs `getUser()`

## Error Handling
- Handle errors at the boundary, not at every level
- Use language-idiomatic patterns (Result types, exceptions, error codes)
- Never swallow errors silently
- Log with context: what happened, what was expected, what input caused it
