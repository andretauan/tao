---
name: tao-database-design
description: "Database schema design with normalization, indexing strategy, migration planning, and constraint patterns. Use when designing database schemas, planning migrations, optimizing queries, or reviewing data models."
user-invocable: false
---
# TAO Database Design

## When to use
Use when designing schemas, planning migrations, optimizing queries, or reviewing data models.

## Schema Design Principles
1. **Normalize first** — denormalize only with proof of performance need
2. **Name consistently** — snake_case, plural tables, singular columns
3. **Every table gets:** id (PK), created_at, updated_at
4. **Foreign keys are NOT optional** — referential integrity matters
5. **Soft delete** — add `deleted_at` instead of actual DELETE when data is valuable

## Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Table | plural, snake_case | `order_items` |
| Column | singular, snake_case | `total_amount` |
| Primary key | `id` | `id` |
| Foreign key | `{table_singular}_id` | `user_id`, `order_id` |
| Index | `idx_{table}_{columns}` | `idx_users_email` |
| Unique | `uq_{table}_{columns}` | `uq_users_email` |
| Boolean | is_/has_ prefix | `is_active`, `has_verified` |
| Timestamp | _at suffix | `created_at`, `published_at` |

## Index Strategy
- **Primary key** — automatic (always indexed)
- **Foreign keys** — ALWAYS index (joins depend on it)
- **WHERE clause columns** — index frequently filtered columns
- **Unique constraints** — combine with index
- **Composite indexes** — order matters: most selective column first
- **DON'T over-index** — each index slows writes

## Migration Safety Checklist
- [ ] Migration is reversible (has `down` method)
- [ ] No data loss (backup before destructive changes)
- [ ] Large table changes are batched (not single ALTER on millions of rows)
- [ ] Tested on copy of production data
- [ ] Zero-downtime compatible (no exclusive locks on hot tables)

## Migration Patterns
```
-- Safe column add (non-blocking)
ALTER TABLE users ADD COLUMN bio TEXT;

-- Safe column rename (two-step for zero-downtime)
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);
-- Step 2: Migrate data
UPDATE users SET display_name = name;
-- Step 3: (next release) Drop old column
ALTER TABLE users DROP COLUMN name;
```

## Anti-Patterns
- ❌ `SELECT *` — always specify columns
- ❌ N+1 queries — use JOINs or eager loading
- ❌ Business logic in triggers — keep in application layer
- ❌ No indexes on foreign keys
- ❌ VARCHAR(255) as default — use appropriate length
- ❌ Storing JSON for structured, queryable data
