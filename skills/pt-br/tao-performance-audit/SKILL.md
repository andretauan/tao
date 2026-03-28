---
name: tao-performance-audit
description: "Metodologia de análise de performance com técnicas de profiling, identificação de gargalos e padrões de otimização. Use ao auditar performance, otimizar código lento ou planejar capacidade."
argument-hint: "Descreva o problema de performance ou área a otimizar"
---
# TAO Auditoria de Performance

## Quando usar
Use ao investigar endpoints lentos, alto uso de memória ou planejamento de capacidade.

## Protocolo de Auditoria
```
1. MEDIR — números de baseline (não adivinhe)
2. IDENTIFICAR — encontre o gargalo (não o sintoma)
3. OTIMIZAR — corrija o gargalo (apenas ele)
4. VERIFICAR — meça novamente (prove a melhoria)
```

## Padrões Comuns de Gargalo

### Banco de Dados
- **Queries N+1** — loop buscando registros relacionados um por um
  → Fix: JOIN ou eager loading
- **Full table scan** — índice faltando na cláusula WHERE
  → Fix: adicionar índice, verificar EXPLAIN
- **Overfetching** — SELECT * quando só precisa de 2 colunas
  → Fix: selecionar apenas colunas necessárias
- **Esgotamento de conexões** — sem pool ou pool muito pequeno
  → Fix: connection pooling com limites adequados

### Aplicação
- **I/O síncrono bloqueante** — esperando HTTP/DB na thread principal
  → Fix: async/await, filas de workers
- **Memory leaks** — caches sem limite, conexões não fechadas
  → Fix: caches com TTL, cleanup adequado
- **Computação desnecessária** — recalculando a cada request
  → Fix: caching (Redis, in-memory), memoização
- **Payload grande** — enviando 1MB JSON quando cliente precisa de 10 campos
  → Fix: seleção de campos, paginação, compressão

### Frontend
- **Tamanho do bundle** — importando biblioteca inteira para uma função
  → Fix: tree-shaking, imports dinâmicos
- **Render bloqueante** — scripts síncronos grandes
  → Fix: async/defer, code splitting

## Regras de Otimização
1. **Não adivinhe, meça** — profile antes de otimizar
2. **Otimize o gargalo** — speedup 10x no não-gargalo = 0% melhoria
3. **Simples primeiro** — caching, indexação, batching antes de redesenho
4. **Defina metas** — "resposta abaixo de 200ms" não "faça mais rápido"
5. **Benchmark antes e depois** — prove a melhoria com números

## Formato de Saída
```
## Auditoria de Performance — [escopo]
**Data:** AAAA-MM-DD

### Baseline
- [métrica]: [valor atual]

### Análise de Gargalos
| # | Local | Problema | Impacto | Correção |
|---|-------|----------|---------|----------|
| 1 | ... | ... | ... | ... |

### Após Otimização
- [métrica]: [novo valor] (XX% melhoria)
```
