---
name: tao-security-audit
description: "OWASP Top 10 security audit with checklist for injection, XSS, authentication, authorization, secrets management, and common vulnerabilities. Use when auditing security, reviewing auth code, or hardening an application."
user-invocable: false
---
# TAO Security Audit (OWASP-Aligned)

## When to use
Use for security audits, auth reviews, vulnerability assessment, or before production deployment.

## OWASP Top 10 Checklist

### A01 — Broken Access Control
- [ ] Every endpoint checks authorization BEFORE processing
- [ ] Default deny: access is denied unless explicitly granted
- [ ] CORS is configured with specific origins (not `*`)
- [ ] Directory traversal: paths are sanitized (no `../`)
- [ ] API rate limiting is in place
- [ ] JWT/session tokens have reasonable expiry

### A02 — Cryptographic Failures
- [ ] Passwords hashed with bcrypt/argon2 (NOT md5/sha1)
- [ ] HTTPS enforced everywhere
- [ ] Sensitive data encrypted at rest
- [ ] No secrets in source code (use .env)
- [ ] No sensitive data in logs or error messages

### A03 — Injection
- [ ] SQL: parameterized queries ONLY (zero string concatenation)
- [ ] NoSQL: input sanitized before queries
- [ ] Command injection: no user input in shell commands
- [ ] LDAP injection: parameterized LDAP queries
- [ ] Template injection: user input not used in templates

### A04 — Insecure Design
- [ ] Threat model exists for critical features
- [ ] Business logic abuse scenarios considered
- [ ] Resource limits prevent abuse (file size, request count)

### A05 — Security Misconfiguration
- [ ] Debug mode OFF in production
- [ ] Default credentials changed
- [ ] Error messages don't reveal stack traces
- [ ] Unnecessary HTTP methods disabled
- [ ] Security headers configured (CSP, X-Frame, HSTS)

### A06 — Vulnerable Components
- [ ] Dependencies have no known CVEs
- [ ] Dependencies are up-to-date (within reason)
- [ ] Lock files committed (package-lock.json, poetry.lock, etc.)

### A07 — Authentication Failures
- [ ] Strong password policy enforced
- [ ] Account lockout after failed attempts
- [ ] Multi-factor available for sensitive operations
- [ ] Session invalidation on logout
- [ ] No credential exposure in URLs

### A08 — Data Integrity Failures
- [ ] Dependencies come from trusted sources
- [ ] CI/CD pipeline has integrity checks
- [ ] Serialization is safe (no arbitrary deserialization)

### A09 — Logging & Monitoring Failures
- [ ] Failed login attempts are logged
- [ ] Access control failures are logged
- [ ] Logs don't contain sensitive data
- [ ] Alerting exists for suspicious patterns

### A10 — SSRF (Server-Side Request Forgery)
- [ ] User-supplied URLs are validated (allowlist)
- [ ] Internal services not accessible via user requests
- [ ] URL redirects are validated

## Audit Output Format
```
## Security Audit — [scope]
**Date:** YYYY-MM-DD
**Severity:** CRITICAL | HIGH | MEDIUM | LOW

### Findings
| # | Category | Severity | Finding | Remediation |
|---|----------|----------|---------|-------------|
| 1 | A03      | HIGH     | ...     | ...         |

### Summary
- Critical: X | High: X | Medium: X | Low: X
- Verdict: PASS | CONDITIONAL PASS | FAIL
```
