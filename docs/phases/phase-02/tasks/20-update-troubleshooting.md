# T20 — Atualizar Troubleshooting do README

## Objetivo
Corrigir seção Troubleshooting para refletir enforcement real pós-correção.

## Contexto
- Seção "Agent ignores rules" diz "the commit is rejected"
- Pós T01-T07, isso será verdade para mais cenários
- Precisa listar quais violações são bloqueadas em L0, quais em L1, quais em L2

## Arquivos a Modificar
- `README.md` — seção Troubleshooting
- `README.pt-br.md` — seção Troubleshooting

## Passos
1. Reescrever "Agent ignores rules" com tabela de enforcement por camada
2. Adicionar novos cenários de troubleshooting para os gates adicionados (T01-T05)

## Critérios de Aceite
- [ ] Cada gate listado com camada (L0/L1/L2)
- [ ] Não promete bloqueio para L2
- [ ] EN e PT-BR consistentes
