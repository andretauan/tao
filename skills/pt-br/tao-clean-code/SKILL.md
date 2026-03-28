---
name: tao-clean-code
description: "Princípios de clean code incluindo SOLID, DRY, KISS, convenções de nomenclatura, design de funções e gestão de complexidade. Use ao escrever código novo, revisar qualidade ou estabelecer padrões de código."
user-invocable: false
---
# TAO Princípios de Código Limpo

## Quando usar
Auto-carregado como conhecimento de fundo para toda escrita e revisão de código.

## Princípios Fundamentais

### SOLID
- **S**ingle Responsibility — uma razão para mudar por classe/módulo
- **O**pen/Closed — aberto para extensão, fechado para modificação
- **L**iskov Substitution — subtipos substituíveis pelos tipos base
- **I**nterface Segregation — muitas interfaces específicas > uma geral
- **D**ependency Inversion — dependa de abstrações, não de concretos

### DRY (Não Se Repita)
LÓGICA duplicada (não apenas código similar) deve ser extraída.
MAS: abstração prematura é pior que duplicação. Regra de três: tolere uma vez, note duas, extraia na terceira.

### KISS (Mantenha Simples)
- Prefira soluções simples a soluções espertas
- Se um dev junior não entende em 5 minutos, simplifique
- Sem otimização prematura

### YAGNI (Você Não Vai Precisar Disso)
- Não construa para requisitos hipotéticos futuros
- A abstração certa é o mínimo para a tarefa atual

## Convenções de Nomenclatura
| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Função | verbo + substantivo | `buscarUsuarioPorId()`, `calcularTotal()` |
| Booleano | é/tem/pode prefixo | `estaAtivo`, `temPermissao` |
| Constante | UPPER_SNAKE | `MAX_TENTATIVAS`, `API_TIMEOUT` |
| Classe | PascalCase substantivo | `ServicoUsuario`, `RepositorioPedido` |
| Variável | substantivo descritivo | `usuariosAtivos`, `totalValor` |

## Design de Funções
- **Máx parâmetros: 3** — use objeto/struct se precisar mais
- **Máx linhas: ~30** — extraia se for maior
- **Máx nesting: 3** — use early returns
- **Nível único de abstração** — não misture orquestração alto-nível com detalhes baixo-nível
- **Efeitos colaterais: declare no nome** — `salvarUsuario()` vs `buscarUsuario()`

## Tratamento de Erros
- Trate erros na fronteira, não em cada nível
- Use padrões idiomáticos da linguagem
- Nunca engula erros silenciosamente
- Logue com contexto: o que aconteceu, o que era esperado, qual input causou
