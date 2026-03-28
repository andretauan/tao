---
name: tao-database-design
description: "Design de schema de banco de dados com normalização, estratégia de indexação, planejamento de migrations e padrões de constraints. Use ao projetar schemas, planejar migrations, otimizar queries ou revisar modelos de dados."
user-invocable: false
---
# TAO Design de Banco de Dados

## Quando usar
Use ao projetar schemas, planejar migrations, otimizar queries ou revisar modelos de dados.

## Princípios de Design
1. **Normalize primeiro** — desnormalize só com prova de necessidade de performance
2. **Nomeie consistentemente** — snake_case, tabelas no plural, colunas no singular
3. **Toda tabela tem:** id (PK), created_at, updated_at
4. **Foreign keys NÃO são opcionais** — integridade referencial importa
5. **Soft delete** — adicione `deleted_at` ao invés de DELETE real quando dados são valiosos

## Convenções de Nomenclatura
| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Tabela | plural, snake_case | `itens_pedido` |
| Coluna | singular, snake_case | `valor_total` |
| Chave primária | `id` | `id` |
| Chave estrangeira | `{tabela_singular}_id` | `usuario_id` |
| Índice | `idx_{tabela}_{colunas}` | `idx_usuarios_email` |
| Booleano | is_/has_ prefixo | `is_ativo`, `has_verificado` |
| Timestamp | sufixo _at | `created_at`, `publicado_at` |

## Estratégia de Índices
- **Chave primária** — automático (sempre indexado)
- **Chaves estrangeiras** — SEMPRE indexe (joins dependem)
- **Colunas de WHERE** — indexe colunas frequentemente filtradas
- **Constraints únicos** — combine com índice
- **Índices compostos** — ordem importa: coluna mais seletiva primeiro
- **NÃO sobre-indexe** — cada índice desacelera escritas

## Checklist de Migration Segura
- [ ] Migration é reversível (tem método `down`)
- [ ] Sem perda de dados (backup antes de mudanças destrutivas)
- [ ] Mudanças em tabelas grandes são em batch
- [ ] Testado em cópia de dados de produção
- [ ] Compatível com zero-downtime

## Anti-Padrões
- ❌ `SELECT *` — sempre especifique colunas
- ❌ Queries N+1 — use JOINs ou eager loading
- ❌ Lógica de negócio em triggers
- ❌ Sem índices em chaves estrangeiras
- ❌ VARCHAR(255) como padrão
- ❌ Armazenar JSON para dados estruturados e consultáveis
