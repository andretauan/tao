# Índice de Skills

> Catálogo auto-gerado de skills disponíveis. Agentes TAO consultam este arquivo antes de tarefas de código (R3).
> VS Code também descobre skills automaticamente de `.github/skills/*/SKILL.md`.

## Como Identificar Skills (Algoritmo R3)

Ao editar um arquivo, verifique quais skills se aplicam:

1. **Sempre ativas** (toda tarefa de código): `tao-clean-code`, `tao-security-audit`, `tao-code-review`, `tao-git-workflow`
2. **Por extensão do arquivo**: relacione o arquivo que você vai editar com os padrões applyTo da instrução:
   - `.test.{js,ts,py}` ou `/tests/` → `tao-test-strategy`
   - Rotas/controllers/handlers → `tao-api-design`
   - `.sql` / migrations / models → `tao-database-design`
3. **Por tipo de tarefa**: relacione com a descrição da tarefa:
   - Refatoração mencionada → `tao-refactoring`
   - Investigação de bug → `tao-debug-investigation`
   - Trabalho de performance → `tao-performance-audit`
   - Decisão de arquitetura → `tao-architecture-decision`
   - Planejamento → `tao-plan-writing`
   - Brainstorming → `tao-brainstorm`

Liste todas as skills identificadas no compliance check.

---

## Skills TAO (built-in)

| Skill | Tipo | Descrição |
|-------|------|-----------|
| `tao-api-design` | slash + auto | Convenções de design de API RESTful incluindo nomenclatura de endpoints, métodos HTTP, status codes, paginação, tratamento de erros e padrões de versionamento. Use ao projetar APIs, criar endpoints ou revisar contratos. |
| `tao-architecture-decision` | slash + auto | Registro de Decisão de Arquitetura (ADR) com matriz de análise de trade-offs e framework de avaliação. Use ao tomar decisões de arquitetura, escolher tecnologias ou documentar decisões de design. |
| `tao-brainstorm` | auto-load | Metodologia de brainstorming baseada em IBIS com análise estruturada de questão-posição-argumento e pontuação de maturidade. Use ao fazer brainstorm, avaliar ideias ou escrever BRIEF.md. |
| `tao-clean-code` | auto-load | Princípios de clean code incluindo SOLID, DRY, KISS, convenções de nomenclatura, design de funções e gestão de complexidade. Use ao escrever código novo, revisar qualidade ou estabelecer padrões de código. |
| `tao-code-review` | slash + auto | Code review estruturado em 6 eixos cobrindo corretude, segurança, performance, legibilidade, testes e padrões. Use ao revisar código, fazer reviews de PR ou verificar qualidade. |
| `tao-database-design` | slash + auto | Design de schema de banco de dados com normalização, estratégia de indexação, planejamento de migrations e padrões de constraints. Use ao projetar schemas, planejar migrations, otimizar queries ou revisar modelos de dados. |
| `tao-debug-investigation` | slash + auto | Metodologia de debugging estruturada com investigação por hipóteses, isolamento sistemático e análise de causa raiz. Use ao debugar problemas, investigar erros ou troubleshooting de produção. |
| `tao-git-workflow` | auto-load | Workflow git compatível com TAO com mensagens de commit convencionais, estratégia de branches e checklist de PR. Auto-carregado para todas as operações git. |
| `tao-onboarding` | slash + auto | Guia novos usuários pelo setup do TAO, conceitos e primeira execução. Use quando alguém perguntar sobre o TAO, como começar, ou precisar de ajuda com o workflow. |
| `tao-performance-audit` | slash + auto | Metodologia de análise de performance com técnicas de profiling, identificação de gargalos e padrões de otimização. Use ao auditar performance, otimizar código lento ou planejar capacidade. |
| `tao-plan-writing` | auto-load | Decomposição expert de tarefas para criar PLAN.md no TAO. Quebra features em fases e tarefas com critérios de aceite, estimativas e dependências. Use ao planejar trabalho, criar fases ou decompor features. |
| `tao-refactoring` | slash + auto | Metodologia de refatoração segura com detecção de code smells, transformação passo-a-passo e prevenção de regressão. Use ao refatorar código, reduzir dívida técnica ou melhorar estrutura. |
| `tao-security-audit` | slash + auto | Auditoria de segurança alinhada ao OWASP Top 10 com checklist para injection, XSS, autenticação, autorização, gestão de secrets e vulnerabilidades comuns. Use ao auditar segurança, revisar código de auth ou hardening de aplicação. |
| `tao-test-strategy` | slash + auto | Estratégia de pirâmide de testes com análise de cobertura, identificação de edge cases e planejamento de testes. Use ao planejar testes, melhorar cobertura, identificar edge cases ou escrever especificações de teste. |

## Skills do Usuário

> Adicione suas próprias skills abaixo. Crie uma pasta em `.github/skills/` com um arquivo `SKILL.md`.
> Veja [agentskills.io](https://agentskills.io) para a especificação.

| Skill | Tipo | Descrição |
|-------|------|-----------|
| *(adicione suas skills aqui)* | | |
