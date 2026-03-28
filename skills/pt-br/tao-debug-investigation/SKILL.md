---
name: tao-debug-investigation
description: "Metodologia de debugging estruturada com investigação por hipóteses, isolamento sistemático e análise de causa raiz. Use ao debugar problemas, investigar erros ou troubleshooting de produção."
argument-hint: "Descreva o bug, mensagem de erro ou comportamento inesperado"
---
# TAO Investigação de Debug

## Quando usar
Use ao debugar problemas, investigar erros ou fazer troubleshooting.

## Protocolo de Investigação
```
1. OBSERVAR — Qual exatamente é o sintoma?
2. HIPOTETIZAR — O que poderia causar isso?
3. TESTAR — Como confirmamos/negamos?
4. ISOLAR — Onde exatamente está a falha?
5. CORRIGIR — Mudança mínima para resolver
6. VERIFICAR — A correção funciona? Alguma regressão?
```

## Passo 1: OBSERVAR
Colete fatos antes de teorizar:
- Qual a mensagem de erro exata?
- Quando começou? (depois de qual mudança?)
- É reproduzível? (sempre, às vezes, só em X?)
- Qual ambiente? (dev, staging, prod)
- Quem reportou? O que estavam fazendo?

## Passo 2: HIPOTETIZAR
Gere hipóteses ranqueadas por probabilidade:
- H1 (mais provável): [descrição]
- H2: [descrição]
- H3: [descrição]

## Passo 3: TESTAR
Para cada hipótese, projete um teste rápido:
- Consegue reproduzir com caso mínimo?
- Consegue adicionar logging no ponto suspeito?
- Mudar uma variável confirma/nega?

## Passo 4: ISOLAR
Estreite até a localização exata:
- **git bisect** — encontre o commit que introduziu o bug
- **Logging binário** — adicione logs no meio, estreite para metade
- **Dividir e conquistar** — comente seções até funcionar

## Passo 5: CORRIGIR
- Corrija a causa raiz, não o sintoma
- Mudança mínima (não refatore durante um fix)
- Escreva teste que reproduz o bug ANTES de corrigir

## Passo 6: VERIFICAR
- [ ] Bug original corrigido
- [ ] Teste de regressão passa
- [ ] Todos testes existentes ainda passam
- [ ] Correção funciona no mesmo ambiente onde o bug foi encontrado

## Anti-Padrões
- ❌ Mudar coisas aleatórias esperando funcionar
- ❌ Debugar sem reproduzir primeiro
- ❌ Corrigir sintomas ao invés de causa raiz
- ❌ "Fix" grande que muda muitas coisas
- ❌ Sem teste para o bug (vai regredir)
