---
name: tao-refactoring
description: "Metodologia de refatoração segura com detecção de code smells, transformação passo-a-passo e prevenção de regressão. Use ao refatorar código, reduzir dívida técnica ou melhorar estrutura."
argument-hint: "Descreva o código a refatorar ou o smell a corrigir"
---
# TAO Refatoração Segura

## Quando usar
Use ao refatorar código, reduzir dívida técnica ou reestruturar módulos.

## Checklist Pré-Voo
Antes de QUALQUER refatoração:
- [ ] Testes existem para o código sendo alterado (se não, escreva primeiro)
- [ ] Testes atuais passam (baseline)
- [ ] Escopo definido (o que muda, o que não muda)
- [ ] git status limpo (commite antes de começar)

## Code Smells Comuns & Correções

### Smell: Função Longa (> 30 linhas)
**Correção:** Extract Method
1. Identifique um bloco coeso de código
2. Extraia em uma função nomeada
3. Passe apenas parâmetros necessários
4. Rode testes

### Smell: Nesting Profundo (> 3 níveis)
**Correção:** Guard Clauses / Early Returns

### Smell: Código Duplicado
**Correção:** Extraia lógica compartilhada em uma função
Só extraia quando a lógica é IDÊNTICA — similar ≠ duplicado

### Smell: Obsessão por Primitivos
**Correção:** Crie value objects ou enums

### Smell: God Class (classe fazendo coisas demais)
**Correção:** Divida em classes focadas com responsabilidade única

### Smell: Feature Envy (método usando dados de outra classe)
**Correção:** Mova o método para a classe dona dos dados

## Protocolo de Segurança
1. **Passos pequenos** — uma transformação por vez
2. **Testar após cada passo** — não agrupe múltiplas mudanças
3. **Sem mudanças de comportamento** — refatoração ≠ adicionar features
4. **Commitar frequentemente** — cada passo tem seu commit

## Red Flags — PARE a Refatoração
- Testes falhando → reverta última mudança
- Escopo crescendo → commite o que tem, planeje o restante como nova tarefa
- Adicionando features → isso não é refatoração, faça tarefa separada
