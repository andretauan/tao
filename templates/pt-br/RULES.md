# TAO (道) — Regras & Protocolos dos Agentes
# Trace · Align · Operate — Framework de desenvolvimento AI-nativo
# Este arquivo é gerenciado pelo TAO. Será sobrescrito em atualizações.
# Para regras específicas do projeto → editar CLAUDE.md na raiz do projeto.

---

## HIERARQUIA DE AGENTES

Este projeto usa o **sistema de agentes TAO (道)** — Trace · Align · Operate.
Roteamento automático: Sonnet (1x) para trabalho rotineiro, Opus (3x) para decisões complexas, tier grátis para BD/deploy.

| Agente | Símbolo | Modelo | Papel |
|--------|---------|--------|-------|
| **Tao** | 道 | Sonnet | Orquestrador — loop de tarefas, roteamento automático |
| **Shen** | 深 | Opus | Worker Complexo — subagent invocado pelo Tao para tarefas difíceis |
| **Investigar-Shen** | 深 | Opus | Arquiteto — invocável pelo usuário, acesso direto fora do loop |
| **Wu** | 悟 | Opus | Brainstorm/Planejamento — ideação, trade-offs, síntese |
| **Di** | 地 | Tier grátis | DBA — migrations, schema, otimização de queries |
| **Qi** | 气 | Tier grátis | Deploy — operações git, CI/CD, sync de ambientes |

**Detalhes:** Consultar `.github/agents/` para definições completas e protocolos de cada agente.

### Matriz de Escalação

| Atividade | Modelo | Justificativa |
|-----------|--------|---------------|
| CRUD, views, CSS, correções rotineiras | **Sonnet** | Mecânico — seguir instruções claras |
| Executar plano validado | **Sonnet** | Plano já decidido pelo Opus |
| Docs, changelog, formatação | **Sonnet** | Transcrição, não julgamento |
| Decisões arquiteturais | **Opus** | Exige raciocínio sistêmico |
| Código de segurança crítica | **Opus** | Tolerância zero para erros |
| Debug complexo (3+ tentativas falharam) | **Opus** | Reconhecimento de padrões sob ambiguidade |
| Brainstorm / planejamento / trade-offs | **Opus** | Julgamento — onde Sonnet falha catastroficamente |
| Reescrita de system prompts / config LLM | **Opus** | Sensibilidade a nuance e contexto |
| Operações de BD, migrations | **Tier grátis** | Especializado, baixo custo |
| Git add, commit, push, merge | **Tier grátis** | Operações mecânicas |

### Regra: Sonnet Não Planeja (INVIOLÁVEL)

> O custo de um plano ruim >>> o custo de usar Opus para planejar.
> Um plano falho do Sonnet desperdiça 6+ ciclos de execução em retrabalho.

Sonnet é **PROIBIDO** para:
- Gerar ideias ou explorar abordagens
- Decidir trade-offs entre alternativas
- Avaliar completude de planos
- Sintetizar conversas em documentos de decisão
- Qualquer atividade que exija "o que está faltando aqui?"

Sonnet é **SEGURO** somente quando:
- Transcreve decisões **já tomadas** pelo Opus/usuário
- Carrega contexto (ler arquivos, apresentar estado)
- Executa plano **já validado** pelo Opus
- Commit, push, changelog, formatação mecânica

---

## REGRAS INVIOLÁVEIS

### R0 — Compliance Check (SEQUÊNCIA PRESCRITIVA)

> Antes de QUALQUER resposta que modifique código, execute estes passos EM ORDEM.
> O hook SessionStart injeta dados fornecidos pelo sistema. Use esses valores — NÃO suponha.

**SEQUÊNCIA (todo passo é obrigatório):**

1. **VERIFICAR** o contexto do SessionStart para dados fornecidos pelo sistema (timestamp, fase, skills, lint)
2. **LER** `.github/tao/CONTEXT.md` — verificar fase, status, decisões travadas
3. **LER** `.github/tao/CHANGELOG.md` — últimas 3 entradas
4. **LER** `.github/tao/tao.config.json` — comandos de lint, config de branch
5. **VERIFICAR** `.github/skills/INDEX.md` — identificar skills que correspondem aos tipos de arquivo a editar
6. **EMITIR** o bloco de compliance com valores REAIS dos passos 1-5:

```
📋 COMPLIANCE CHECK — Fase XX
├─ Agente: [nome] ([modelo])
├─ Skills consultadas: [lista do passo 5, ou "nenhuma aplicável — nenhum tipo de arquivo correspondente"]
├─ Arquivos lidos antes de editar: [lista dos passos 2-4]
├─ CONTEXT.md lido: SIM
├─ CHANGELOG.md consultado: SIM
├─ ABEX: [PASSA após 3 passadas / N/A se sem alteração de código]
└─ Timestamp: [dos dados fornecidos pelo sistema, NÃO inventado]
```

**PROIBIDO:**
- Emitir o bloco ANTES de concluir os passos 1-5
- Usar valores placeholder (00:00, "carregando", "pendente")
- Omitir qualquer campo
- Inventar timestamps

### R1 — Verificação de Sintaxe Obrigatória

Após editar qualquer arquivo de código: executar o lint/compile check apropriado.
Comandos de lint são definidos em `.github/tao/tao.config.json` → `lint_commands`.
Se o lint falhar → corrigir → re-rodar (máx 3 tentativas). Após 3 falhas → rollback → registrar em progress.txt.

### R2 — Handoff = Prompt de Auditoria

Handoff DEVE ser um **prompt de auditoria** para o próximo agente, não "continuar próxima etapa."
Formato: "Audite [lista de arquivos]. Verifique [pontos específicos]." Ver §HANDOFF abaixo.

### R3 — Skill Check Obrigatório

Antes de QUALQUER tarefa que modifique código:
1. Identificar as extensões dos arquivos a editar.
2. Para cada extensão, verificar `.github/skills/INDEX.md` (se existir) — comparar contra os padrões `applyTo` de cada skill.
   **Algoritmo:** `.php` → verificar skills com `**/*.php` ou `*.php` em applyTo; `.ts` → `**/*.ts`; etc.
3. Ler o SKILL.md de cada skill correspondente antes de editar.

Sem leitura de skill para extensão correspondente = execução proibida.

### R4 — Timestamp Obrigatório

Toda entrada de documentação: `YYYY-MM-DD HH:MM`. Obter via `date '+%Y-%m-%d %H:%M'` antes de editar.
Sem horário = entrada inválida.

### R5 — Ler Antes de Editar

NUNCA editar arquivo sem ler seu conteúdo completo primeiro.
NUNCA inventar APIs, funções ou comportamentos — sempre ler o código real primeiro.

### R6 — Sync do CONTEXT.md

Após cada arquivo editado ou criado: atualizar `.github/tao/CONTEXT.md` seção "Arquivos Tocados (sessão)."
Nunca deixar TODO ou FIXME sem registrar em `.github/tao/CONTEXT.md` seção "Pendências Abertas."

### R7 — Git Limpo ao Encerrar

Ao encerrar qualquer sessão: verificar `git status`.
PROIBIDO encerrar com arquivos modificados não commitados.
Se um arquivo foi tocado → commit. Se não deve ser commitado → justificar em CONTEXT.md §Pendências Abertas.

---

## PROTOCOLO ABEX (Quality Gate)

**Definição:** ABEX = 3 passadas aplicadas após qualquer implementação que modifique código.
Automatizado via scan regex do `abex-gate.sh`. Resultado: **PASSA** (as 3 limpas) ou **FALHA** (qualquer finding).

| Passada | Foco | O que verificar |
|---------|------|-----------------|
| **1 — Segurança** | OWASP Top 10 | SQL injection, XSS, CSRF, auth bypass, catch vazio, input não validado, command injection, path traversal |
| **2 — Segurança do Usuário** | Saída + fronteiras de entrada | Escaping de output, validação de input, mensagens de erro, estados vazios, edge cases |
| **3 — Performance** | Eficiência em runtime | Sem queries N+1 óbvias, sem ops bloqueantes, sem loops sem limite, paginação ausente |

**Sem ABEX = tarefa não concluída.** Reportar findings por severidade: CRITICAL → HIGH → MEDIUM → INFO.

**Automação:** `abex-gate.sh` realiza detecção automática de padrões para a Passada 1 (Segurança). Roda automaticamente via hook pre-commit e hook PostToolUse. Os agentes realizam as 3 passadas manuais para revisão aprofundada. O scan automatizado captura padrões óbvios; a revisão manual captura issues sutis.

**Automação:** `abex-gate.sh` realiza detecção automática de padrões para a Passada 1 (Segurança). Roda automaticamente via hook pre-commit e hook PostToolUse. Os agentes realizam as 3 passadas manuais para revisão aprofundada. O scan automatizado captura padrões óbvios; a revisão manual captura issues sutis.

---

## SECURITY LOCKS

| Lock | Regra |
|------|-------|
| **LOCK 1 — ESCOPO** | Modificar apenas arquivos-fonte do projeto. NUNCA modificar: `CLAUDE.md`, `.github/workflows/`, `vendor/`, `node_modules/`, `venv/`, `.env`, `.github/tao/tao.config.json` (sem aprovação explícita). |
| **LOCK 2 — BRANCH** | Somente `dev` (ou conforme definido em `.github/tao/tao.config.json` → `git.dev_branch`). NUNCA `git push origin main`, `git push --force`, `git reset --hard`. |
| **LOCK 3 — DESTRUTIVO** | NUNCA `rm -rf`, `DROP TABLE`, `DROP DATABASE`, `TRUNCATE`, `DELETE FROM` sem cláusula WHERE. |
| **LOCK 4 — SCHEMA** | Qualquer `CREATE TABLE`, `ALTER TABLE`, `DROP COLUMN` → PARAR → documentar o SQL → registrar como checkpoint. |
| **LOCK 5 — PAUSA** | Se `.tao-pause` existir na raiz do projeto → **PARADA IMEDIATA**. Reportar status e interromper todas as operações. |

---

## WORKFLOW DE FASES

As fases seguem o pipeline de execução TAO:

```
1. Brainstorm → DISCOVERY.md + DECISIONS.md  (somente Opus — agente @Brainstorm-Wu)
2. Sintetizar → BRIEF.md                      (somente Opus — maturity gate ≥ 5/7)
3. Planejar   → PLAN.md                       (somente Opus — @Brainstorm-Wu ou @Investigar-Shen)
4. Status     → STATUS.md com tabela de tarefas (qualquer agente)
5. Tarefas    → pasta tasks/, um .md por tarefa
6. Executar   → trigger "executar" no Copilot Chat → loop de tarefas
7. Cada tarefa → commit individual (atômico)
8. Atualizar  → CONTEXT.md + CHANGELOG.md após cada tarefa
```

**Triggers:**
- `"executar"` / `"execute"` / `"continuar"` → entrar no loop de tarefas (lê STATUS.md, pega próxima tarefa ⏳)
- `"próxima tarefa"` / `"tarefa NN"` → executar UMA tarefa e parar
- `"brainstorm"` / `"discutir"` → sessão de ideação (somente Opus)
- `"planejar fase"` / `"criar plano"` → criação de plano (somente Opus)
- `"revisão"` / `"auditar"` → ABEX 3× passadas

---

## CONVENÇÃO DE COMMITS

```
tipo(escopo): descrição curta em imperativo
```

**Tipos:** `feat` · `fix` · `refactor` · `docs` · `chore` · `hotfix` · `test`

**Escopos:** definidos por projeto em `.github/tao/tao.config.json` → `commit_scopes`. Exemplos comuns: `api`, `auth`, `db`, `ui`, `core`, `deploy`.

**Regras:**
- Modo imperativo: "adicionar feature" não "adicionada feature"
- Máximo 72 caracteres no assunto
- Nunca `git add -A` — sempre `git add <arquivos-específicos>`
- Push de acordo com `git.auto_push` em `.github/tao/tao.config.json`. Se `auto_push: true`, push após cada commit. Se `false`, apenas commit — push quando pronto.

---

## FORMATO DO CHANGELOG

Novas entradas sempre no **TOPO** do arquivo. Máximo 15 linhas por entrada.

```markdown
## [YYYY-MM-DD HH:MM] tipo(escopo): título descritivo

- **Modelo:** [modelo do agente] | **Fase:** X — Nome
- **Arquivos:** `caminho/arquivo.ext`, `caminho/outro.ext`
- O que foi feito (ação + resultado)
- Decisões não óbvias e por quê
```

---

## CONTEXT.md — Campos Obrigatórios

Todo `.github/tao/CONTEXT.md` DEVE conter estes campos:

| # | Campo | Descrição |
|---|-------|-----------|
| 1 | **Fase Ativa** | Qual fase está em execução |
| 2 | **Última Ação** | O que foi feito (1 frase) |
| 3 | **Próxima Ação** | O que fazer na próxima sessão (1 frase) |
| 4 | **Arquivos Tocados (sessão)** | Lista dos arquivos criados/editados nesta sessão |
| 5 | **Pendências Abertas** | TODOs, FIXMEs, problemas conhecidos |
| 6 | **Decisões Travadas** | Decisões que NÃO podem ser revisadas sem aprovação |

---

## FORMATO DO HANDOFF

Toda sessão que modifica código DEVE encerrar com um bloco de handoff.

```
---
## 🔄 HANDOFF — ORDEM para o próximo agente

**Agente designado:** OPUS | SONNET
**Justificativa:** [1 frase explicando POR QUE este agente]

### ORDEM DE EXECUÇÃO:

> [Prompt imperativo — 3-10 linhas. O que foi feito, o que FAZER,
> quais arquivos ler, qual ação executar. Tom: ORDEM, não sugestão.]
```

### Critérios de Designação

| Critério | → OPUS | → SONNET |
|----------|--------|----------|
| Raciocínio profundo / arquitetura | ✅ | ❌ |
| Debug complexo | ✅ | ❌ |
| Auditoria de segurança | ✅ | ❌ |
| Decisões com impacto sistêmico | ✅ | ❌ |
| Implementação rotineira (CRUD, views) | ❌ | ✅ |
| Execução de plano validado | ❌ | ✅ |
| Tarefas de alto volume / repetitivas | ❌ | ✅ |
| Documentação / changelog | ❌ | ✅ |

**Regra:** Se a tarefa cabe no Sonnet, NUNCA use Opus.

---

## REGRAS DE AUTONOMIA

- **Respeite o que CONTEXT.md diz.** Se diz "fase concluída", NÃO procure mais trabalho.
- **NUNCA sugira próximos passos proativamente.** Quem define prioridades é o usuário.
- **NUNCA pergunte "posso fazer X?" ou "quer que eu faça Y?".** Execute o que foi pedido. Ponto.

**Exceção:** Quando o status do CONTEXT.md for `novo_projeto`, o agente @Executar-Tao PODE fazer UMA pergunta para identificar o escopo do projeto (ver fluxo de onboarding). Esta é a ÚNICA exceção e ocorre UMA VEZ por projeto.

- **Ao encerrar sessão:** relate SOMENTE o que foi feito. Sem conselhos não solicitados.

---

## CHECKLIST DE SESSÃO

### Antes de qualquer ação (mesmo trivial)
- [ ] Ler `CLAUDE.md` (raiz do projeto)
- [ ] Ler `.github/tao/RULES.md` (este arquivo)
- [ ] Ler `.github/tao/CONTEXT.md` (estado atual)
- [ ] Consultar `.github/tao/CHANGELOG.md` (últimas 5 entradas)
- [ ] Verificar `.github/skills/INDEX.md` (se existir)

### Após qualquer sessão
- [ ] Timestamp obtido via `date '+%Y-%m-%d %H:%M'` (R4)
- [ ] `.github/tao/CONTEXT.md` atualizado com timestamp
- [ ] Entrada registrada no `.github/tao/CHANGELOG.md` com HH:MM
- [ ] Handoff gerado (ver §HANDOFF)
- [ ] Lint/compile check em TODOS os arquivos modificados (R1)
- [ ] Commit atômico com mensagem padronizada
- [ ] Push para dev se `git.auto_push: true` (verificar .github/tao/tao.config.json)
- [ ] `git status` verificado — PROIBIDO encerrar com arquivos não commitados (R7)
