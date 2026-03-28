---
name: tao-refactoring
description: "Safe refactoring methodology with code smell detection, step-by-step transformation, and regression prevention. Use when refactoring code, reducing technical debt, or improving code structure."
argument-hint: "Describe the code to refactor or the smell to fix"
---
# TAO Safe Refactoring

## When to use
Use when refactoring code, reducing technical debt, or restructuring modules.

## Pre-Flight Checklist
Before ANY refactoring:
- [ ] Tests exist for the code being changed (if not, write them first)
- [ ] Current tests pass (baseline)
- [ ] Scope is defined (what changes, what doesn't)
- [ ] git status is clean (commit before starting)

## Common Code Smells & Fixes

### Smell: Long Function (> 30 lines)
**Fix:** Extract Method
1. Identify a cohesive block of code
2. Extract into a named function
3. Pass only needed parameters
4. Run tests

### Smell: Deep Nesting (> 3 levels)
**Fix:** Guard Clauses / Early Returns
```
// Before:
if (user) {
  if (user.active) {
    if (user.hasPermission) {
      doWork();
    }
  }
}

// After:
if (!user) return;
if (!user.active) return;
if (!user.hasPermission) return;
doWork();
```

### Smell: Duplicate Code
**Fix:** Extract shared logic into a single function
Only extract when logic is IDENTICAL — similar ≠ duplicate

### Smell: Primitive Obsession
**Fix:** Create value objects or enums
```
// Before: email is a raw string everywhere
// After: Email class with validation
```

### Smell: God Class (class doing too many things)
**Fix:** Split into focused classes with single responsibility

### Smell: Feature Envy (method using another class's data)
**Fix:** Move method to the class that owns the data

## Refactoring Safety Protocol
1. **Small steps** — one transformation at a time
2. **Test after each step** — don't batch multiple changes
3. **No behavior changes** — refactoring ≠ adding features
4. **Commit frequently** — each step gets its own commit

## Red Flags — STOP Refactoring
- Tests are failing → revert last change
- Scope is growing → commit what you have, plan remaining as new task
- You're adding features → that's not refactoring, make a separate task
