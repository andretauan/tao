---
name: tao-git-workflow
description: "TAO-compatible git workflow with conventional commit messages, branch strategy, and PR checklist. Auto-loaded for all git operations to ensure consistent commit format and branch discipline."
user-invocable: false
---
# TAO Git Workflow

## When to use
Auto-loaded for all git operations: commits, branches, PRs.

## Commit Message Format (TAO)
```
type(phase-XX): TNN — short description
```

**Types:**
| Type | When |
|------|------|
| feat | New feature |
| fix | Bug fix |
| refactor | Code restructure (no behavior change) |
| test | Add/update tests |
| docs | Documentation only |
| chore | Build, config, tooling |
| style | Formatting, whitespace |

**Rules:**
- 1 commit = 1 task
- Subject line ≤ 72 characters
- Imperative mood: "add feature", NOT "added feature"
- Reference phase and task: `feat(phase-01): T03 — add user authentication`

## Branch Strategy
```
main ─────────────────────────── production (protected)
  └─ dev ─────────────────────── integration
       ├─ feature/phase-01-auth   task branches (optional)
       └─ fix/phase-02-t05-null   bug fix branches (optional)
```

**Rules:**
- Work on `dev` (or branch from tao.config.json → git.dev_branch)
- NEVER push directly to `main`
- NEVER `git push --force`
- NEVER `git reset --hard`

## Pre-Commit Checklist
- [ ] Lint passes (R1)
- [ ] Tests pass
- [ ] CONTEXT.md updated (R6)
- [ ] No secrets in staged files
- [ ] No unrelated changes (one task per commit)

## PR Description Template
```markdown
## What
[Brief description of changes]

## Why
[Motivation — task reference]

## How
[Implementation approach]

## Testing
[How to verify]

## Checklist
- [ ] Tests pass
- [ ] Lint passes
- [ ] CONTEXT.md updated
- [ ] CHANGELOG.md updated
```
