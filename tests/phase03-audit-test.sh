#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# phase03-audit-test.sh — Comprehensive audit verification tests
# ═══════════════════════════════════════════════════════════════
# Verifies ALL fixes applied during Phase 03 scientific audit.
# Each test is deterministic — no judgment, no heuristics.

set -euo pipefail

TAO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$TAO_DIR"

PASS=0
FAIL=0
TOTAL=0

pass() { PASS=$((PASS + 1)); TOTAL=$((TOTAL + 1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL + 1)); TOTAL=$((TOTAL + 1)); echo "  ❌ $1"; }

# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ BUG FIXES — CODE ═══"
# ═══════════════════════════════════════════════════════════════

# B1: enforcement-hook.sh — R0 and R5 use DIFFERENT config lines
echo ""
echo "── B1: enforcement-hook.sh R0/R5 config fix ──"
if grep -q "sed -n '1p'" hooks/enforcement-hook.sh && grep -q "sed -n '2p'" hooks/enforcement-hook.sh; then
  R0_LINE=$(grep "REQUIRE_R0_CHECK=\$(echo" hooks/enforcement-hook.sh | head -1)
  R5_LINE=$(grep "REQUIRE_R5_CHECK=\$(echo" hooks/enforcement-hook.sh | head -1)
  if echo "$R0_LINE" | grep -q "1p" && echo "$R5_LINE" | grep -q "2p"; then
    pass "B1: R0 reads line 1, R5 reads line 2 (independent)"
  else
    fail "B1: R0 and R5 still read same line"
  fi
else
  fail "B1: sed lines not found"
fi

# B1b: Python now outputs 3 lines (R0, R5, R3)
if grep -q "require_read_before_edit" hooks/enforcement-hook.sh; then
  pass "B1b: R5 uses own config flag (require_read_before_edit)"
else
  fail "B1b: R5 does not use own config flag"
fi

# B2: enforcement-hook.sh — R5 no longer uses basename collision
echo ""
echo "── B2: enforcement-hook.sh R5 basename fix ──"
if grep -q 'grep -qF "$FILE_BASENAME" "$READS_LOG"' hooks/enforcement-hook.sh; then
  fail "B2: R5 still uses basename matching"
else
  pass "B2: R5 no longer uses bare basename matching"
fi
if grep -q '_rel_path=' hooks/enforcement-hook.sh; then
  pass "B2b: R5 uses relative path fallback"
else
  fail "B2b: R5 missing relative path fallback"
fi

# B3: pre-commit.sh — Validates lint command from config
echo ""
echo "── B3: pre-commit.sh lint command validation ──"
if grep -q "T08b" hooks/pre-commit.sh; then
  pass "B3: Lint command validation added (T08b)"
else
  fail "B3: Lint command validation missing"
fi

# B4: lint-hook.sh — Validates lint command from config
echo ""
echo "── B4: lint-hook.sh lint command validation ──"
if grep -q 'LINT_CMD.*=~' hooks/lint-hook.sh; then
  pass "B4: Lint command validation in lint-hook.sh"
else
  fail "B4: Lint command validation missing in lint-hook.sh"
fi

# B5: install.sh — pt-br uses tarefas/ not tasks/
echo ""
echo "── B5: install.sh pt-br tarefas dir ──"
if grep -q '_tasks_dir="tarefas"' install.sh; then
  pass "B5: pt-br creates tarefas/ directory"
else
  fail "B5: pt-br still creates tasks/ directory"
fi
if grep -q 'INITIAL_PHASE_DIR/\$_tasks_dir' install.sh; then
  pass "B5b: Uses variable for tasks dir name"
else
  fail "B5b: Hardcoded tasks/ directory"
fi

# B6: tao.sh — unpause removes both .tao-pause and .gsd-pause
echo ""
echo "── B6: tao.sh unpause legacy fix ──"
if grep -q 'rm -f "$PAUSE_FILE" "$PAUSE_FILE_LEGACY"' tao.sh; then
  pass "B6: Unpause removes both pause files"
else
  fail "B6: Unpause only removes one pause file"
fi

# B7: tao.sh — dead check_pause() removed
echo ""
echo "── B7: tao.sh dead code removal ──"
if grep -q "check_pause()" tao.sh; then
  fail "B7: Dead check_pause() function still exists"
else
  pass "B7: Dead check_pause() function removed"
fi

# B8: update-models.sh — dead code impossible condition
echo ""
echo "── B8: update-models.sh dead code fix ──"
if grep -q "not line.strip().startswith" scripts/update-models.sh; then
  fail "B8: Impossible condition still exists"
else
  pass "B8: Dead code impossible condition removed"
fi

# B9: faudit.sh — FINAL VERDICT message
echo ""
echo "── B9: faudit.sh verdict message fix ──"
if grep -q 'across ${TOTAL_BLOCKS} pass(es)' scripts/faudit.sh; then
  fail "B9: Wrong TOTAL_BLOCKS in verdict message"
else
  pass "B9: Verdict message fixed"
fi

# B10: tao.sh — dry-run checks Executor column specifically
echo ""
echo "── B10: tao.sh dry-run executor check ──"
if grep -q '_executor=.*awk.*-F' tao.sh; then
  pass "B10: Dry-run checks Executor column via awk"
else
  fail "B10: Dry-run still uses grep on whole line"
fi

# B11: pre-push.sh — unused variables prefixed with _
echo ""
echo "── B11: pre-push.sh dead variables ──"
if grep -q '_local_ref _local_sha remote_ref _remote_sha' hooks/pre-push.sh; then
  pass "B11: Unused vars prefixed with underscore"
else
  fail "B11: Unused vars not prefixed"
fi

# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ SECURITY FIXES ═══"
# ═══════════════════════════════════════════════════════════════

# S1: Python injection — no more open('$VAR') in inline Python
echo ""
echo "── S1: Python injection fix ──"
INJECTION_COUNT=0
for f in scripts/faudit.sh scripts/forensic-audit.sh scripts/validate-brainstorm.sh scripts/doc-validate.sh; do
  c=$(grep -c "open('\\\$" "$f" 2>/dev/null || true)
  c="${c// /}"
  [ -z "$c" ] && c=0
  INJECTION_COUNT=$((INJECTION_COUNT + c))
done
if [ "$INJECTION_COUNT" -eq 0 ]; then
  pass "S1: Zero open('\$VAR') patterns remaining (4 files clean)"
else
  fail "S1: ${INJECTION_COUNT} open('\$VAR') patterns still exist"
fi

# S2: All Python file reading uses sys.argv
echo ""
echo "── S2: sys.argv usage ──"
for f in scripts/faudit.sh scripts/forensic-audit.sh scripts/validate-brainstorm.sh scripts/doc-validate.sh; do
  if grep -q "open(sys.argv" "$f"; then
    pass "S2: $(basename $f) uses sys.argv for file paths"
  else
    fail "S2: $(basename $f) does NOT use sys.argv"
  fi
done

# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ DOCUMENTATION FIXES ═══"
# ═══════════════════════════════════════════════════════════════

# D1: RULES.md EN has 7 LOCKs
echo ""
echo "── D1: RULES.md LOCKs ──"
EN_LOCKS=$(grep -c "LOCK [0-9]" templates/en/RULES.md 2>/dev/null || echo 0)
PTBR_LOCKS=$(grep -c "LOCK [0-9]" templates/pt-br/RULES.md 2>/dev/null || echo 0)
if [ "$EN_LOCKS" -ge 7 ]; then
  pass "D1: RULES.md EN has $EN_LOCKS LOCKs (>=7)"
else
  fail "D1: RULES.md EN has only $EN_LOCKS LOCKs"
fi
if [ "$PTBR_LOCKS" -ge 7 ]; then
  pass "D1b: RULES.md PT-BR has $PTBR_LOCKS LOCKs (>=7)"
else
  fail "D1b: RULES.md PT-BR has only $PTBR_LOCKS LOCKs"
fi

# D2: copilot-instructions.md has 7 LOCKs
echo ""
echo "── D2: copilot-instructions.md LOCKs ──"
EN_CI_LOCKS=$(grep -c "LOCK [0-9]" templates/en/copilot-instructions.md 2>/dev/null || echo 0)
PTBR_CI_LOCKS=$(grep -c "LOCK [0-9]" templates/pt-br/copilot-instructions.md 2>/dev/null || echo 0)
if [ "$EN_CI_LOCKS" -ge 7 ]; then
  pass "D2: copilot-instructions.md EN has $EN_CI_LOCKS LOCKs (>=7)"
else
  fail "D2: copilot-instructions.md EN has only $EN_CI_LOCKS LOCKs"
fi
if [ "$PTBR_CI_LOCKS" -ge 7 ]; then
  pass "D2b: copilot-instructions.md PT-BR has $PTBR_CI_LOCKS LOCKs (>=7)"
else
  fail "D2b: copilot-instructions.md PT-BR has only $PTBR_CI_LOCKS LOCKs"
fi

# D3: doc-sync.sh references removed
echo ""
echo "── D3: doc-sync.sh phantom removed ──"
DOC_SYNC_REFS=$(grep -rl "doc-sync\.sh" install.sh tao.config.json.example docs/ARCHITECTURE.md docs/GETTING-STARTED.md 2>/dev/null || true)
if [ -z "$DOC_SYNC_REFS" ]; then
  pass "D3: Zero doc-sync.sh references in critical files"
else
  fail "D3: Files still reference doc-sync.sh: $DOC_SYNC_REFS"
fi

# D4: GUARDRAILS.md ABEX description updated
echo ""
echo "── D4: GUARDRAILS.md ABEX fix ──"
if grep -q "not a script" docs/GUARDRAILS.md; then
  fail "D4: ABEX still says 'not a script'"
else
  pass "D4: ABEX description corrected"
fi
if grep -q "abex-gate.sh" docs/GUARDRAILS.md; then
  pass "D4b: GUARDRAILS mentions abex-gate.sh"
else
  fail "D4b: GUARDRAILS does not mention abex-gate.sh"
fi

# D5: Maturity gate title
echo ""
echo "── D5: Maturity gate title ──"
if grep -q "7/7)" docs/GUARDRAILS.md; then
  fail "D5: Maturity gate still says '7/7)'"
else
  pass "D5: Maturity gate title fixed"
fi
if grep -q "≥5" docs/GUARDRAILS.md; then
  pass "D5b: Maturity gate shows ≥5 requirement"
else
  fail "D5b: Maturity gate doesn't show ≥5"
fi

# D6: ARCHITECTURE.md version
echo ""
echo "── D6: ARCHITECTURE.md version ──"
if grep -q "Version: 1.0.0" docs/ARCHITECTURE.md; then
  pass "D6: ARCHITECTURE.md version is 1.0.0"
else
  fail "D6: ARCHITECTURE.md version mismatch"
fi

# D7: ARCHITECTURE.md documents all hooks
echo ""
echo "── D7: ARCHITECTURE.md hooks ──"
for hook in "abex-hook" "brainstorm-hook" "plan-hook" "pre-commit" "pre-push" "commit-msg" "install-hooks"; do
  if grep -q "$hook" docs/ARCHITECTURE.md; then
    pass "D7: ARCHITECTURE.md documents $hook"
  else
    fail "D7: ARCHITECTURE.md missing $hook"
  fi
done

# D8: Qi commit format
echo ""
echo "── D8: Qi commit format ──"
if grep -q "phase-XX.*TNN" agents/en/Qi.agent.md; then
  pass "D8: Qi EN has correct commit format with scope"
else
  fail "D8: Qi EN missing scope in commit format"
fi
if grep -q "fase-XX.*TNN" agents/pt-br/Qi.agent.md; then
  pass "D8b: Qi PT-BR has correct commit format with scope"
else
  fail "D8b: Qi PT-BR missing scope in commit format"
fi

# D9: RULES.md PT-BR no duplicate paragraph
echo ""
echo "── D9: RULES.md PT-BR duplicate paragraph ──"
DUP_COUNT=$(grep -c "abex-gate.sh.*realiza.*detecção" templates/pt-br/RULES.md 2>/dev/null || echo 0)
if [ "$DUP_COUNT" -le 1 ]; then
  pass "D9: No duplicate ABEX paragraph in RULES.md PT-BR"
else
  fail "D9: ${DUP_COUNT} copies of ABEX paragraph (should be 1)"
fi

# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══ CROSS-FILE CONSISTENCY ═══"
# ═══════════════════════════════════════════════════════════════

echo ""
echo "── C1: Shell scripts syntax ──"
SYNTAX_ERRORS=0
for f in hooks/*.sh scripts/*.sh tao.sh install.sh; do
  if ! bash -n "$f" 2>/dev/null; then
    fail "C1: Syntax error in $f"
    SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
  fi
done
if [ "$SYNTAX_ERRORS" -eq 0 ]; then
  pass "C1: All 22 shell scripts pass syntax check"
fi

echo ""
echo "── C2: LOCKs parity EN ↔ PT-BR ──"
EN_RULE_LOCKS=$(grep -c "LOCK [0-9]" templates/en/RULES.md 2>/dev/null || echo 0)
PTBR_RULE_LOCKS=$(grep -c "LOCK [0-9]" templates/pt-br/RULES.md 2>/dev/null || echo 0)
if [ "$EN_RULE_LOCKS" -eq "$PTBR_RULE_LOCKS" ]; then
  pass "C2: RULES.md EN ($EN_RULE_LOCKS) = PT-BR ($PTBR_RULE_LOCKS) LOCKs"
else
  fail "C2: RULES.md EN ($EN_RULE_LOCKS) ≠ PT-BR ($PTBR_RULE_LOCKS) LOCKs"
fi

EN_CI_LOCKS=$(grep -c "LOCK [0-9]" templates/en/copilot-instructions.md 2>/dev/null || echo 0)
PTBR_CI_LOCKS=$(grep -c "LOCK [0-9]" templates/pt-br/copilot-instructions.md 2>/dev/null || echo 0)
if [ "$EN_CI_LOCKS" -eq "$PTBR_CI_LOCKS" ]; then
  pass "C2b: copilot-instructions EN ($EN_CI_LOCKS) = PT-BR ($PTBR_CI_LOCKS) LOCKs"
else
  fail "C2b: copilot-instructions EN ($EN_CI_LOCKS) ≠ PT-BR ($PTBR_CI_LOCKS) LOCKs"
fi

echo ""
echo "── C3: Agent parity EN ↔ PT-BR ──"
EN_AGENTS=$(find agents/en -name "*.agent.md" | wc -l)
PTBR_AGENTS=$(find agents/pt-br -name "*.agent.md" | wc -l)
if [ "$EN_AGENTS" -eq "$PTBR_AGENTS" ]; then
  pass "C3: Agent count EN ($EN_AGENTS) = PT-BR ($PTBR_AGENTS)"
else
  fail "C3: Agent count EN ($EN_AGENTS) ≠ PT-BR ($PTBR_AGENTS)"
fi

echo ""
echo "── C4: Skill parity EN ↔ PT-BR ──"
EN_SKILLS=$(find skills/en -type d | wc -l)
PTBR_SKILLS=$(find skills/pt-br -type d | wc -l)
if [ "$EN_SKILLS" -eq "$PTBR_SKILLS" ]; then
  pass "C4: Skill count EN ($EN_SKILLS) = PT-BR ($PTBR_SKILLS)"
else
  fail "C4: Skill count EN ($EN_SKILLS) ≠ PT-BR ($PTBR_SKILLS)"
fi

# ═══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════════"
echo "  PHASE 03 AUDIT TEST — FINAL REPORT"
echo "════════════════════════════════════════════════════"
echo ""
echo "  Total tests:  $TOTAL"
echo "  Passed:       $PASS"
echo "  Failed:       $FAIL"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "  ✅ ALL TESTS PASSED — Audit fixes verified"
else
  echo "  ❌ $FAIL TESTS FAILED — Fixes incomplete"
fi
echo ""
echo "════════════════════════════════════════════════════"
echo ""

[ "$FAIL" -gt 0 ] && exit 1
exit 0
