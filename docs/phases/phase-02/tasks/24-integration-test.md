# T24 — Teste de integração completo

## Objetivo
Validar que TODAS as correções (T01-T23) funcionam em conjunto num projeto real instalado.

## Contexto
- Esta é a tarefa final — validação end-to-end
- Precisa de um projeto limpo onde TAO será instalado do zero
- Cada gate adicionado (T01-T05) deve ser testado em cenário real

## Passos

### Setup
1. Criar diretório temporário para projeto de teste
2. `bash install.sh .` → verificar toda a árvore gerada
3. Inicializar git repo, criar branch dev

### Cenários de Teste

| # | Cenário | Esperado |
|---|---------|----------|
| C1 | Criar BRIEF.md inválido (maturidade 2/7) → commit | BLOQUEADO (T01) |
| C2 | Criar BRIEF.md válido (maturidade 6/7) → commit | PASSA |
| C3 | Criar PLAN.md sem traceabilidade → commit | BLOQUEADO (T02) |
| C4 | Criar PLAN.md válido → commit | PASSA |
| C5 | Completar todas tasks ✅ + doc incompleta → commit | BLOQUEADO (T04) |
| C6 | Completar todas tasks ✅ + forensic falha → commit | BLOQUEADO (T05) |
| C7 | Completar tudo válido → commit | PASSA |
| C8 | `git push -f origin dev` | BLOQUEADO (T09) |
| C9 | Arquivo com `;` no nome → lint | SKIPPED sem crash (T08) |
| C10 | Editar BRIEF.md no agent mode → PostToolUse | Feedback imediato (T07) |

### Validação de Segurança
| # | Cenário | Esperado |
|---|---------|----------|
| S1 | Criar arquivo com `eval(user_input)` → commit | ABEX BLOCK |
| S2 | Criar password hardcoded → commit | ABEX BLOCK |
| S3 | String normal de 4 chars → commit | NÃO dispara (T22) |

### Validação de Circuit Breakers
- Manualmente simular falha em validate-brainstorm que nunca resolve → verificar que para em 9 tentativas

## Critérios de Aceite
- [ ] Todos 10 cenários de gate passam
- [ ] Todos 3 cenários de segurança passam
- [ ] Circuit breaker funciona
- [ ] Zero falsos positivos
- [ ] Zero falsos negativos
- [ ] Pipeline é genuinamente determinístico
- [ ] README é 100% factual pós T18
