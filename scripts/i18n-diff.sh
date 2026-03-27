#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# i18n-diff.sh — Compare EN vs PT-BR templates for drift
# ═══════════════════════════════════════════════════════════════
# Compares file pairs between EN and PT-BR directories.
# Reports missing files, size drift, and structural differences.
# Usage: ./i18n-diff.sh [--verbose]

set -euo pipefail

WORKSPACE_DIR="${TAO_WORKSPACE_DIR:-$(pwd)}"

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

VERBOSE=false
if [[ "${1:-}" == "--verbose" ]]; then
  VERBOSE=true
fi

# ── i18n name equivalences (intentional renames between languages) ──
# Format: "en_name=ptbr_name" — these are NOT missing/orphan, just renamed
I18N_EQUIV=(
  "Shen-Architect.agent.md=Shen-Arquiteto.agent.md"
  "task.md.template=tarefa.md.template"
  "task.md=tarefa.md"
)

# Check if a file has a known equivalent in the other language
has_equivalent() {
  local filename="$1"
  local direction="$2"  # "en2pt" or "pt2en"
  for eq in "${I18N_EQUIV[@]}"; do
    local en_name="${eq%%=*}"
    local pt_name="${eq##*=}"
    if [[ "$direction" == "en2pt" && "$(basename "$filename")" == "$en_name" ]]; then
      return 0
    fi
    if [[ "$direction" == "pt2en" && "$(basename "$filename")" == "$pt_name" ]]; then
      return 0
    fi
  done
  return 1
}

# ── Directories to compare ──
PAIRS=(
  "templates/en:templates/pt-br"
  "agents/en:agents/pt-br"
  "phases/en:phases/pt-br"
)

TOTAL_CHECKED=0
TOTAL_MISSING=0
TOTAL_DRIFT=0
TOTAL_OK=0

echo -e "${CYAN}═══ TAO i18n Drift Report ═══${NC}"
echo ""

for pair in "${PAIRS[@]}"; do
  EN_DIR="$WORKSPACE_DIR/${pair%%:*}"
  PT_DIR="$WORKSPACE_DIR/${pair##*:}"

  en_label="${pair%%:*}"
  pt_label="${pair##*:}"

  echo -e "${CYAN}── $en_label ↔ $pt_label ──${NC}"

  if [ ! -d "$EN_DIR" ]; then
    echo -e "  ${RED}MISSING${NC} EN dir: $en_label"
    TOTAL_MISSING=$((TOTAL_MISSING + 1))
    continue
  fi

  if [ ! -d "$PT_DIR" ]; then
    echo -e "  ${RED}MISSING${NC} PT-BR dir: $pt_label"
    TOTAL_MISSING=$((TOTAL_MISSING + 1))
    continue
  fi

  # List files in EN
  while IFS= read -r en_file; do
    rel_path="${en_file#$EN_DIR/}"
    pt_file="$PT_DIR/$rel_path"
    TOTAL_CHECKED=$((TOTAL_CHECKED + 1))

    if [ ! -f "$pt_file" ]; then
      if has_equivalent "$en_file" "en2pt"; then
        if $VERBOSE; then
          echo -e "  ${GREEN}EQUIV${NC} $rel_path — known i18n rename"
        fi
        TOTAL_OK=$((TOTAL_OK + 1))
      else
        echo -e "  ${RED}MISSING${NC} $rel_path — exists in EN, not in PT-BR"
        TOTAL_MISSING=$((TOTAL_MISSING + 1))
      fi
      continue
    fi

    # Compare line counts
    en_lines=$(wc -l < "$en_file")
    pt_lines=$(wc -l < "$pt_file")

    # Calculate drift percentage
    if [ "$en_lines" -eq 0 ]; then
      drift_pct=0
    else
      drift_pct=$(( (pt_lines - en_lines) * 100 / en_lines ))
      # Absolute value
      if [ "$drift_pct" -lt 0 ]; then
        drift_pct=$(( -drift_pct ))
      fi
    fi

    # Compare section headers (## lines) as structural check
    en_headers=$(grep -c '^##' "$en_file" 2>/dev/null || echo "0")
    pt_headers=$(grep -c '^##' "$pt_file" 2>/dev/null || echo "0")

    header_match=true
    if [ "$en_headers" != "$pt_headers" ]; then
      header_match=false
    fi

    if [ "$drift_pct" -gt 20 ] || [ "$header_match" = false ]; then
      TOTAL_DRIFT=$((TOTAL_DRIFT + 1))
      echo -e "  ${YELLOW}DRIFT${NC}  $rel_path"
      echo "         EN: ${en_lines}L / ${en_headers} sections"
      echo "         PT: ${pt_lines}L / ${pt_headers} sections"
      echo "         Drift: ${drift_pct}%"
      if [ "$header_match" = false ]; then
        echo "         ⚠ Section count mismatch (EN:${en_headers} vs PT:${pt_headers})"
      fi
    else
      TOTAL_OK=$((TOTAL_OK + 1))
      if $VERBOSE; then
        echo -e "  ${GREEN}OK${NC}     $rel_path (EN:${en_lines}L PT:${pt_lines}L drift:${drift_pct}%)"
      fi
    fi

  done < <(find "$EN_DIR" -type f | sort)

  # Check for PT-BR files without EN counterpart
  while IFS= read -r pt_file; do
    rel_path="${pt_file#$PT_DIR/}"
    en_file="$EN_DIR/$rel_path"

    if [ ! -f "$en_file" ]; then
      if has_equivalent "$pt_file" "pt2en"; then
        if $VERBOSE; then
          echo -e "  ${GREEN}EQUIV${NC} $rel_path — known i18n rename"
        fi
      else
        echo -e "  ${RED}ORPHAN${NC} $rel_path — exists in PT-BR, not in EN"
        TOTAL_MISSING=$((TOTAL_MISSING + 1))
      fi
    fi
  done < <(find "$PT_DIR" -type f | sort)

  echo ""
done

# ── Summary ──
echo -e "${CYAN}═══ Summary ═══${NC}"
echo "  Files checked:  $TOTAL_CHECKED"
echo -e "  ${GREEN}OK:${NC}             $TOTAL_OK"
echo -e "  ${YELLOW}Drift (>20%):${NC}   $TOTAL_DRIFT"
echo -e "  ${RED}Missing/Orphan:${NC} $TOTAL_MISSING"

if [ "$TOTAL_DRIFT" -gt 0 ] || [ "$TOTAL_MISSING" -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}Action needed: review drifted/missing files above.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}All i18n pairs are in sync.${NC}"
  exit 0
fi
