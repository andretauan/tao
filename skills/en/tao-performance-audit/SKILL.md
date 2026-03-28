---
name: tao-performance-audit
description: "Performance analysis methodology with profiling techniques, bottleneck identification, and optimization patterns. Use when auditing performance, optimizing slow code, or planning capacity."
user-invocable: false
---
# TAO Performance Audit

## When to use
Use when investigating slow endpoints, high memory usage, or capacity planning.

## Performance Audit Protocol
```
1. MEASURE — baseline numbers (don't guess)
2. IDENTIFY — find the bottleneck (not the symptom)
3. OPTIMIZE — fix the bottleneck (only)
4. VERIFY — measure again (prove improvement)
```

## Common Bottleneck Patterns

### Database
- **N+1 queries** — loop fetching related records one by one
  → Fix: JOIN or eager loading
- **Full table scan** — missing index on WHERE clause
  → Fix: add index, check EXPLAIN plan
- **Overfetching** — SELECT * when only 2 columns needed
  → Fix: select only needed columns
- **Connection exhaustion** — no pool or pool too small
  → Fix: connection pooling with proper limits

### Application
- **Synchronous I/O blocking** — waiting on HTTP/DB in main thread
  → Fix: async/await, worker queues
- **Memory leaks** — unbounded caches, unclosed connections
  → Fix: TTL caches, proper cleanup
- **Unnecessary computation** — recalculating on every request
  → Fix: caching (Redis, in-memory), memoization
- **Large payload** — sending 1MB JSON when client needs 10 fields
  → Fix: field selection, pagination, compression

### Frontend
- **Bundle size** — importing entire library for one function
  → Fix: tree-shaking, dynamic imports
- **Render blocking** — large synchronous scripts
  → Fix: async/defer, code splitting
- **Layout thrashing** — reading+writing DOM in loops
  → Fix: batch DOM reads, then batch writes

## Rules of Optimization
1. **Don't guess, measure** — profile before optimizing
2. **Optimize the bottleneck** — 10x speedup on non-bottleneck = 0% improvement
3. **Simple first** — caching, indexing, batching before algorithmic redesign
4. **Set targets** — "response under 200ms" not "make it faster"
5. **Benchmark before and after** — prove the improvement with numbers

## Performance Budget (web)
| Metric | Target |
|--------|--------|
| First Contentful Paint | < 1.5s |
| Largest Contentful Paint | < 2.5s |
| Time to Interactive | < 3.5s |
| API response (p95) | < 200ms |
| Bundle size (gzipped) | < 200KB |

## Output Format
```
## Performance Audit — [scope]
**Date:** YYYY-MM-DD

### Baseline
- [metric]: [current value]

### Bottleneck Analysis
| # | Location | Issue | Impact | Fix |
|---|----------|-------|--------|-----|
| 1 | ... | ... | ... | ... |

### After Optimization
- [metric]: [new value] (XX% improvement)
```
