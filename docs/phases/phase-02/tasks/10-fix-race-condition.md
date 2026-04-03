# T10 — Corrigir race condition no context-hook.sh

## Objetivo
Isolar logs de sessão para evitar corrupção quando múltiplas sessões rodam em paralelo.

## Contexto
- context-hook.sh L35: `rm -f "$SESSION_DIR/reads.log"` limpa o log de todas as sessões
- enforcement-hook.sh escreve em `reads.log` — se duas sessões existem, uma corrompe a outra
- Solução: usar session ID único por sessão

## Arquivos a Ler
- `hooks/context-hook.sh` L25-50
- `hooks/enforcement-hook.sh` — onde reads.log é escrito

## Arquivos a Modificar
- `hooks/context-hook.sh`
- `hooks/enforcement-hook.sh`

## Passos
1. Gerar session ID: `SESSION_ID="${PPID}_$(date +%s)"`
2. Criar diretório `.tao-session/${SESSION_ID}/`
3. Escrever reads.log dentro do diretório da sessão
4. Exportar SESSION_ID para enforcement-hook usar
5. Cleanup: remover diretórios de sessão com mais de 24h na inicialização

## Critérios de Aceite
- [ ] Cada sessão tem diretório isolado
- [ ] Sessões paralelas não interferem
- [ ] Sessões antigas (>24h) são limpas automaticamente
- [ ] enforcement-hook.sh usa SESSION_ID corretamente
