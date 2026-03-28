# CLAUDE.md — Regras do Projeto | {{PROJECT_NAME}}

> **LEIA ESTE ARQUIVO ANTES DE QUALQUER AÇÃO.**
> Depois leia `.github/tao/RULES.md` para as regras completas do framework TAO.

---

## PROJETO

**{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}

**Configuração:** `.github/tao/tao.config.json` é a **fonte única de verdade** para configuração do projeto.

| Arquivo | Propósito |
|---------|-----------|
| `.github/tao/tao.config.json` | Configuração do projeto — caminhos, modelos, lint, branch, escopos |
| `.github/tao/RULES.md` | Regras do framework TAO — agentes, R0-R7, ABEX, travas de segurança |
| `.github/tao/CONTEXT.md` | Estado atual — fase ativa, decisões, arquivos tocados |
| `.github/tao/CHANGELOG.md` | Histórico — o que mudou, quando, por quem |
| `.github/tao/phases/` | Templates de fases |
| `.github/skills/` | Biblioteca de skills (opcional) |
| `.github/agents/` | Definições de agentes |

---

## LEITURA OBRIGATÓRIA (ordem)

1. `CLAUDE.md` (este arquivo) — identidade do projeto + padrões de código
2. `.github/tao/RULES.md` — regras, protocolos e travas de segurança do TAO
3. `.github/tao/CONTEXT.md` — estado atual
4. `.github/tao/CHANGELOG.md` — últimas 5 entradas
5. `.github/tao/tao.config.json` — configuração do projeto
6. `.github/skills/INDEX.md` — skills aplicáveis (se existir)

---

## PADRÕES DE CÓDIGO

> Defina seus padrões de código específicos do projeto abaixo.
> Referência: `.github/tao/tao.config.json` → `lint_commands` para convenções por linguagem.

```
<!-- PADRÕES ESPECÍFICOS DO PROJETO -->
<!-- Adicione seus padrões de código, convenções de nomenclatura e práticas aqui. -->
<!-- Exemplos: -->
<!--   - SQL: sempre usar prepared statements                                     -->
<!--   - Output: sempre escapar com a função apropriada                           -->
<!--   - Auth: verificar permissões na primeira linha do handler                  -->
<!--   - Respostas de erro: usar formato consistente (helpers ok/error)           -->
```
