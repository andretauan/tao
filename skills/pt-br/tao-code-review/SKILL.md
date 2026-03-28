---
name: tao-code-review
description: "Code review estruturado em 6 eixos cobrindo corretude, segurança, performance, legibilidade, testes e padrões. Use ao revisar código, fazer reviews de PR ou verificar qualidade."
user-invocable: false
---
# TAO Code Review (6 Eixos)

## Quando usar
Use para code reviews, reviews de PR ou verificações de qualidade em qualquer modificação de código.

## Os 6 Eixos

### Eixo 1 — Corretude
- O código faz o que diz?
- Casos extremos tratados? (null, vazio, valores de fronteira)
- Caminhos de erro corretos? (try/catch, fallbacks, propagação de erros)
- Condições de corrida possíveis? (async, concorrência, estado compartilhado)

### Eixo 2 — Segurança
- Validação de input nas fronteiras do sistema?
- SQL injection: apenas queries parametrizadas?
- XSS: encoding/sanitização de output?
- Autenticação: permissões verificadas antes do acesso a dados?
- Secrets: sem credenciais hardcoded? (apenas .env)
- Upload de arquivos: validação real de MIME type?

### Eixo 3 — Performance
- Queries N+1? (busca em batch)
- Loops dentro de loops desnecessários? (O(n²) → O(n))
- Listas sem limite? (paginação, limites)
- Indexes faltando em colunas frequentemente consultadas?
- Memory leaks? (conexões não fechadas, listeners)

### Eixo 4 — Legibilidade
- Nomes claros? (funções = verbos, variáveis = substantivos)
- Funções com ~30 linhas?
- Profundidade de nesting ≤ 3? (early returns, guard clauses)
- Sem números mágicos? (constantes nomeadas)
- Comentários explicam POR QUÊ, não O QUÊ?

### Eixo 5 — Testes
- Novas features estão testadas?
- Casos extremos cobertos?
- Testes são independentes? (sem estado mutável compartilhado)
- Assertions são específicos? (não apenas "sem erro")
- Cobertura adequada para caminhos críticos?

### Eixo 6 — Padrões
- Consistente com convenções do projeto? (ler CLAUDE.md)
- Sem abstrações desnecessárias para código único?
- Tratamento de erro segue o padrão do projeto?
- Estrutura de arquivos segue convenções do projeto?

## Formato de Saída
```
## Code Review — [arquivo/feature]

### ✅ Aprovado
- [eixo]: [o que está bom]

### ⚠️ Sugestões
- [eixo]: [melhoria com justificativa]

### 🚫 Bloqueadores
- [eixo]: [deve corrigir antes do merge]

### Veredicto: APROVAR | SOLICITAR MUDANÇAS | COMENTAR
```

## Etiqueta de Review
- Seja específico: "linha 42: faltando null check" > "trate erros melhor"
- Sugira soluções, não apenas problemas
- Distinga nitpicks de bloqueadores
- Reconheça código bom, não apenas ruim
