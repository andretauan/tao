---
name: tao-test-strategy
description: "Estratégia de pirâmide de testes com análise de cobertura, identificação de edge cases e planejamento de testes. Use ao planejar testes, melhorar cobertura, identificar edge cases ou escrever especificações de teste."
user-invocable: false
---
# TAO Estratégia de Testes

## Quando usar
Use ao planejar testes, escrever specs, melhorar cobertura ou identificar edge cases.

## Pirâmide de Testes
```
        ╱╲
       ╱ E2E ╲         Poucos (fluxos críticos do usuário)
      ╱────────╲
     ╱Integração╲      Médio (fronteiras API/serviço)
    ╱──────────────╲
   ╱  Testes Unitários╲ Muitos (funções puras, lógica de negócio)
  ╱════════════════════╲
```

## Metas de Cobertura
| Camada | Meta | Foco |
|--------|------|------|
| Unitário | 80%+ | Lógica de negócio, cálculos, transformações |
| Integração | Caminhos-chave | Endpoints API, queries DB, serviços externos |
| E2E | Fluxos críticos | Login, checkout, submissão de dados |

## Padrões de Edge Case
Sempre teste estas categorias:
1. **Vazio/null** — null, undefined, string vazia, array vazio, 0
2. **Fronteira** — min-1, min, max, max+1, negativo
3. **Coerção de tipo** — string onde número esperado, booleanos
4. **Unicode** — acentos, emojis, texto RTL, strings muito longas
5. **Concorrência** — requests simultâneos, condições de corrida
6. **Estado** — primeiro uso, uso repetido, após erro, após timeout

## Estrutura do Teste (AAA)
```
// Arrange — preparar dados e contexto
// Act — executar o código sob teste
// Assert — verificar o resultado esperado
```

## Convenção de Nomes
`[unidade]_[cenario]_[resultado_esperado]`
- `criarUsuario_comEmailValido_retornaUserId`
- `criarUsuario_comEmailDuplicado_lancaErroConflito`
- `buscarPedido_comIdInvalido_retorna404`

## Anti-Padrões
- ❌ Testar detalhes de implementação (testes frágeis)
- ❌ Estado mutável compartilhado entre testes
- ❌ Testes dependentes de ordem de execução
- ❌ Muitas assertions em um teste
- ❌ Mockar tudo (não testa nada real)
- ❌ Sem assertions (teste "passa" mas não verifica nada)

## Quando Escrever Testes
- Feature nova → testes no mesmo PR
- Bug fix → escreva teste que reproduz o bug PRIMEIRO, depois corrija
- Refactor → garanta que testes existem ANTES de refatorar
