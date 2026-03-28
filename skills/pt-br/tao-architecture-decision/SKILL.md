---
name: tao-architecture-decision
description: "Registro de Decisão de Arquitetura (ADR) com matriz de análise de trade-offs e framework de avaliação. Use ao tomar decisões de arquitetura, escolher tecnologias ou documentar decisões de design."
argument-hint: "Descreva a decisão de arquitetura a avaliar"
---
# TAO Registros de Decisão de Arquitetura

## Quando usar
Use ao fazer escolhas de tecnologia, projetar arquitetura de sistema ou avaliar alternativas de design.

## Template ADR
```markdown
# ADR-NNN — [Título da Decisão]

**Data:** AAAA-MM-DD
**Status:** PROPOSTO | ACEITO | DEPRECIADO | SUBSTITUÍDO por ADR-XXX
**Decisores:** [quem participou]

## Contexto
[Qual é a questão? Quais forças estão em jogo?]

## Opções Consideradas

### Opção A — [Nome]
- **Prós:** ...
- **Contras:** ...
- **Custo:** ...

### Opção B — [Nome]
- **Prós:** ...
- **Contras:** ...
- **Custo:** ...

## Decisão
[Qual opção foi escolhida e POR QUÊ]

## Consequências
### Positivas
- ...
### Negativas
- ...
### Riscos
- ...
```

## Matriz de Trade-Off
Pontue cada opção de 1-5 em critérios ponderados:

| Critério | Peso | Opção A | Opção B | Opção C |
|----------|------|---------|---------|---------|
| Performance | 3 | 4 (12) | 3 (9) | 5 (15) |
| Manutenibilidade | 4 | 5 (20) | 3 (12) | 2 (8) |
| Expertise do time | 2 | 3 (6) | 5 (10) | 1 (2) |
| Custo | 3 | 4 (12) | 3 (9) | 2 (6) |
| **Total** | | **50** | **40** | **31** |

## Perguntas de Revisão
1. Isso escala para 10x a carga atual?
2. O que acontece quando este componente falha?
3. Podemos substituir sem reescrever?
4. Como monitoramos e debugamos em produção?
5. Qual o custo em escala? (compute, storage, licenças)
