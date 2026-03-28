# GitHub Copilot — Instruções Base | {{PROJECT_NAME}}
# Lido automaticamente em TODA sessão. Para loop TAO completo → usar agente @Executar-Tao.

## IDENTIDADE

Você é um agente do projeto **{{PROJECT_NAME}}** — {{PROJECT_DESCRIPTION}}.
Para executar tarefas TAO (trigger "executar"/"continuar"), use o agente **@Executar-Tao** no chat.

---

## LEITURA OBRIGATÓRIA (toda sessão que modifica código)

1. Ler `CLAUDE.md` — regras invioláveis
2. Ler `.github/tao/CONTEXT.md` — fase ativa + decisões travadas
3. Consultar `.github/tao/CHANGELOG.md` — últimas 3 entradas
4. Consultar `.github/skills/INDEX.md` — identificar skills aplicáveis (se existir)

---

## REGRAS INVIOLÁVEIS (resumo — detalhes em CLAUDE.md)

| # | Regra |
|---|-------|
| R0 | Compliance check no início de toda resposta que modifica código |
| R1 | Verificação de syntax/lint após toda edição (ler .github/tao/tao.config.json → lint_commands) |
| R2 | Handoff = prompt de auditoria, não continuação cega |
| R3 | Consulta de skills antes de qualquer código (se skills existirem) |
| R4 | Timestamp em toda documentação: YYYY-MM-DD HH:MM |
| R5 | NUNCA editar arquivo sem ler primeiro |
| R6 | Atualizar .github/tao/CONTEXT.md após toda edição |
| R7 | Sessão deve encerrar com `git status` limpo |

---

## AGENTES DISPONÍVEIS

| Agente | Uso |
|--------|-----|
| **@Executar-Tao** | Loop TAO completo — seleciona tarefas, roteia modelos, commita automaticamente |
| **@Investigar-Shen** | Decisões arquiteturais, debugging difícil, auditoria de segurança |
| **@Brainstorm-Wu** | Brainstorming, planejamento, avaliação de trade-offs |

---

## SEGURANÇA

> Adapte para a stack do projeto. Estes são requisitos universais.

- NUNCA exibir dados do usuário sem sanitização
- SQL: queries parametrizadas APENAS — zero concatenação
- Uploads: validar MIME real
- Secrets: variáveis de ambiente apenas (`.env`) — nunca hardcode
- Auth: verificar permissão antes de acessar dado sensível
- Validação de input em fronteiras do sistema

---

## TRAVAS DE SEGURANÇA

### LOCK 1 — ESCOPO
Agente pode APENAS modificar arquivos do projeto.
**PROIBIDO sem aprovação:** `CLAUDE.md`, `.github/instructions/tao.instructions.md`, `.github/workflows/`, `vendor/`, `node_modules/`, `venv/`, `.env`

### LOCK 2 — BRANCH
- Trabalhar SOMENTE em `dev` (ou branch definida em .github/tao/tao.config.json → git.dev_branch)
- NUNCA `git push origin main`
- NUNCA `git push --force`
- NUNCA `git reset --hard`

### LOCK 3 — DESTRUTIVOS
NUNCA: `rm -rf`, `DROP TABLE/DATABASE`, `TRUNCATE`, `DELETE FROM` sem WHERE

### LOCK 4 — SCHEMA
Qualquer operação que altera schema → STOP → documentar SQL → registrar como checkpoint

### LOCK 5 — PAUSE
Se `.tao-pause` existir na raiz → **STOP IMEDIATO**

### LOCK 6 — COMMIT
- NUNCA commitar sem quality gates passando
- NUNCA commitar com `--no-verify`
- Mensagem: `tipo(fase-XX): TNN — descrição curta`
- 1 commit = 1 tarefa

---

## COMPLIANCE CHECK

Toda resposta que modifique código DEVE começar com:

```
📋 COMPLIANCE CHECK
├─ Skills consultadas: [lista ou "nenhuma aplicável"]
├─ Arquivos lidos antes de editar: [lista]
├─ .github/tao/CONTEXT.md lido: SIM
├─ .github/tao/CHANGELOG.md consultado: SIM
└─ ABEX: [PASSA / N/A]
```
