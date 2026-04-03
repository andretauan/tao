# Task T06 — Expand enforcement-hook.sh: Terminal Intercept + R5 Strengthen

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P1-HOOKS (L1)
**Depends on:** None

---

## Objective

Expand enforcement-hook.sh with: (1) terminal command interception to detect dangerous git/shell commands, (2) stronger R5 violation language (BLOCK not warn), (3) read compliance.* config to control behavior.

## Gaps Fixed

- G07: --no-verify/--force not detected
- G11: R5 is warning-only, not block
- G12: No terminal command interception
- G14: compliance.* config decorative

## Files to Read

- `hooks/enforcement-hook.sh` — current implementation (full file)
- `tao.config.json.example` — compliance section

## Files to Edit

- `hooks/enforcement-hook.sh` — add terminal intercept section, strengthen R5, add config reading

## Implementation

### 1. Terminal command interception
Add a new case for `runInTerminal`/`run_in_terminal`:

```bash
case "$TOOL_NAME" in
  runInTerminal|run_in_terminal)
    COMMAND=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input',{}).get('command',''))
except:
    print('')
" 2>/dev/null)
    
    DANGER=""
    if echo "$COMMAND" | grep -qE 'push\s+(origin\s+)?main|push\s+(origin\s+)?master'; then
      DANGER="⚠️ LOCK 2 VIOLATION: Command pushes to main/master. This is FORBIDDEN."
    elif echo "$COMMAND" | grep -qE '\-\-force|force-with-lease'; then
      DANGER="⚠️ LOCK 2 VIOLATION: Force push detected. This is FORBIDDEN."
    elif echo "$COMMAND" | grep -qE '\-\-no-verify'; then
      DANGER="⚠️ LOCK 6 VIOLATION: --no-verify bypasses quality gates. This is FORBIDDEN."
    elif echo "$COMMAND" | grep -qE 'rm\s+-rf\s'; then
      DANGER="⚠️ LOCK 3 VIOLATION: rm -rf detected. This is FORBIDDEN."
    elif echo "$COMMAND" | grep -qiE 'DROP\s+(TABLE|DATABASE)|TRUNCATE\s'; then
      DANGER="⚠️ LOCK 3 VIOLATION: Destructive SQL detected. STOP."
    fi
    
    if [ -n "$DANGER" ]; then
      # Inject block
      SAFE_MSG=$(printf '%s' "$DANGER" | python3 -c "...")
      printf '{"hookSpecificOutput":{...}}\n' "$SAFE_MSG"
    fi
    exit 0
    ;;
esac
```

### 2. Strengthen R5 language
Change from:
```
"⚠️ R5 VIOLATION DETECTED: You edited '${FILE_BASENAME}' without reading it first. You MUST read..."
```
To:
```
"🚫 R5 VIOLATION — STOP ALL EDITING. You edited '${FILE_BASENAME}' WITHOUT reading it first. This is an INVIOLABLE rule. You MUST: 1) STOP editing immediately 2) Read this file NOW with read_file 3) Verify your edit is correct 4) Only then continue. DO NOT proceed with any other edit until this is resolved."
```

### 3. Read compliance config
At top of script, read compliance flags:
```bash
REQUIRE_SKILL_CHECK="true"
if [ -f "$CONFIG_FILE" ]; then
  REQUIRE_SKILL_CHECK=$(python3 -c "..." "$CONFIG_FILE")
fi
```

Use these to conditionally enable checks.

## Acceptance Criteria

- [ ] `git push origin main` via terminal → LOCK 2 violation injected
- [ ] `--force` push via terminal → LOCK 2 violation injected
- [ ] `--no-verify` commit via terminal → LOCK 6 violation injected
- [ ] `rm -rf` via terminal → LOCK 3 violation injected
- [ ] R5 violation message is BLOCK tone (not mild warning)
- [ ] compliance.require_skill_check read from config
- [ ] All existing functionality preserved
