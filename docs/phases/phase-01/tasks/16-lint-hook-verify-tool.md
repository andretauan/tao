# Task T16 — lint-hook.sh Verify Tool Existence + Warn Empty

**Phase:** 01 — Enforcement Architecture
**Complexity:** Low
**Executor:** Sonnet
**Priority:** P3-INSTALL
**Depends on:** T08

---

## Objective

Add tool existence verification to lint-hook.sh so it doesn't fail silently when a lint command isn't installed, and warn when lint_commands is empty.

## Gaps Fixed

- G29: lint-hook.sh doesn't verify tool exists before calling it

## Files to Read

- `hooks/lint-hook.sh` — current implementation

## Files to Edit

- `hooks/lint-hook.sh` — add verification

## Changes

### 1. Verify tool exists before running

Before executing each lint command, check if the binary exists:

```bash
run_lint_command() {
  local cmd="$1"
  local tool=$(echo "$cmd" | awk '{print $1}')

  # Handle npx/vendor paths
  if [[ "$tool" == "npx" ]]; then
    tool=$(echo "$cmd" | awk '{print $2}')
  fi

  if ! command -v "$tool" &>/dev/null && [[ ! -x "$tool" ]]; then
    echo "⚠️  TAO lint: tool '$tool' not found — skipping: $cmd"
    return 0  # Don't block, just warn
  fi

  eval "$cmd"
}
```

### 2. Warn when lint_commands is empty

```bash
if [[ ${#lint_commands[@]} -eq 0 ]]; then
  echo "⚠️  TAO lint: no lint_commands configured in tao.config.json"
  echo "   Run: configure lint tools in .github/tao/tao.config.json → lint_commands"
fi
```

## Acceptance Criteria

- [ ] Tool existence checked before each lint command
- [ ] Missing tools produce warning (not error)
- [ ] Empty lint_commands produces helpful message
- [ ] Existing lint behavior unchanged when tools are present
