# T01 — Gate de brainstorm no pre-commit.sh

## Objetivo
Adicionar validação de brainstorm como gate L0 no pre-commit.sh, para que commits com BRIEF.md inválido sejam bloqueados deterministicamente.

## Contexto
- `validate-brainstorm.sh` existe e funciona, mas só é chamado via instrução textual no agent
- README diz "guardrails are code-enforced — bash scripts that block bad commits"
- Atualmente, o agente pode pular o brainstorm gate sem consequências no commit

## Arquivos a Ler
- `hooks/pre-commit.sh` — hook existente onde inserir o gate
- `scripts/validate-brainstorm.sh` — script de validação a ser chamado
- `agents/en/Execute-Tao.agent.md` L91-112 — lógica atual do BRAINSTORM_GATE

## Arquivos a Modificar
- `hooks/pre-commit.sh`

## Passos
1. Usar helper `get_active_phase_dir()` de T06 para obter diretório da fase ativa
2. Checar se `brainstorm/BRIEF.md` existe no diretório da fase
3. Checar se alguma task já está ✅ no STATUS.md (se sim, pula — brainstorm já validado)
4. Se BRIEF existe e nenhuma task ✅: executar `validate-brainstorm.sh {phase_dir}`
5. Se exit 1: bloquear commit com mensagem clara
6. Se exit 0 ou script não encontrado: permitir commit

## Critérios de Aceite
- [ ] BRIEF.md inválido → commit bloqueado
- [ ] BRIEF.md válido → commit passa
- [ ] Sem BRIEF.md → commit passa (brainstorm não iniciado)
- [ ] Task ✅ já existe → pula gate
- [ ] Mensagem de erro bilíngue (PT-BR + EN)
