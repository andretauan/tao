# T18 — Corrigir README: ~98% + loop + forensic

## Objetivo
Atualizar ambos os READMEs para refletir a realidade pós-correção, eliminando todas as promessas falsas.

## Contexto
- "~98% enforcement via deterministic automation" → número real pós T01-T07 será ~85-90%
- "Every commit passes through a 3-pass forensic audit" → pós T05, verdade para commits de conclusão de fase
- "runs automatically without pausing" → é protocolo de instruções, não processo de sistema
- "not honor-system" → parcialmente verdadeiro para L0/L1, mas ~10-15% continua L2

## Arquivos a Ler
- `README.md` — seções: Qualidade Blindada, Loop, Design Principles
- `README.pt-br.md` — mesmas seções

## Arquivos a Modificar
- `README.md`
- `README.pt-br.md`

## Passos
1. Calcular % real: contar mecanismos L0 + L1 vs total de promessas enforcement
2. Substituir "~98%" pelo número calculado com nota de rodapé explicando a métrica
3. Qualificar "Every commit passes through forensic audit" → "Phase completion commits..."
4. Qualificar loop: "autonomous instruction sequence followed by the agent" em vez de "runs automatically"
5. Manter "not honor-system" apenas para items que são genuinamente L0/L1
6. Adicionar seção clara explicando as 3 camadas (L0, L1, L2) no README
7. Manter tom persuasivo (é marketing) mas factualmente correto

## Critérios de Aceite
- [ ] Zero promessas falsas
- [ ] Porcentagem baseada em contagem real
- [ ] Loop descrito honestamente
- [ ] Forensic audit com condição real
- [ ] 3 camadas explicadas claramente
- [ ] Tom preservado (persuasivo mas honesto)
- [ ] EN e PT-BR consistentes
