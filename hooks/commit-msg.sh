#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# commit-msg.sh — Validate TAO commit message format (LOCK 6)
# ═══════════════════════════════════════════════════════════════
# Enforces conventional commit format: type(scope): description
# Called by .git/hooks/commit-msg (installed by install-hooks.sh).
# Exit 0 = allow commit, Exit 1 = block commit.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MSG_FILE="$1"

if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
  exit 0
fi

MSG=$(head -1 "$MSG_FILE")

# Skip empty messages and merge commits
if [ -z "$MSG" ]; then exit 0; fi
if echo "$MSG" | grep -qE '^(Merge|Revert|fixup!|squash!)'; then exit 0; fi

# ─── Format: type(scope): description ────────────────────────
# type = feat|fix|refactor|docs|chore|hotfix|test|perf|ci|build|style
# scope = alphanumeric, dashes, underscores (e.g. phase-01, core, api)
# description = non-empty
PATTERN='^(feat|fix|refactor|docs|chore|hotfix|test|perf|ci|build|style)\([a-zA-Z0-9_.-]+\): .{1,}'

if ! echo "$MSG" | grep -qE "$PATTERN"; then
  echo ""
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: Formato de commit inválido (LOCK 6)${NC}"
  echo ""
  echo -e "${YELLOW}  Esperado / Expected:${NC}"
  echo "    tipo(escopo): descrição"
  echo "    type(scope): description"
  echo ""
  echo -e "${YELLOW}  Tipos válidos / Valid types:${NC}"
  echo "    feat | fix | refactor | docs | chore | hotfix | test | perf | ci | build | style"
  echo ""
  echo -e "${YELLOW}  Exemplos / Examples:${NC}"
  echo "    feat(phase-01): T05 — expand context hook"
  echo "    fix(api): handle null user in auth middleware"
  echo "    docs(readme): add troubleshooting section"
  echo ""
  echo -e "${RED}  Recebido / Got:${NC} $MSG"
  echo ""
  exit 1
fi

# ─── Max 72 chars ────────────────────────────────────────────
if [ "${#MSG}" -gt 72 ]; then
  echo ""
  echo -e "${RED}✗ BLOQUEADO / BLOCKED: Commit message muito longa / too long${NC}"
  echo "  ${#MSG} chars (máximo / max: 72)"
  echo "  $MSG"
  echo ""
  exit 1
fi

echo -e "${GREEN}✓ Commit message OK${NC}"
exit 0
