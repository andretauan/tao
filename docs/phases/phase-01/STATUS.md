# STATUS — Phase 01: Vibe Coder Promise Fulfillment

> Executor reads this file to know which task to run.
> Mark ✅ when done. Mark ❌ if blocked.
> **Last update:** 2026-03-29
>
> **Execution order:**
> P0: T02 → T03 → T04 → T01
> P1: T05 → T06 → T07
> P2: T08 → T09 → T10
> P3: T11 → T12 → T13 → T14
> P4: T15 → T16

## GROUP P0 — First-Run Experience (Blocking)

| # | Task | Complexity | Executor | Status | Notes |
|---|------|------------|----------|--------|-------|
| T02 | install.sh: auto-detect lint stack | Medium | Sonnet | ⏳ | Replace Q5 with detection |
| T03 | install.sh: phase 01 + .vscode + output | Medium | Sonnet | ⏳ | Depends on T02 |
| T04 | lint-hook.sh: verify tool + warn empty | Low | Sonnet | ⏳ | — |
| T01 | Onboarding flow in Execute-Tao agents | High | Architect | ⏳ | Depends on T03, T06 |

## GROUP P1 — Contradictions & Consistency

| # | Task | Complexity | Executor | Status | Notes |
|---|------|------------|----------|--------|-------|
| T05 | Fix auto_push in RULES.md template | Low | Sonnet | ⏳ | —  |
| T06 | Fix CONTEXT.md templates (EN+PT-BR) | Low | Sonnet | ⏳ | — |
| T07 | Add novo_projeto exception to RULES.md | Low | Sonnet | ⏳ | — |

## GROUP P2 — Enforcement & Quality Gates

| # | Task | Complexity | Executor | Status | Notes |
|---|------|------------|----------|--------|-------|
| T08 | Create abex-gate.sh | High | Architect | ⏳ | New script |
| T09 | enforcement-hook.sh: strengthen R5 | Low | Sonnet | ⏳ | — |
| T10 | context-hook.sh: enhanced dashboard | Medium | Sonnet | ⏳ | — |

## GROUP P3 — Documentation & Claims

| # | Task | Complexity | Executor | Status | Notes |
|---|------|------------|----------|--------|-------|
| T11 | README (EN+PT-BR): qualify + troubleshoot | Medium | Architect | ⏳ | Both languages |
| T12 | GETTING-STARTED.md: Quick Path | Low | Sonnet | ⏳ | — |
| T13 | ECONOMICS.md: full-cycle costs | Medium | Sonnet | ⏳ | — |
| T14 | Wu agents (EN+PT-BR): rate-limit msg | Low | Sonnet | ⏳ | Both languages |

## GROUP P4 — Verification

| # | Task | Complexity | Executor | Status | Notes |
|---|------|------------|----------|--------|-------|
| T15 | Bilingual smoke test: fresh install | High | Architect | ⏳ | E2E test |
| T16 | Regression check: existing projects | Medium | Sonnet | ⏳ | tao-test |

---

## SUMMARY — 2026-03-29

| Group | Done | Pending | Tasks |
|-------|------|---------|-------|
| P0 — First-Run | 0/4 | 4 | T01-T04 |
| P1 — Consistency | 0/3 | 3 | T05-T07 |
| P2 — Enforcement | 0/3 | 3 | T08-T10 |
| P3 — Documentation | 0/4 | 4 | T11-T14 |
| P4 — Verification | 0/2 | 2 | T15-T16 |
| **TOTAL** | **0/16** | **16** | — |

**Executor breakdown:** Architect (Opus): 4 tasks | Sonnet: 12 tasks

---

## 🎯 PRÓXIMA AÇÃO — Como Executar

> **A próxima tarefa é: T02 — install.sh: auto-detect lint stack**

### Passo a passo:

1. Abra o **Copilot Chat** no VS Code
2. Selecione o agente **@Executar-Tao** (clique no `@` e escolha)
3. Digite:
   ```
   executar T02
   ```
4. O agente vai ler a spec em `docs/phases/phase-01/tasks/02-install-autodetect-lint.md` e implementar

### Após T02 concluída, a próxima será:
```
executar T03
```

### Ordem completa de execução:
```
@Executar-Tao → executar T02
@Executar-Tao → executar T03
@Executar-Tao → executar T04
@Executar-Tao → executar T01
@Executar-Tao → executar T05
@Executar-Tao → executar T06
@Executar-Tao → executar T07
@Executar-Tao → executar T08  (⚠️ este usa Opus — Architect)
@Executar-Tao → executar T09
@Executar-Tao → executar T10
@Executar-Tao → executar T11  (⚠️ este usa Opus — Architect)
@Executar-Tao → executar T12
@Executar-Tao → executar T13
@Executar-Tao → executar T14
@Executar-Tao → executar T15  (⚠️ este usa Opus — Architect)
@Executar-Tao → executar T16
```

> Após T16, todos os testes passando → `git push origin dev` → testar → `git push origin main`
