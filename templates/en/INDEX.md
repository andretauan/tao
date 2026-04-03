# Skills Index

> Auto-generated catalog of available skills. TAO agents consult this file before code tasks (R3).
> VS Code also auto-discovers skills from `.github/skills/*/SKILL.md`.

## How to Match Skills (R3 Algorithm)

When editing a file, check which skills apply:

1. **Always active** (every code task): `tao-clean-code`, `tao-security-audit`, `tao-code-review`, `tao-git-workflow`
2. **By file extension**: match the file you're editing against the instruction applyTo patterns:
   - `.test.{js,ts,py}` or `/tests/` → `tao-test-strategy`
   - Routes/controllers/handlers → `tao-api-design`
   - `.sql` / migrations / models → `tao-database-design`
3. **By task type**: match the task description:
   - Refactoring mentioned → `tao-refactoring`
   - Bug investigation → `tao-debug-investigation`
   - Performance work → `tao-performance-audit`
   - Architecture decision → `tao-architecture-decision`
   - Planning → `tao-plan-writing`
   - Brainstorming → `tao-brainstorm`

List all matching skills in the compliance check.

---

## TAO Skills (built-in)

| Skill | Type | Description |
|-------|------|-------------|
| `tao-api-design` | slash + auto | RESTful API design conventions including endpoint naming, HTTP methods, status codes, pagination, error handling, and versioning patterns. Use when designing APIs, creating endpoints, or reviewing API contracts. |
| `tao-architecture-decision` | slash + auto | Architecture Decision Record (ADR) writing with trade-off analysis matrix and decision evaluation framework. Use when making architectural decisions, choosing technologies, or documenting design decisions. |
| `tao-brainstorm` | auto-load | IBIS-based brainstorming methodology with structured issue-position-argument analysis and maturity scoring. Use when brainstorming, evaluating ideas, or writing BRIEF.md. |
| `tao-clean-code` | auto-load | Clean code principles including SOLID, DRY, KISS, naming conventions, function design, and complexity management. Use when writing new code, reviewing for quality, or establishing coding standards. |
| `tao-code-review` | slash + auto | Structured 6-axis code review covering correctness, security, performance, readability, tests, and patterns. Use when reviewing code, doing pull request reviews, or checking code quality. |
| `tao-database-design` | slash + auto | Database schema design with normalization, indexing strategy, migration planning, and constraint patterns. Use when designing database schemas, planning migrations, optimizing queries, or reviewing data models. |
| `tao-debug-investigation` | slash + auto | Structured debugging methodology with hypothesis-driven investigation, systematic isolation, and root cause analysis. Use when debugging issues, investigating errors, or troubleshooting production problems. |
| `tao-git-workflow` | auto-load | TAO-compatible git workflow with conventional commit messages, branch strategy, and PR checklist. Auto-loaded for all git operations to ensure consistent commit format and branch discipline. |
| `tao-onboarding` | slash + auto | Guide new users through TAO framework setup, concepts, and first execution. Use when someone asks about TAO, how to get started, or needs help understanding the workflow. |
| `tao-performance-audit` | slash + auto | Performance analysis methodology with profiling techniques, bottleneck identification, and optimization patterns. Use when auditing performance, optimizing slow code, or planning capacity. |
| `tao-plan-writing` | auto-load | Expert task decomposition for creating TAO PLAN.md files. Breaks features into phases and tasks with acceptance criteria, effort estimates, and dependencies. Use when planning work, creating phases, or decomposing features. |
| `tao-refactoring` | slash + auto | Safe refactoring methodology with code smell detection, step-by-step transformation, and regression prevention. Use when refactoring code, reducing technical debt, or improving code structure. |
| `tao-security-audit` | slash + auto | OWASP Top 10 security audit with checklist for injection, XSS, authentication, authorization, secrets management, and common vulnerabilities. Use when auditing security, reviewing auth code, or hardening an application. |
| `tao-test-strategy` | slash + auto | Test pyramid strategy with coverage analysis, edge case identification, and test planning. Use when planning tests, improving coverage, identifying edge cases, or writing test specifications. |

## User Skills

> Add your own skills below. Create a folder in `.github/skills/` with a `SKILL.md` file.
> See [agentskills.io](https://agentskills.io) for the specification.

| Skill | Type | Description |
|-------|------|-------------|
| *(add your skills here)* | | |
