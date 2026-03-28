---
name: tao-onboarding
description: "Guia novos usuários pelo setup do TAO, conceitos e primeira execução. Use quando alguém perguntar sobre o TAO, como começar, ou precisar de ajuda com o workflow."
argument-hint: "Descreva o que precisa de ajuda no TAO"
---
# Guia de Onboarding TAO

## Quando usar esta skill
Use quando alguém é novo no TAO, pergunta como funciona, ou precisa configurar seu primeiro projeto.

## O que é TAO?
TAO (Trace · Align · Operate) é um framework de desenvolvimento AI-nativo que organiza a codificação com agentes de IA em três camadas:
- **Trace (Pensar)** — Brainstorm de ideias, avaliar trade-offs, tomar decisões
- **Align (Planejar)** — Decompor trabalho em fases com tarefas, critérios de aceite e estimativas
- **Operate (Executar)** — Executar tarefas em loop autônomo com quality gates

## Arquivos Principais
| Arquivo | Propósito |
|---------|-----------|
| `CLAUDE.md` | Identidade do projeto + padrões de código (raiz) |
| `.github/tao/tao.config.json` | Fonte única de verdade para config |
| `.github/tao/CONTEXT.md` | Estado atual — fase ativa, decisões |
| `.github/tao/CHANGELOG.md` | Histórico — o que mudou, quando, por quem |
| `.github/tao/RULES.md` | Regras do framework (R0-R7) |
| `.github/skills/INDEX.md` | Catálogo de skills (se existir) |
| `.github/agents/*.agent.md` | Definições dos agentes |

## Checklist da Primeira Execução
1. Revise `.github/tao/tao.config.json` — personalize modelos, caminhos, lint
2. Edite `CLAUDE.md` — adicione regras e padrões de código do projeto
3. Defina a primeira fase em `.github/tao/CONTEXT.md`
4. Ative `chat.useCustomAgentHooks` nas Configurações do VS Code
5. No Copilot Chat: selecione `@Executar-Tao` e diga "executar"

## O Loop
```
@Executar-Tao → lê CONTEXT.md → encontra fase ativa
  → lê PLAN.md → pega próxima tarefa
  → roteia para modelo certo (Sonnet/Opus/GPT-4.1)
  → executa tarefa → roda lint → atualiza CONTEXT.md
  → commita → pega próxima tarefa → repete
```

## Agentes
| Agente | Quando usar |
|--------|-------------|
| `@Executar-Tao` | Loop de execução autônomo completo |
| `@Brainstorm-Wu` | Planejamento, ideação, análise de trade-offs |
| `@Investigar-Shen` | Debug complexo, decisões de arquitetura, auditorias de segurança |

## Regras (R0-R7)
- **R0**: Compliance check no início de toda resposta que modifica código
- **R1**: Verificação de lint após cada edição
- **R2**: Auditoria de handoff no fim da sessão
- **R3**: Verificação de skills antes de qualquer tarefa de código
- **R4**: Timestamp em toda documentação (AAAA-MM-DD HH:MM)
- **R5**: NUNCA editar sem ler antes
- **R6**: Atualizar CONTEXT.md após cada edição de arquivo
- **R7**: Sessão deve terminar com git status limpo
