# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in TAO, please report it responsibly.

**DO NOT open a public issue.**

Instead, please use [GitHub Security Advisories](https://github.com/andretauan/tao/security/advisories/new) to report the vulnerability privately.

### What to include

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment:** Within 48 hours
- **Assessment:** Within 7 days
- **Fix release:** As soon as possible, depending on severity

### Scope

The following are in scope:

- Shell scripts (`tao.sh`, `install.sh`, hooks, validators)
- Template generation and file writing
- Git operations (hooks, commits)
- Path traversal or injection via configuration

The following are **out of scope**:

- Issues in projects that _use_ TAO (report those to the project maintainer)
- Social engineering
- Denial of service

## Security Best Practices

TAO enforces security through:

- **Pre-commit hooks** — Lint and syntax validation before every commit
- **Security locks** — Protected files, branches, and destructive operations
- **Enforcement hooks** — Runtime validation of R0-R7 compliance rules
- **Parameterized operations** — No shell injection in configuration processing

## Acknowledgments

We appreciate responsible disclosure and will credit security researchers in our release notes (with permission).
