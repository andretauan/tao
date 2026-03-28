---
name: tao-api-design
description: "Convenções de design de API RESTful incluindo nomenclatura de endpoints, métodos HTTP, status codes, paginação, tratamento de erros e padrões de versionamento. Use ao projetar APIs, criar endpoints ou revisar contratos."
argument-hint: "Descreva o recurso ou endpoint da API a projetar"
---
# TAO Guia de Design de API

## Quando usar
Use ao projetar APIs REST, definir contratos de endpoint ou revisar consistência de API.

## Convenção de URLs
```
GET    /api/v1/users          # Listar (coleção)
POST   /api/v1/users          # Criar
GET    /api/v1/users/:id      # Ler (único)
PUT    /api/v1/users/:id      # Update completo
PATCH  /api/v1/users/:id      # Update parcial
DELETE /api/v1/users/:id      # Deletar
GET    /api/v1/users/:id/orders  # Recurso aninhado
```

**Regras:**
- Substantivos (plural), não verbos: `/users`, NÃO `/getUsers`
- Minúsculas, hífens: `/order-items`, NÃO `/orderItems`
- Sem barras finais
- Sem extensões de arquivo nas URLs

## HTTP Status Codes
| Código | Quando |
|--------|--------|
| 200 | Sucesso (GET, PUT, PATCH) |
| 201 | Criado (POST) |
| 204 | Sem conteúdo (DELETE) |
| 400 | Request ruim (erro de validação) |
| 401 | Não autorizado (sem auth/auth inválido) |
| 403 | Proibido (auth OK, sem permissão) |
| 404 | Não encontrado |
| 409 | Conflito (duplicado) |
| 422 | Entidade não processável |
| 429 | Muitas requests (rate limit) |
| 500 | Erro interno do servidor |

## Formato de Resposta de Erro
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email é obrigatório",
    "details": [
      { "field": "email", "issue": "required" }
    ]
  }
}
```

## Paginação
```
GET /api/v1/users?page=2&per_page=20

Headers de resposta:
X-Total-Count: 150

Body:
{
  "data": [...],
  "meta": { "page": 2, "per_page": 20, "total": 150, "pages": 8 }
}
```

## Filtros, Ordenação, Busca
```
GET /api/v1/users?status=active&role=admin    # Filtro
GET /api/v1/users?sort=-created_at,name       # Ordenação (- = desc)
GET /api/v1/users?q=john                      # Busca
```

## Segurança
- [ ] Autenticação em todos endpoints não-públicos
- [ ] Rate limiting por cliente/IP
- [ ] Validação + sanitização de input
- [ ] Sem dados sensíveis nas URLs
- [ ] CORS configurado corretamente
