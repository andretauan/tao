# PLAN — Phase 02: Correção Total — TAO 100% Determinístico

> **Objetivo:** Corrigir todos os gaps identificados na auditoria científica para que o TAO entregue exatamente o que promete — enforcement determinístico real, não instrução textual.

> **Princípio norteador:** Depois desta fase, NENHUMA promessa do README dependerá de "o agente decidir obedecer". Tudo que é anunciado como automático SERÁ automático.

---

## Auditoria Científica Consolidada — Todos os Gaps

### CATEGORIA A — ENFORCEMENT FALSO (promessas de automação que são texto)

| ID | Gap | Severidade | Evidência |
|----|-----|-----------|-----------|
| A1 | `validate-brainstorm.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | Referenciado apenas em Execute-Tao.agent.md L91 como pseudo-código |
| A2 | `validate-plan.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | Referenciado apenas em Execute-Tao.agent.md L128 como pseudo-código |
| A3 | `validate-execution.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | Referenciado apenas em Execute-Tao.agent.md L157 como pseudo-código |
| A4 | `doc-validate.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | Referenciado apenas em Execute-Tao.agent.md L183 como pseudo-código |
| A5 | `forensic-audit.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | README diz "Every commit passes through a 3-pass forensic audit" — FALSO |
| A6 | `faudit.sh` não está em nenhum hook (L0/L1) | 🔴 CRÍTICO | Nunca executado automaticamente |
| A7 | README diz "~98% enforcement via deterministic automation" | 🔴 CRÍTICO | Real: ~50-55%. Precisa ser corrigido no código OU no README |
| A8 | README diz "not honor-system" mas ~45% é honor-system | 🔴 CRÍTICO | Aparece 2x no README (EN + PT-BR) |

### CATEGORIA B — BUGS DE SEGURANÇA

| ID | Gap | Severidade | Evidência |
|----|-----|-----------|-----------|
| B1 | pre-commit.sh L71: `bash -c "$cmd"` sem sanitização de `$file` | 🔴 CRÍTICO | Filename com metacharacters pode injetar comandos shell |
| B2 | pre-push.sh L32: não detecta `-f` (forma curta de `--force`) | 🔴 CRÍTICO | `git push -f origin dev` passa sem bloqueio |
| B3 | context-hook.sh: race condition em `.tao-session/reads.log` | ⚠️ ALTO | Sessões paralelas podem corromper o log |
| B4 | lint-hook.sh sanitiza `FILE_PATH` mas não cobre newlines | ⚠️ MÉDIO | Regex em L105 não inclui `\n` |

### CATEGORIA C — LOOPS INFINITOS

| ID | Gap | Severidade | Evidência |
|----|-----|-----------|-----------|
| C1 | BRAINSTORM_FIX_LOOP reseta contador após 3 tentativas e volta ao início | 🔴 CRÍTICO | Execute-Tao.agent.md L97-112: `brainstorm_fix_attempt = 0 → GOTO BRAINSTORM_FIX_LOOP` sem limite total |
| C2 | PLAN_FIX_LOOP: mesmo problema | 🔴 CRÍTICO | Execute-Tao.agent.md L128-135: reset infinito |
| C3 | GATE_LOOP reseta `gate_attempt = 0` após Shen intervenção | 🔴 CRÍTICO | Execute-Tao.agent.md L221-228: `gate_attempt = 0 → GOTO GATE_LOOP` sem circuit breaker |

### CATEGORIA D — INCONSISTÊNCIAS DOCUMENTAÇÃO

| ID | Gap | Severidade | Evidência |
|----|-----|-----------|-----------|
| D1 | tao-brainstorm/SKILL.md tem critérios de maturidade DIFERENTES de BRIEF.md.template e Wu | ⚠️ ALTO | Skill lista critérios diferentes dos 7 definidos no agent e no template |
| D2 | Execute-Tao YAML: modelo duplo (Sonnet + GPT-4.1) mas docs dizem "Sonnet only" | ⚠️ MÉDIO | L5-6 YAML vs L22 texto |
| D3 | Investigate-Shen YAML: modelo duplo (Opus + Sonnet) mas docs dizem "Opus only" | ⚠️ MÉDIO | L4-5 YAML vs L11 texto |
| D4 | README promete "runs automatically without pausing" — loop é pseudo-código | ⚠️ ALTO | O loop NÃO é um processo de sistema — é instrução textual |
| D5 | README promete "14 skills auto-discovered" — mecanismo não documentado | ⚠️ BAIXO | É feature do VS Code, não do TAO |
| D6 | README Troubleshooting diz "the commit is rejected" para agent skip — incompleto | ⚠️ MÉDIO | Só rejeita lint/ABEX/branch, não validate-*/forensic |
| D7 | GUARDRAILS.md numeração de LOCKs conflita entre seções | ⚠️ BAIXO | LOCK numbers inconsistentes em docs vs scripts |

### CATEGORIA E — GAPS ESTRUTURAIS

| ID | Gap | Severidade | Evidência |
|----|-----|-----------|-----------|
| E1 | Nenhum mecanismo impede commit sem brainstorm completo | 🔴 CRÍTICO | Se agente pula brainstorm_gate, pre-commit.sh NÃO checa BRIEF.md |
| E2 | Nenhum mecanismo impede commit sem plan válido | 🔴 CRÍTICO | Se agente pula plan_gate, pre-commit.sh NÃO checa PLAN.md |
| E3 | compliance check block (R0) é apenas prompt-based | ⚠️ ALTO | Nenhum hook verifica se compliance block existe no output |
| E4 | faudit.sh PASS 3 (hacker perspective) parcialmente implementado | ⚠️ MÉDIO | Descrito mas incompleto |

---

## Plano de Correção — 24 Tarefas

### GRUPO P1 — ENFORCEMENT L0: Wiring de Scripts no Pre-commit (7 tarefas)

> **Objetivo:** Transformar scripts que hoje são "honor-system" em enforcement real via git hooks.

#### T01 — Criar gate de brainstorm no pre-commit.sh
- **O que:** Adicionar chamada a `validate-brainstorm.sh` no pre-commit.sh
- **Lógica:** Se existe `brainstorm/BRIEF.md` no diretório da fase ativa E nenhuma task está ✅ no STATUS.md, executar validate-brainstorm.sh. Se falhar → BLOCK commit.
- **Condição:** Só bloqueia se BRIEF existe mas é inválido. Se BRIEF não existe ainda (fase sem brainstorm iniciado), não bloqueia. Se já há tasks ✅, pula (brainstorm já foi validado antes).
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] `validate-brainstorm.sh` é chamado no pre-commit quando condições atendem
  - [ ] BRIEF.md inválido → commit bloqueado
  - [ ] BRIEF.md válido → commit passa
  - [ ] Sem BRIEF.md → commit passa (brainstorm ainda não iniciado)
  - [ ] Task ✅ já existe → pula gate (já validado)

#### T02 — Criar gate de plan no pre-commit.sh
- **O que:** Adicionar chamada a `validate-plan.sh` no pre-commit.sh
- **Lógica:** Se existe `STATUS.md` no diretório da fase ativa E nenhuma task está ✅, executar validate-plan.sh. Se falhar → BLOCK commit.
- **Condição:** Só bloqueia na primeira execução (antes de qualquer task ser marcada ✅). Depois disso, pula.
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] `validate-plan.sh` é chamado no pre-commit quando condições atendem
  - [ ] PLAN.md inválido → commit bloqueado
  - [ ] PLAN.md válido → commit passa
  - [ ] Task ✅ já existe → pula gate (plano já validado)

#### T03 — Criar gate de execução no pre-commit.sh
- **O que:** Adicionar chamada a `validate-execution.sh` no pre-commit.sh
- **Lógica:** Se todas as tasks do STATUS.md estão ✅ (fase completa), executar validate-execution.sh. Se falhar → BLOCK commit.
- **Condição:** Só roda quando a fase inteira está completa. Isso garante que o último commit de uma fase passe pela validação completa.
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] `validate-execution.sh` é chamado quando todas tasks ✅
  - [ ] Validação falha → commit bloqueado
  - [ ] Validação passa → commit liberado
  - [ ] Tasks ⏳ restantes → pula gate

#### T04 — Criar gate de documentação no pre-commit.sh
- **O que:** Adicionar chamada a `doc-validate.sh` no pre-commit.sh
- **Lógica:** Se todas as tasks do STATUS.md estão ✅ (fase completa), executar doc-validate.sh junto com T03.
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] `doc-validate.sh` é chamado quando todas tasks ✅
  - [ ] Documentação incompleta → commit bloqueado
  - [ ] Documentação ok → commit passa

#### T05 — Criar gate forensic no pre-commit.sh
- **O que:** Adicionar chamada a `forensic-audit.sh` no pre-commit.sh
- **Lógica:** Se todas as tasks do STATUS.md estão ✅ (fase completa), executar forensic-audit.sh como última verificação.
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] `forensic-audit.sh` roda no commit de fase completa
  - [ ] Auditoria forense falha → commit bloqueado
  - [ ] Auditoria forense passa → commit liberado
  - [ ] README passa a ser VERDADEIRO: "Every commit passes through a 3-pass forensic audit" (para commits de conclusão de fase)

#### T06 — Helper: extrair fase ativa no pre-commit.sh
- **O que:** Criar função reutilizável no pre-commit.sh que lê `tao.config.json` + `CONTEXT.md` para determinar o diretório da fase ativa e o estado das tasks.
- **Arquivos:** `hooks/pre-commit.sh`
- **Critérios de aceite:**
  - [ ] Função `get_active_phase_dir()` retorna path da fase ativa
  - [ ] Função `count_tasks()` retorna contagem de ⏳ e ✅
  - [ ] Usado por T01-T05
  - [ ] Fallback gracioso se CONTEXT.md não existe

#### T07 — Adicionar validate-brainstorm.sh e validate-plan.sh ao hooks.json (L1)
- **O que:** Registrar os scripts de validação como PostToolUse hooks para feedback em tempo real durante sessões de agente.
- **Lógica:** Criar um novo hook PostToolUse que, após write_file em artefatos de brainstorm/plan, executa o validador correspondente e injeta o resultado como feedback.
- **Arquivos:** `templates/shared/hooks.json`, criar `hooks/brainstorm-hook.sh` e `hooks/plan-hook.sh`
- **Critérios de aceite:**
  - [ ] Após agent criar/editar BRIEF.md → validate-brainstorm.sh roda e injeta feedback
  - [ ] Após agent criar/editar PLAN.md/STATUS.md → validate-plan.sh roda e injeta feedback
  - [ ] Feedback aparece no chat como PostToolUse output
  - [ ] Não bloqueia (L1 = advisory), mas fornece awareness imediata

---

### GRUPO P2 — BUGS DE SEGURANÇA (4 tarefas)

#### T08 — Sanitizar file paths no pre-commit.sh
- **O que:** Adicionar sanitização de `$file` antes de `bash -c "$cmd"` na seção de lint do pre-commit.sh
- **Arquivos:** `hooks/pre-commit.sh` L60-75
- **Critérios de aceite:**
  - [ ] Nomes de arquivo com metacharacters (`;`, `|`, `&`, `` ` ``, `$`, `(`, `)`) são detectados e skipped
  - [ ] Nomes com espaços funcionam normalmente
  - [ ] Nomes normais não são afetados

#### T09 — Corrigir detecção de force-push no pre-push.sh
- **O que:** Adicionar detecção de `-f` (forma curta) na regex do pre-push.sh
- **Arquivos:** `hooks/pre-push.sh` L32
- **Critérios de aceite:**
  - [ ] `git push -f origin dev` → BLOQUEADO
  - [ ] `git push --force origin dev` → BLOQUEADO (já funciona)
  - [ ] `git push --force-with-lease origin dev` → BLOQUEADO (já funciona)
  - [ ] `git push origin dev` → PERMITIDO (não é force)

#### T10 — Corrigir race condition no context-hook.sh
- **O que:** Usar session ID único (PID + timestamp) para isolar logs de sessões paralelas
- **Arquivos:** `hooks/context-hook.sh`, `hooks/enforcement-hook.sh`
- **Critérios de aceite:**
  - [ ] Cada sessão cria `.tao-session/{session_id}/reads.log` isolado
  - [ ] Cleanup de sessões antigas (>24h) automático
  - [ ] Sessões paralelas não corrompem logs uma da outra

#### T11 — Corrigir sanitização de newlines no lint-hook.sh
- **O que:** Adicionar `\n` e `\r` à regex de sanitização de FILE_PATH
- **Arquivos:** `hooks/lint-hook.sh` L105
- **Critérios de aceite:**
  - [ ] Paths com newlines → skipped
  - [ ] Regex inclui caracteres de controle

---

### GRUPO P3 — CIRCUIT BREAKERS (3 tarefas)

#### T12 — Adicionar limite total ao BRAINSTORM_FIX_LOOP
- **O que:** Adicionar `MAX_TOTAL_BRAINSTORM_ATTEMPTS = 9` (3 Wu + 3 Shen + 3 Wu = 9). Após 9 tentativas totais, PARAR e reportar ao usuário.
- **Arquivos:** `agents/en/Execute-Tao.agent.md`, `agents/pt-br/Executar-Tao.agent.md`
- **Critérios de aceite:**
  - [ ] Counter total independente do counter por ciclo
  - [ ] Após 9 tentativas → STOP com relatório de falhas
  - [ ] Nunca loop infinito

#### T13 — Adicionar limite total ao PLAN_FIX_LOOP
- **O que:** Mesmo padrão de T12 para o loop de fix do plano.
- **Arquivos:** `agents/en/Execute-Tao.agent.md`, `agents/pt-br/Executar-Tao.agent.md`
- **Critérios de aceite:**
  - [ ] MAX_TOTAL_PLAN_ATTEMPTS = 9
  - [ ] Após 9 → STOP com relatório
  - [ ] Nunca loop infinito

#### T14 — Adicionar limite total ao GATE_LOOP
- **O que:** Mesmo padrão de T12 para o GATE_LOOP de pós-execução.
- **Arquivos:** `agents/en/Execute-Tao.agent.md`, `agents/pt-br/Executar-Tao.agent.md`
- **Critérios de aceite:**
  - [ ] MAX_TOTAL_GATE_ATTEMPTS = 9
  - [ ] Após 9 → STOP com relatório, marcar fase como ⚠️
  - [ ] Nunca loop infinito

---

### GRUPO P4 — CONSISTÊNCIA DE DOCUMENTAÇÃO (6 tarefas)

#### T15 — Corrigir critérios de maturidade no tao-brainstorm/SKILL.md
- **O que:** Alinhar os 7 critérios de maturidade do skill com os definidos em Brainstorm-Wu.agent.md e BRIEF.md.template
- **Arquivos:** `skills/en/tao-brainstorm/SKILL.md`, `skills/pt-br/tao-brainstorm/SKILL.md`
- **Critérios de aceite:**
  - [ ] 7 critérios idênticos nos 3 locais (agent, skill, template)

#### T16 — Documentar modelo duplo no Execute-Tao como fallback intencional
- **O que:** Atualizar a documentação interna do agent para explicar que GPT-4.1 é fallback (não modelo primário). Não remover o fallback — é feature de rate-limit shield.
- **Arquivos:** `agents/en/Execute-Tao.agent.md` L22, `agents/pt-br/Executar-Tao.agent.md`
- **Critérios de aceite:**
  - [ ] Texto diz "Model: Sonnet 4.6 (primary) with GPT-4.1 fallback (free)"
  - [ ] Consistente com README Rate Limit Shield section

#### T17 — Documentar modelo duplo no Investigate-Shen como fallback intencional
- **O que:** Mesmo que T16 para Investigate-Shen.
- **Arquivos:** `agents/en/Investigate-Shen.agent.md` L11, `agents/pt-br/Investigar-Shen.agent.md`
- **Critérios de aceite:**
  - [ ] Texto diz "Model: Opus 4.6 (primary) with Sonnet 4.6 fallback"
  - [ ] Consistente com README

#### T18 — Atualizar README: ~98% → número real + qualificar loop
- **O que:** Corrigir as duas seções falsas do README:
  1. Substituir "~98%" pelo número real pós-correção (com T01-T07 implementados, será ~85-90%)
  2. Qualificar que o loop autônomo é uma sequência de instruções seguida pelo agente, não um processo de sistema
  3. Corrigir "Every commit passes through a 3-pass forensic audit" → "Phase completion commits pass through..."
  4. Manter "not honor-system" apenas para as partes que são realmente L0/L1
- **Arquivos:** `README.md`, `README.pt-br.md`
- **Critérios de aceite:**
  - [ ] Nenhuma promessa falsa no README
  - [ ] Porcentagem real baseada em contagem de mecanismos L0+L1 vs total
  - [ ] Loop descrito honestamente
  - [ ] Forensic audit descrito com condição real

#### T19 — Corrigir GUARDRAILS.md: numeração de LOCKs consistente
- **O que:** Auditar toda a numeração de LOCKs entre GUARDRAILS.md, RULES.md, scripts e agents. Alinhar.
- **Arquivos:** `docs/GUARDRAILS.md`, `templates/en/RULES.md`, `templates/pt-br/RULES.md`
- **Critérios de aceite:**
  - [ ] Cada LOCK tem número único
  - [ ] Mesma numeração em todos os arquivos
  - [ ] Referências cruzadas corretas

#### T20 — Atualizar Troubleshooting do README
- **O que:** Corrigir seção "Agent ignores rules" para refletir enforcement real pós-T01-T07.
- **Arquivos:** `README.md`, `README.pt-br.md`
- **Critérios de aceite:**
  - [ ] Lista quais violações são bloqueadas em L0 vs L1
  - [ ] Não promete bloqueio para coisas que não bloqueia

---

### GRUPO P5 — ROBUSTEZ ESTRUTURAL (3 tarefas)

#### T21 — Completar PASS 3 (hacker) do faudit.sh
- **O que:** Implementar os checks faltantes da perspectiva de atacante no faudit.sh
- **Arquivos:** `scripts/faudit.sh`
- **Critérios de aceite:**
  - [ ] Todos os checks documentados na PASS 3 estão implementados
  - [ ] Inclui: dependency audit, env var leak, debug endpoint, insecure defaults
  - [ ] Cada check produz output claro (PASS/FAIL/WARN)

#### T22 — Reduzir falsos positivos no abex-gate.sh
- **O que:** Refinar regexes de detecção de segredos hardcoded (padrão `[A-Za-z0-9+/]{4,}` é muito amplo)
- **Arquivos:** `scripts/abex-gate.sh`
- **Critérios de aceite:**
  - [ ] Regex exige contexto (prefixo `key=`, `secret=`, `password=`, `token=`)
  - [ ] Strings normais de 4+ chars não disparam falso positivo
  - [ ] Secrets reais ainda são detectados

#### T23 — Tornar sed no new-phase.sh robusto contra metacharacters
- **O que:** Corrigir escape de metacharacters sed (`&`, `/`, `\`) nos placeholders do new-phase.sh
- **Arquivos:** `scripts/new-phase.sh`
- **Critérios de aceite:**
  - [ ] Nomes de projeto com `&`, `/`, `\` não corrompem substituição
  - [ ] Usar Python para substituição em vez de sed, ou escapar corretamente

---

### GRUPO P6 — VALIDAÇÃO FINAL (1 tarefa)

#### T24 — Teste de integração completo
- **O que:** Instalar TAO num projeto limpo e executar o ciclo completo:
  1. `bash install.sh .` → verificar toda a árvore
  2. Criar BRIEF.md inválido → tentar commit → deve BLOQUEAR (T01)
  3. Criar BRIEF.md válido → commit → deve PASSAR
  4. Criar PLAN.md inválido → commit → deve BLOQUEAR (T02)
  5. Criar PLAN.md válido → commit → deve PASSAR
  6. Completar todas as tasks → commit → forensic-audit deve rodar (T05)
  7. `git push -f` → deve BLOQUEAR (T09)
  8. Arquivo com metacharacter no nome → lint não injeta (T08)
  9. hooks.json → brainstorm-hook e plan-hook produzem feedback (T07)
- **Arquivos:** Projeto temporário de teste
- **Critérios de aceite:**
  - [ ] Todos os 9 cenários passam
  - [ ] Zero falsos positivos
  - [ ] Zero falsos negativos
  - [ ] Pipeline é genuinamente determinístico

---

## Ordem de Execução

```
P1 (T06 → T01 → T02 → T03 → T04 → T05 → T07)  ← fundação
  ↓
P2 (T08 → T09 → T10 → T11)  ← segurança
  ↓
P3 (T12 → T13 → T14)  ← proteção contra loops
  ↓
P4 (T15 → T16 → T17 → T18 → T19 → T20)  ← documentação honesta
  ↓
P5 (T21 → T22 → T23)  ← robustez
  ↓
P6 (T24)  ← validação final
```

**T06 é prerequisito de T01-T05** (helper de extração de fase).
**T18 só pode ser escrito após T01-T07** (precisa saber o número real de enforcement).
**T24 é a última tarefa** (valida tudo junto).

---

## Resultado Esperado

Após as 24 tarefas:

| Métrica | Antes | Depois |
|---------|-------|--------|
| Scripts de validação em L0 (pre-commit) | 1 (ABEX) | 6 (ABEX + brainstorm + plan + execution + doc + forensic) |
| Scripts de validação em L1 (hooks.json) | 3 (lint + enforcement + ABEX) | 5 (+brainstorm-hook + plan-hook) |
| Enforcement determinístico real | ~50-55% | ~85-90% |
| Bugs de segurança | 4 | 0 |
| Loops infinitos possíveis | 3 | 0 |
| Promessas falsas no README | 3 | 0 |
| Inconsistências de documentação | 7 | 0 |

**O que continua como L2 (instrução textual) — e isso é OK:**
- O loop de execução em si (é comportamento de agente, não de git)
- O roteamento de modelos (decisão do agente baseada em complexidade)
- O compliance check block (output format do agente)
- A proibição de Wu escrever código (guardrail subjetivo)

**Esses itens são genuinamente L2** — não faz sentido tentar enforçá-los via hook. O README será atualizado para reconhecê-los honestamente como tal.
