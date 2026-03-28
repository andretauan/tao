---
applyTo: "**/routes/**,**/api/**,**/controllers/**,**/handlers/**,**/endpoints/**,**/routers/**,**/views.py"
---
# TAO API Standards — Auto-enforced on API files

## REST Conventions (mandatory)
- URLs: nouns (plural), lowercase, hyphens — `/order-items`, NOT `/getOrderItems`
- Methods: GET (read), POST (create), PUT (full update), PATCH (partial), DELETE (remove)
- No trailing slashes, no file extensions in URLs
- Nested resources: `/users/:id/orders`

## Status Codes (mandatory)
| Code | When |
|------|------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad request / validation error |
| 401 | Unauthorized (missing/invalid auth) |
| 403 | Forbidden (auth OK, no permission) |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity |
| 429 | Rate limit exceeded |

## Error Format (mandatory)
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "Description", "details": [] } }
```

## Security (mandatory on every endpoint)
- Validate ALL input at the boundary
- Check authorization BEFORE processing
- Rate limiting on public endpoints
- No sensitive data in URLs or logs
- Parameterized queries only

## Pagination (mandatory for list endpoints)
- Accept: `?page=N&per_page=N`
- Return: `{ "data": [], "meta": { "page", "per_page", "total", "pages" } }`
