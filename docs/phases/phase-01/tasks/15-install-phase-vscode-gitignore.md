# Task T15 — install.sh Create Phase-01 + .vscode + .gitignore + Output

**Phase:** 01 — Enforcement Architecture
**Complexity:** Medium
**Executor:** Sonnet
**Priority:** P3-INSTALL
**Depends on:** T14

---

## Objective

Fix install.sh to: (1) create phase-01 directory automatically, (2) create .vscode/settings.json enabling agent hooks, (3) create .gitignore for TAO artifacts, (4) confirm success with actionable output.

## Gaps Fixed

- G31: No phase-01 creation during install
- G32: No .vscode/settings.json created (hooks don't activate)
- G34: Missing .gitignore for project artifacts
- G35: No actionable output after install

## Files to Read

- `install.sh` — current implementation (full file)
- `scripts/new-phase.sh` — phase creation logic (reference)
- `tao.config.json.example` — phases directory config

## Files to Edit

- `install.sh` — add 4 new capabilities

## Changes

### 1. Create phase-01 directory

After config file is written, call phase creation:
```bash
# Create initial phase directory
phase_dir="${phases_dir}/${phase_prefix}01"
mkdir -p "$phase_dir/brainstorm" "$phase_dir/tasks"
# Copy templates
```

### 2. Create .vscode/settings.json

```bash
create_vscode_settings() {
  local vscode_dir="$PROJECT_ROOT/.vscode"
  mkdir -p "$vscode_dir"

  if [[ ! -f "$vscode_dir/settings.json" ]]; then
    cat > "$vscode_dir/settings.json" << 'SETTINGS'
{
  "chat.useCustomAgentHooks": true
}
SETTINGS
    echo "✅ Created .vscode/settings.json (agent hooks enabled)"
  else
    # Check if setting already exists, add if not
    if ! grep -q "chat.useCustomAgentHooks" "$vscode_dir/settings.json"; then
      echo "⚠️  .vscode/settings.json exists — add \"chat.useCustomAgentHooks\": true manually"
    fi
  fi
}
```

### 3. Create .gitignore entries

Append to project .gitignore (create if needed):
```
# TAO Framework
.tao-pause
*.local
```

### 4. Success output

After install completes, show:
```
✅ TAO installed successfully!

📁 Created:
   .github/tao/tao.config.json
   .github/tao/phases/fase-01/
   .vscode/settings.json

🎯 Next steps:
   1. Open VS Code Agent Mode (Ctrl+Shift+I)
   2. Type: @Executar-Tao executar
   3. The agent will read STATUS.md and start the first task
```

## Acceptance Criteria

- [ ] Phase-01 directory created with brainstorm/ and tasks/ subdirs
- [ ] Phase templates copied to phase-01
- [ ] .vscode/settings.json created with chat.useCustomAgentHooks: true
- [ ] Existing .vscode/settings.json handled gracefully (no overwrite)
- [ ] .gitignore updated with TAO entries
- [ ] Success message shows what was created + next steps
