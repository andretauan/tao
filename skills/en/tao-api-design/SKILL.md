---
name: tao-api-design
description: "RESTful API design conventions including endpoint naming, HTTP methods, status codes, pagination, error handling, and versioning patterns. Use when designing APIs, creating endpoints, or reviewing API contracts."
user-invocable: false
---
# TAO API Design Guide

## When to use
Use when designing REST APIs, defining endpoint contracts, or reviewing API consistency.

## URL Convention
```
GET    /api/v1/users          # List (collection)
POST   /api/v1/users          # Create
GET    /api/v1/users/:id      # Read (single)
PUT    /api/v1/users/:id      # Full update
PATCH  /api/v1/users/:id      # Partial update
DELETE /api/v1/users/:id      # Delete
GET    /api/v1/users/:id/orders  # Nested resource
```

**Rules:**
- Nouns (plural), not verbs: `/users`, NOT `/getUsers`
- Lowercase, hyphens: `/order-items`, NOT `/orderItems`
- No trailing slashes
- No file extensions in URLs

## HTTP Status Codes
| Code | When |
|------|------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad request (validation error) |
| 401 | Unauthorized (no/invalid auth) |
| 403 | Forbidden (auth OK, no permission) |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity (semantic error) |
| 429 | Too many requests (rate limit) |
| 500 | Internal server error |

## Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "issue": "required" }
    ]
  }
}
```

## Pagination
```
GET /api/v1/users?page=2&per_page=20

Response headers:
X-Total-Count: 150
Link: <...?page=3>; rel="next", <...?page=1>; rel="prev"

Response body:
{
  "data": [...],
  "meta": { "page": 2, "per_page": 20, "total": 150, "pages": 8 }
}
```

## Filtering, Sorting, Search
```
GET /api/v1/users?status=active&role=admin    # Filter
GET /api/v1/users?sort=-created_at,name       # Sort (- = desc)
GET /api/v1/users?q=john                      # Search
```

## Versioning
- URL path: `/api/v1/users` (recommended)
- Header: `Accept: application/vnd.api+json;version=1`
- Never break existing clients — add, don't change

## Security Checklist
- [ ] Authentication on all non-public endpoints
- [ ] Rate limiting per client/IP
- [ ] Input validation + sanitization
- [ ] No sensitive data in URLs (use body/headers)
- [ ] CORS configured correctly
