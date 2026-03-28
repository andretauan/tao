---
name: tao-git-workflow
description: "Workflow git compatível com TAO com mensagens de commit convencionais, estratégia de branches e checklist de PR. Auto-carregado para todas as operações git."
user-invocable: false
---
# TAO Workflow Git

## Quando usar
Auto-carregado para todas operações git: commits, branches, PRs.

## Formato de Mensagem de Commit (TAO)
```
tipo(fase-XX): TNN — descrição curta
```

**Tipos:**
| Tipo | Quando |
|------|--------|
| feat | Nova feature |
| fix | Correção de bug |
| refactor | Reestruturação (sem mudança de comportamento) |
| test | Adicionar/atualizar testes |
| docs | Apenas documentação |
| chore | Build, config, ferramentas |
| style | Formatação, espaços |

**Regras:**
- 1 commit = 1 tarefa
- Linha de assunto ≤ 72 caracteres
- Modo imperativo: "adicionar feature", NÃO "adicionei feature"
- Referência fase e tarefa: `feat(fase-01): T03 — adicionar autenticação`

## Estratégia de Branches
```
main ─────────────────────────── produção (protegido)
  └─ dev ─────────────────────── integração
       ├─ feature/fase-01-auth    branches de tarefa (opcional)
       └─ fix/fase-02-t05-null    branches de correção (opcional)
```

**Regras:**
- Trabalhe em `dev` (ou branch do tao.config.json → git.dev_branch)
- NUNCA push direto na `main`
- NUNCA `git push --force`
- NUNCA `git reset --hard`

## Checklist Pré-Commit
- [ ] Lint passa (R1)
- [ ] Testes passam
- [ ] CONTEXT.md atualizado (R6)
- [ ] Sem secrets nos arquivos staged
- [ ] Sem mudanças não relacionadas (uma tarefa por commit)

## Template de Descrição de PR
```markdown
## O quê
[Breve descrição das mudanças]

## Por quê
[Motivação — referência da tarefa]

## Como
[Abordagem de implementação]

## Testes
[Como verificar]

## Checklist
- [ ] Testes passam
- [ ] Lint passa
- [ ] CONTEXT.md atualizado
- [ ] CHANGELOG.md atualizado
```
