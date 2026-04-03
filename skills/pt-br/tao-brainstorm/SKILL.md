---
name: tao-brainstorm
description: "Metodologia de brainstorming baseada em IBIS com análise estruturada de questão-posição-argumento e pontuação de maturidade. Use ao fazer brainstorm, avaliar ideias ou escrever BRIEF.md."
user-invocable: false
---
# TAO Brainstorm (Método IBIS)

## Quando usar
Auto-carregado durante sessões de brainstorm, criação de BRIEF.md e avaliação de ideias.

## Framework IBIS
Issue-Based Information System (IBIS) estrutura a discussão em:
- **Issues (Questões)** — Perguntas ou problemas a resolver
- **Positions (Posições)** — Respostas ou abordagens possíveis
- **Arguments (Argumentos)** — Prós e contras de cada posição

## Estrutura do BRIEF.md
```markdown
# BRIEF — [Tópico]

## Questão
[Declaração clara do problema ou decisão]

## Posições

### Posição A — [Nome]
**Argumentos a favor:**
- Pró 1
- Pró 2

**Argumentos contra:**
- Contra 1

### Posição B — [Nome]
**Argumentos a favor:**
- Pró 1

**Argumentos contra:**
- Contra 1
- Contra 2

## Decisão
[Posição selecionada com justificativa]

## Pontuação de Maturidade
[X/7] — veja critérios abaixo
```

## Portão de Maturidade (7 critérios)
Marque 1 ponto para cada:
1. ✅ Problema/objetivo está claro (DISCOVERY tem seção "Problema Central" definida)
2. ✅ Alternativas foram exploradas (≥ 2 abordagens significativamente diferentes registradas)
3. ✅ Trade-offs foram avaliados (≥ 1 issue IBIS em DECISIONS com positions + arguments)
4. ✅ Decisões têm condição de invalidação (toda decisão tem "Invalidaria se")
5. ✅ Documentos de referência relevantes consultados (registrado em DISCOVERY §Referências)
6. ✅ Escopo está definido (o que ENTRA e o que NÃO entra explicitamente declarados)
7. ✅ Padrões do codebase existente considerados (padrões do progress.txt da fase anterior integrados)

**Mínimo para prosseguir: 5/7**

## Anti-Padrões de Brainstorm
- ❌ Brainstorm de posição única (já decidiu antes de pensar)
- ❌ Só prós, sem contras (viés de confirmação)
- ❌ Avaliação só técnica (ignorando manutenção, custo, skills do time)
- ❌ Paralisia de análise (posições demais, sem convergência)

## Sinais de Convergência
Passe do brainstorm para o plano quando:
- Uma posição domina claramente nos critérios ponderados
- Existe alinhamento do time/stakeholders
- Riscos são compreendidos e mitigáveis
- Viabilidade técnica está confirmada
