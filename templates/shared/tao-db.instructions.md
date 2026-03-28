---
applyTo: "**/*.sql,**/migrations/**,**/models/**,**/schemas/**,**/entities/**"
---
# TAO Database Standards — Auto-enforced on database files

## Schema Rules (mandatory)
- Normalize first — denormalize only with proof of performance need
- Every table: `id` (PK), `created_at`, `updated_at`
- Foreign keys are NOT optional — referential integrity always
- Naming: snake_case, plural tables, singular columns
- FK naming: `{table_singular}_id` — e.g. `user_id`, `order_id`
- Boolean columns: `is_`/`has_` prefix — e.g. `is_active`
- Timestamp columns: `_at` suffix — e.g. `published_at`

## SQL Safety (mandatory)
- Parameterized queries ONLY — zero string concatenation
- Never `SELECT *` — always specify columns
- Never N+1 queries — use JOINs or eager loading
- No business logic in triggers — keep in application layer

## Index Strategy (mandatory)
- Foreign keys: ALWAYS index
- WHERE clause columns: index frequently filtered
- Composite indexes: most selective column first
- Don't over-index — each index slows writes

## Migration Safety Checklist (mandatory before running)
- [ ] Migration is reversible (has rollback/down method)
- [ ] No data loss (backup before destructive changes)
- [ ] Large tables: batch operations (not single ALTER on millions)
- [ ] Zero-downtime compatible (no exclusive locks on hot tables)
- [ ] Column rename: two-step (add new → migrate data → drop old)

## Anti-Patterns (never do)
- `VARCHAR(255)` as default — use appropriate length
- Storing JSON for structured, queryable data
- Missing indexes on foreign keys
- `DELETE FROM` without WHERE clause
