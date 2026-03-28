---
name: tao-debug-investigation
description: "Structured debugging methodology with hypothesis-driven investigation, systematic isolation, and root cause analysis. Use when debugging issues, investigating errors, or troubleshooting production problems."
argument-hint: "Describe the bug, error message, or unexpected behavior"
---
# TAO Debug Investigation

## When to use
Use when debugging issues, investigating errors, or troubleshooting.

## Investigation Protocol
```
1. OBSERVE — What exactly is the symptom?
2. HYPOTHESIZE — What could cause this?
3. TEST — How do we confirm/deny?
4. ISOLATE — Where exactly is the fault?
5. FIX — Minimal change to resolve
6. VERIFY — Does the fix work? Any regressions?
```

## Step 1: OBSERVE
Collect facts before theorizing:
- What is the exact error message?
- When did it start? (after what change?)
- Is it reproducible? (always, sometimes, only on X?)
- What environment? (dev, staging, prod)
- Who reported it? What were they doing?

## Step 2: HYPOTHESIZE
Generate hypotheses ranked by probability:
- H1 (most likely): [description]
- H2: [description]
- H3: [description]

**Common categories:**
- Data issue (null, wrong type, missing field)
- State issue (race condition, stale cache, wrong order)
- Environment issue (config, dependency version, OS)
- Logic issue (wrong condition, off-by-one, boundary)

## Step 3: TEST
For each hypothesis, design a quick test:
- Can you reproduce with a minimal case?
- Can you add logging at the suspected point?
- Does changing one variable confirm/deny?
- Binary search: does it work with half the code commented out?

## Step 4: ISOLATE
Narrow down to the exact location:
- **git bisect** — find the commit that introduced the bug
- **Binary logging** — add logs at midpoint, narrow to half
- **Divide and conquer** — comment out sections until it works
- **Minimal reproduction** — strip down to smallest failing case

## Step 5: FIX
- Fix the root cause, not the symptom
- Minimal change (don't refactor during a fix)
- Write a test that reproduces the bug BEFORE fixing
- The test should fail before the fix, pass after

## Step 6: VERIFY
- [ ] Original bug is fixed
- [ ] Regression test passes
- [ ] All existing tests still pass
- [ ] Fix works in the same environment where bug was found

## Debug Anti-Patterns
- ❌ Changing random things hoping it works
- ❌ Debugging without reproducing first
- ❌ Fixing symptoms instead of root cause
- ❌ Large "fix" that changes many things
- ❌ No test for the bug (will regress)
