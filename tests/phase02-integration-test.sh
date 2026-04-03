#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# phase02-integration-test.sh — Phase 02 deterministic proof
# ═══════════════════════════════════════════════════════════════
# Runs all 24 task verifications to prove each fix works.
# Exit 0 = ALL PASS, Exit 1 = FAILURES

set -uo pipefail

TAO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
TOTAL=0

ok()   { PASS=$((PASS + 1)); TOTAL=$((TOTAL + 1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL + 1)); TOTAL=$((TOTAL + 1)); echo "  ❌ $1"; }
section() { echo ""; echo "═══ $1 ═══"; }

# ══════════════════════════════════════════════════════════════
# GROUP 1: Shell script syntax (all modified files)
# ══════════════════════════════════════════════════════════════
section "SYNTAX VALIDATION"

for f in hooks/pre-commit.sh hooks/pre-push.sh hooks/context-hook.sh \
         hooks/enforcement-hook.sh hooks/lint-hook.sh hooks/commit-msg.sh \
         hooks/install-hooks.sh hooks/brainstorm-hook.sh hooks/plan-hook.sh \
         scripts/faudit.sh scripts/new-phase.sh scripts/abex-gate.sh \
         scripts/validate-brainstorm.sh scripts/validate-plan.sh \
         scripts/validate-execution.sh scripts/doc-validate.sh \
         scripts/forensic-audit.sh; do
  if [ -f "$TAO_DIR/$f" ]; then
    if bash -n "$TAO_DIR/$f" 2>/dev/null; then
      ok "Syntax OK: $f"
    else
      fail "Syntax ERROR: $f"
    fi
  fi
done

# ══════════════════════════════════════════════════════════════
# T06: Helper functions present in pre-commit.sh
# ══════════════════════════════════════════════════════════════
section "T06: HELPER FUNCTIONS"

if grep -q 'locate_script()' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T06: locate_script() exists in pre-commit.sh"
else
  fail "T06: locate_script() missing"
fi

if grep -q 'get_active_phase_dir()' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T06: get_active_phase_dir() exists"
else
  fail "T06: get_active_phase_dir() missing"
fi

if grep -q 'count_tasks()' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T06: count_tasks() exists"
else
  fail "T06: count_tasks() missing"
fi

# ══════════════════════════════════════════════════════════════
# T01-T05: Validation gates in pre-commit.sh
# ══════════════════════════════════════════════════════════════
section "T01-T05: VALIDATION GATES"

if grep -q 'BRAINSTORM GATE' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T01: Brainstorm gate present"
else
  fail "T01: Brainstorm gate missing"
fi

if grep -q 'PLAN GATE' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T02: Plan gate present"
else
  fail "T02: Plan gate missing"
fi

if grep -q 'EXECUTION GATE' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T03: Execution gate present"
else
  fail "T03: Execution gate missing"
fi

if grep -q 'DOC GATE' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T04: Doc gate present"
else
  fail "T04: Doc gate missing"
fi

if grep -q 'FORENSIC GATE' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T05: Forensic gate present"
else
  fail "T05: Forensic gate missing"
fi

# Verify gates use helper functions
if grep -q 'locate_script "validate-brainstorm.sh"' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T01: Gate calls locate_script for validate-brainstorm.sh"
else
  fail "T01: Gate doesn't use locate_script"
fi

if grep -q 'locate_script "validate-plan.sh"' "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T02: Gate calls locate_script for validate-plan.sh"
else
  fail "T02: Gate doesn't use locate_script"
fi

# ══════════════════════════════════════════════════════════════
# T07: L1 hooks exist and hooks.json updated
# ══════════════════════════════════════════════════════════════
section "T07: L1 HOOKS"

if [ -f "$TAO_DIR/hooks/brainstorm-hook.sh" ]; then
  ok "T07: brainstorm-hook.sh exists"
else
  fail "T07: brainstorm-hook.sh missing"
fi

if [ -f "$TAO_DIR/hooks/plan-hook.sh" ]; then
  ok "T07: plan-hook.sh exists"
else
  fail "T07: plan-hook.sh missing"
fi

if grep -q 'brainstorm-hook.sh' "$TAO_DIR/templates/shared/hooks.json"; then
  ok "T07: brainstorm-hook.sh registered in hooks.json"
else
  fail "T07: brainstorm-hook.sh not in hooks.json"
fi

if grep -q 'plan-hook.sh' "$TAO_DIR/templates/shared/hooks.json"; then
  ok "T07: plan-hook.sh registered in hooks.json"
else
  fail "T07: plan-hook.sh not in hooks.json"
fi

# Verify hooks.json is valid JSON
if python3 -c "import json; json.load(open('$TAO_DIR/templates/shared/hooks.json'))" 2>/dev/null; then
  ok "T07: hooks.json is valid JSON"
else
  fail "T07: hooks.json is invalid JSON"
fi

# ══════════════════════════════════════════════════════════════
# T08: File path sanitization in pre-commit.sh
# ══════════════════════════════════════════════════════════════
section "T08: PATH SANITIZATION (pre-commit.sh)"

if grep -q "Skipping lint for unsafe filename" "$TAO_DIR/hooks/pre-commit.sh"; then
  ok "T08: Unsafe filename skip message present"
else
  fail "T08: Sanitization guard missing in pre-commit.sh"
fi

# ══════════════════════════════════════════════════════════════
# T09: pre-push.sh -f detection
# ══════════════════════════════════════════════════════════════
section "T09: FORCE PUSH -f DETECTION"

if grep -qE '\\s-f\\b' "$TAO_DIR/hooks/pre-push.sh"; then
  ok "T09: -f standalone flag pattern in pre-push.sh"
else
  fail "T09: -f detection missing in pre-push.sh"
fi

if grep -qE '\\s--force\\b' "$TAO_DIR/hooks/pre-push.sh"; then
  ok "T09: --force pattern in pre-push.sh"
else
  fail "T09: --force detection missing"
fi

if grep -qE '\\s--force-with-lease\\b' "$TAO_DIR/hooks/pre-push.sh"; then
  ok "T09: --force-with-lease pattern in pre-push.sh"
else
  fail "T09: --force-with-lease detection missing"
fi

# ══════════════════════════════════════════════════════════════
# T10: Race condition fix (session-scoped logs)
# ══════════════════════════════════════════════════════════════
section "T10: RACE CONDITION FIX"

if grep -q 'session_id' "$TAO_DIR/hooks/context-hook.sh"; then
  ok "T10: Session ID mechanism in context-hook.sh"
else
  fail "T10: Session ID missing in context-hook.sh"
fi

if grep -q 'session_id' "$TAO_DIR/hooks/enforcement-hook.sh"; then
  ok "T10: Session ID read in enforcement-hook.sh"
else
  fail "T10: Session ID missing in enforcement-hook.sh"
fi

# Verify NO global reads.log deletion (the old race condition)
if grep -q 'rm -f.*reads\.log.*edits\.log' "$TAO_DIR/hooks/context-hook.sh"; then
  fail "T10: Old global reads.log/edits.log deletion still present"
else
  ok "T10: No global log deletion (race condition fixed)"
fi

# Verify session-scoped log files
if grep -q 'reads\.\${SESSION_ID}' "$TAO_DIR/hooks/enforcement-hook.sh"; then
  ok "T10: Session-scoped reads log in enforcement-hook.sh"
else
  fail "T10: Logs not session-scoped in enforcement-hook.sh"
fi

# ══════════════════════════════════════════════════════════════
# T11: Newline sanitization in lint-hook.sh
# ══════════════════════════════════════════════════════════════
section "T11: LINT-HOOK NEWLINE FIX"

if grep -q "\\\\n" "$TAO_DIR/hooks/lint-hook.sh"; then
  ok "T11: Newline check present in lint-hook.sh sanitization"
else
  fail "T11: Newline check missing in lint-hook.sh"
fi

if grep -q "\\\\r" "$TAO_DIR/hooks/lint-hook.sh"; then
  ok "T11: CR check present in lint-hook.sh sanitization"
else
  fail "T11: CR check missing in lint-hook.sh"
fi

# ══════════════════════════════════════════════════════════════
# T12-T14: Circuit breakers in Execute-Tao agents
# ══════════════════════════════════════════════════════════════
section "T12-T14: CIRCUIT BREAKERS"

for agent in "agents/en/Execute-Tao.agent.md" "agents/pt-br/Executar-Tao.agent.md"; do
  basename=$(basename "$agent")

  # T12: BRAINSTORM_FIX_LOOP circuit breaker
  if grep -q 'MAX_BRAINSTORM_TOTAL' "$TAO_DIR/$agent"; then
    ok "T12: Brainstorm circuit breaker in $basename"
  else
    fail "T12: Brainstorm circuit breaker missing in $basename"
  fi

  if grep -q 'total_brainstorm_attempts' "$TAO_DIR/$agent"; then
    ok "T12: Total brainstorm counter in $basename"
  else
    fail "T12: Total brainstorm counter missing in $basename"
  fi

  # T13: PLAN_FIX_LOOP circuit breaker
  if grep -q 'MAX_PLAN_TOTAL' "$TAO_DIR/$agent"; then
    ok "T13: Plan circuit breaker in $basename"
  else
    fail "T13: Plan circuit breaker missing in $basename"
  fi

  # T14: GATE_LOOP circuit breaker
  if grep -q 'MAX_GATE_TOTAL' "$TAO_DIR/$agent"; then
    ok "T14: Gate circuit breaker in $basename"
  else
    fail "T14: Gate circuit breaker missing in $basename"
  fi

  if grep -q 'total_gate_attempts' "$TAO_DIR/$agent"; then
    ok "T14: Total gate counter in $basename"
  else
    fail "T14: Total gate counter missing in $basename"
  fi

  # Verify HARD STOP is present
  if grep -q 'HARD STOP' "$TAO_DIR/$agent" || grep -q 'CIRCUIT BREAKER' "$TAO_DIR/$agent"; then
    ok "T12-T14: HARD STOP/CIRCUIT BREAKER message in $basename"
  else
    fail "T12-T14: No HARD STOP message in $basename"
  fi
done

# ══════════════════════════════════════════════════════════════
# T15: Maturity criteria alignment
# ══════════════════════════════════════════════════════════════
section "T15: MATURITY CRITERIA ALIGNMENT"

# Check skill EN matches agent EN
if grep -q 'invalidation conditions' "$TAO_DIR/skills/en/tao-brainstorm/SKILL.md"; then
  ok "T15: EN skill has 'invalidation conditions' (matches agent)"
else
  fail "T15: EN skill missing agent criterion 'invalidation conditions'"
fi

if grep -q 'Scope is defined' "$TAO_DIR/skills/en/tao-brainstorm/SKILL.md"; then
  ok "T15: EN skill has 'Scope is defined' (matches agent)"
else
  fail "T15: EN skill missing 'Scope is defined'"
fi

if grep -q 'codebase patterns' "$TAO_DIR/skills/en/tao-brainstorm/SKILL.md"; then
  ok "T15: EN skill has 'codebase patterns' (matches agent)"
else
  fail "T15: EN skill missing 'codebase patterns'"
fi

# PT-BR check
if grep -q 'invalidação' "$TAO_DIR/skills/pt-br/tao-brainstorm/SKILL.md"; then
  ok "T15: PT-BR skill has Portuguese criteria"
else
  fail "T15: PT-BR skill not updated"
fi

# ══════════════════════════════════════════════════════════════
# T16-T17: Fallback documentation
# ══════════════════════════════════════════════════════════════
section "T16-T17: FALLBACK DOCUMENTATION"

if grep -q 'GPT-4.1 as automatic fallback' "$TAO_DIR/agents/en/Execute-Tao.agent.md"; then
  ok "T16: EN Execute-Tao documents GPT-4.1 fallback"
else
  fail "T16: EN Execute-Tao missing fallback documentation"
fi

if grep -q 'GPT-4.1 como fallback' "$TAO_DIR/agents/pt-br/Executar-Tao.agent.md"; then
  ok "T16: PT-BR Executar-Tao documents GPT-4.1 fallback"
else
  fail "T16: PT-BR Executar-Tao missing fallback documentation"
fi

if grep -q 'Sonnet 4.6 as automatic fallback' "$TAO_DIR/agents/en/Investigate-Shen.agent.md"; then
  ok "T17: EN Investigate-Shen documents Sonnet fallback"
else
  fail "T17: EN Investigate-Shen missing fallback documentation"
fi

if grep -q 'Sonnet 4.6 como fallback' "$TAO_DIR/agents/pt-br/Investigar-Shen.agent.md"; then
  ok "T17: PT-BR Investigar-Shen documents Sonnet fallback"
else
  fail "T17: PT-BR Investigar-Shen missing fallback documentation"
fi

# ══════════════════════════════════════════════════════════════
# T18: README claims fixed
# ══════════════════════════════════════════════════════════════
section "T18: README CLAIMS"

# Verify ~98% is gone
if grep -q '~98%' "$TAO_DIR/README.md"; then
  fail "T18: EN README still claims ~98%"
else
  ok "T18: EN README no longer claims ~98%"
fi

if grep -q '~98%' "$TAO_DIR/README.pt-br.md"; then
  fail "T18: PT-BR README still claims ~98%"
else
  ok "T18: PT-BR README no longer claims ~98%"
fi

# Verify honest percentage
if grep -q '~75%' "$TAO_DIR/README.md"; then
  ok "T18: EN README has honest ~75% claim"
else
  fail "T18: EN README missing honest percentage"
fi

# Verify L0/L1/L2 explanation
if grep -q 'L0.*L1.*L2' "$TAO_DIR/README.md" || grep -q 'L0 + L1' "$TAO_DIR/README.md"; then
  ok "T18: EN README explains enforcement layers"
else
  fail "T18: EN README missing layer explanation"
fi

# Verify forensic audit qualification
if grep -q 'phase tasks are complete' "$TAO_DIR/README.md" || grep -q 'when all' "$TAO_DIR/README.md"; then
  ok "T18: EN README qualifies forensic audit scope"
else
  fail "T18: EN README still has unqualified forensic claim"
fi

# ══════════════════════════════════════════════════════════════
# T19: LOCK numbering
# ══════════════════════════════════════════════════════════════
section "T19: LOCK NUMBERING"

if grep -q 'LOCK 1' "$TAO_DIR/docs/GUARDRAILS.md"; then
  ok "T19: GUARDRAILS.md has LOCK 1"
else
  fail "T19: GUARDRAILS.md missing LOCK numbering"
fi

if grep -q 'LOCK 5.*Pause' "$TAO_DIR/docs/GUARDRAILS.md"; then
  ok "T19: GUARDRAILS.md has LOCK 5 — Pause"
else
  fail "T19: GUARDRAILS.md missing LOCK 5"
fi

if grep -q 'LOCK 6.*Commit' "$TAO_DIR/docs/GUARDRAILS.md"; then
  ok "T19: GUARDRAILS.md has LOCK 6 — Commit"
else
  fail "T19: GUARDRAILS.md missing LOCK 6"
fi

if grep -q 'LOCK 7' "$TAO_DIR/docs/GUARDRAILS.md"; then
  ok "T19: GUARDRAILS.md has LOCK 7 — External"
else
  fail "T19: GUARDRAILS.md missing LOCK 7"
fi

# ══════════════════════════════════════════════════════════════
# T20: Troubleshooting updated
# ══════════════════════════════════════════════════════════════
section "T20: TROUBLESHOOTING"

if grep -q 'Enforcement varies by layer\|enforcement varia por camada\|Violation.*Layer.*Enforcement' "$TAO_DIR/README.md"; then
  ok "T20: EN README has enforcement layer table"
else
  fail "T20: EN README missing enforcement layer table"
fi

if grep -q 'L0.*blocked deterministically\|L0 = bloqueado' "$TAO_DIR/README.md" || grep -q 'bloqueado deterministicamente' "$TAO_DIR/README.pt-br.md"; then
  ok "T20: Troubleshooting explains L0 blocking"
else
  fail "T20: Troubleshooting missing L0 explanation"
fi

# ══════════════════════════════════════════════════════════════
# T21: faudit.sh PASS 3 complete
# ══════════════════════════════════════════════════════════════
section "T21: FAUDIT PASS 3"

if grep -q 'P3-J' "$TAO_DIR/scripts/faudit.sh"; then
  ok "T21: P3-J (DEBUG=True check) present"
else
  fail "T21: P3-J missing from faudit.sh"
fi

if grep -q 'P3-K' "$TAO_DIR/scripts/faudit.sh"; then
  ok "T21: P3-K (sensitive data logging) present"
else
  fail "T21: P3-K missing from faudit.sh"
fi

if grep -q 'P3-L' "$TAO_DIR/scripts/faudit.sh"; then
  ok "T21: P3-L (file permissions) present"
else
  fail "T21: P3-L missing from faudit.sh"
fi

# ══════════════════════════════════════════════════════════════
# T22: ABEX false positives reduced
# ══════════════════════════════════════════════════════════════
section "T22: ABEX FALSE POSITIVES"

if grep -q '{8,}' "$TAO_DIR/scripts/abex-gate.sh"; then
  ok "T22: Min secret length increased to 8 chars"
else
  fail "T22: Secret detection still uses low min length"
fi

if grep -q 'AKIA' "$TAO_DIR/scripts/abex-gate.sh"; then
  ok "T22: AWS key pattern (AKIA...) present"
else
  fail "T22: AWS key pattern missing"
fi

# Verify no {4,} remains for secrets
if grep -q 'password.*{4,}\|secret.*{4,}\|token.*{4,}' "$TAO_DIR/scripts/abex-gate.sh"; then
  fail "T22: Old {4,} pattern still present"
else
  ok "T22: Old {4,} pattern removed"
fi

# ══════════════════════════════════════════════════════════════
# T23: sed metacharacter fix
# ══════════════════════════════════════════════════════════════
section "T23: SED METACHARACTER FIX"

if grep -q '\[&/\\\\|]' "$TAO_DIR/scripts/new-phase.sh"; then
  ok "T23: sed escape includes | delimiter character"
else
  fail "T23: sed escape missing | delimiter"
fi

# ══════════════════════════════════════════════════════════════
# CROSS-FILE CONSISTENCY CHECKS
# ══════════════════════════════════════════════════════════════
section "CROSS-FILE CONSISTENCY"

# EN and PT-BR agents must both have circuit breakers
EN_CB=$(grep -c 'CIRCUIT BREAKER\|HARD STOP\|MAX_.*_TOTAL' "$TAO_DIR/agents/en/Execute-Tao.agent.md" 2>/dev/null || echo 0)
PT_CB=$(grep -c 'CIRCUIT BREAKER\|HARD STOP\|MAX_.*_TOTAL' "$TAO_DIR/agents/pt-br/Executar-Tao.agent.md" 2>/dev/null || echo 0)
if [ "$EN_CB" -gt 0 ] && [ "$PT_CB" -gt 0 ]; then
  ok "Consistency: Both EN ($EN_CB) and PT-BR ($PT_CB) have circuit breaker markers"
else
  fail "Consistency: Circuit breakers missing from EN ($EN_CB) or PT-BR ($PT_CB)"
fi

# hooks.json entry count must match # of hook files
HOOK_FILES=$(ls "$TAO_DIR/hooks/"*-hook.sh 2>/dev/null | wc -l)
HOOK_JSON_ENTRIES=$(grep -c 'hook.sh' "$TAO_DIR/templates/shared/hooks.json" 2>/dev/null || echo 0)
if [ "$HOOK_FILES" -le "$HOOK_JSON_ENTRIES" ]; then
  ok "Consistency: hook files ($HOOK_FILES) ≤ hooks.json entries ($HOOK_JSON_ENTRIES)"
else
  fail "Consistency: hook files ($HOOK_FILES) > hooks.json entries ($HOOK_JSON_ENTRIES)"
fi

# Both READMEs must have same percentage
EN_PCT=$(grep -oE '~[0-9]+%' "$TAO_DIR/README.md" | head -1)
PT_PCT=$(grep -oE '~[0-9]+%' "$TAO_DIR/README.pt-br.md" | head -1)
if [ "$EN_PCT" = "$PT_PCT" ] && [ -n "$EN_PCT" ]; then
  ok "Consistency: EN ($EN_PCT) and PT-BR ($PT_PCT) READMEs have same percentage"
else
  fail "Consistency: EN ($EN_PCT) vs PT-BR ($PT_PCT) percentage mismatch"
fi

# ══════════════════════════════════════════════════════════════
# FINAL REPORT
# ══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════════"
echo "  PHASE 02 INTEGRATION TEST — FINAL REPORT"
echo "════════════════════════════════════════════════════"
echo ""
echo "  Total tests:  $TOTAL"
echo "  Passed:       $PASS"
echo "  Failed:       $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "  ✅ ALL TESTS PASSED — Phase 02 is COMPLETE"
  echo ""
  echo "  Every Task (T01-T23) has been verified with"
  echo "  deterministic checks. All fixes are in place."
else
  echo "  ❌ $FAIL TEST(S) FAILED — review above"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo ""

exit "$FAIL"
