# T22 — Reduzir falsos positivos no abex-gate.sh

## Objetivo
Refinar regexes de detecção de segredos hardcoded para reduzir falsos positivos.

## Contexto
- abex-gate.sh usa padrão `[A-Za-z0-9+/]{4,}` para detectar segredos
- Isso captura QUALQUER string de 4+ caracteres alfanuméricos — taxa de false positive muito alta
- Precisa exigir contexto (prefixo indicativo de secret)

## Arquivos a Ler
- `scripts/abex-gate.sh` — seção de segredos hardcoded

## Arquivos a Modificar
- `scripts/abex-gate.sh`

## Passos
1. Identificar todos os padrões de detecção de segredos
2. Refinar para exigir contexto:
   - `(key|secret|password|token|api_key|apikey|auth)\s*=\s*["'][^"']{8,}["']`
   - `(AWS|AZURE|GCP|GITHUB|SLACK)_[A-Z_]+\s*=`
   - Strings com alta entropia em contexto de atribuição
3. Manter detecção de padrões conhecidos (AWS keys, JWT, etc.)
4. Remover padrão genérico que causa false positives

## Critérios de Aceite
- [ ] Código normal não dispara falso positivo
- [ ] Secrets reais ainda são detectados
- [ ] Taxa de false positive reduzida significativamente
