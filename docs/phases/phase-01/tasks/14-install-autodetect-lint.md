# Task T14 — install.sh Auto-Detect Lint Stack (Replace Q5)

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P3-INSTALL
**Depends on:** None

---

## Objective

Replace the confusing Q5 (which shows option numbers but writes full command names) with automatic lint stack detection. The installer should detect the project's actual lint tools and configure `lint_commands` automatically.

## Gaps Fixed

- G30: Q5 confusing UX (option numbers vs command names mismatch)
- G33: lint_commands populated incorrectly or not at all

## Files to Read

- `install.sh` — current Q5 implementation (~lines 200-280)
- `tao.config.json.example` — lint_commands format

## Files to Edit

- `install.sh` — replace Q5 with auto-detection

## Changes

### 1. Auto-detect lint tools

Replace Q5 with a detection function:

```bash
detect_lint_stack() {
  local detected=()

  # PHP
  [[ -f "vendor/bin/phpstan" ]] && detected+=("phpstan analyse")
  [[ -f "vendor/bin/phpcs" ]] && detected+=("phpcs --standard=PSR12 .")
  [[ -f "vendor/bin/pint" ]] && detected+=("./vendor/bin/pint --test")

  # JavaScript/TypeScript
  [[ -f "node_modules/.bin/eslint" ]] && detected+=("npx eslint .")
  [[ -f "node_modules/.bin/tsc" ]] && detected+=("npx tsc --noEmit")

  # Python
  [[ -f ".flake8" ]] || [[ -f "setup.cfg" ]] && detected+=("flake8 .")
  command -v ruff &>/dev/null && detected+=("ruff check .")
  command -v mypy &>/dev/null && detected+=("mypy .")

  # Rust
  [[ -f "Cargo.toml" ]] && detected+=("cargo clippy" "cargo fmt --check")

  # Go
  [[ -f "go.mod" ]] && detected+=("go vet ./..." "golangci-lint run")

  if [[ ${#detected[@]} -eq 0 ]]; then
    echo "⚠️  No lint tools detected. Enter lint commands manually (comma-separated):"
    read -r manual_input
    # Parse manual input
  else
    echo "✅ Detected lint tools:"
    for tool in "${detected[@]}"; do echo "   - $tool"; done
    echo ""
    echo "Accept? [Y/n] (or enter additional commands)"
    read -r confirm
    # Handle confirmation
  fi
}
```

### 2. Fix the output format

Ensure detected tools write to `lint_commands` as proper JSON array.

### 3. Keep manual fallback

If no tools detected, ask user to enter commands manually with clear instructions.

## Acceptance Criteria

- [ ] Q5 replaced with auto-detection
- [ ] Detects at least: PHP (phpstan/phpcs/pint), JS/TS (eslint/tsc), Python (flake8/ruff/mypy)
- [ ] Falls back to manual input if nothing detected
- [ ] Writes proper JSON array to lint_commands
- [ ] User sees what was detected and can confirm/modify
