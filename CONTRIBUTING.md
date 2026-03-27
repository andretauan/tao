# Contributing to TAO

Thank you for your interest in contributing to TAO! This document covers the guidelines for contributing to the project.

🇧🇷 **Contribuindo em Português:** Este projeto aceita contribuições em português e inglês. PRs e issues podem ser escritos em qualquer um dos dois idiomas.

---

## How to Contribute

### Reporting Issues

- Use [GitHub Issues](../../issues) to report bugs or suggest features
- Include your VS Code version, Copilot version, and OS
- For bugs: describe what happened, what you expected, and steps to reproduce
- For feature requests: describe the use case and why it matters

### Pull Requests

1. Fork the repository
2. Create a branch from `dev`: `git checkout -b feature/your-feature dev`
3. Make your changes following the guidelines below
4. Test your changes (see Testing section)
5. Submit a PR against the `dev` branch

### What We Need Help With

- **Translations:** Adapting templates to new languages (cultural adaptation, not mechanical translation)
- **Agent improvements:** Better prompts, edge case handling, clearer instructions
- **Hook scripts:** New hooks for different tools/workflows
- **Documentation:** Tutorials, examples, walkthroughs
- **Lint commands:** Adding default lint commands for more languages
- **Compatibility:** Adapters for Claude Code, Cursor, Cline, Windsurf

---

## Guidelines

### Code Style

- Shell scripts: `set -euo pipefail`, use `bash -n` for syntax validation
- JSON: validate with `python3 -c "import json; json.load(open('file.json'))"`
- Markdown: proper headers hierarchy, no trailing whitespace
- Use `python3` for JSON parsing in hooks (not `jq` — not all systems have it)

### Templates

- All templates use `{{PLACEHOLDER}}` syntax for values replaced by `install.sh`
- Zero hardcoded project-specific values
- If you add a new template, update `install.sh` to copy it during installation

### Agents (.agent.md)

- YAML frontmatter must be valid
- Model strings must match exactly: `Claude Sonnet 4.6 (copilot)`, `Claude Opus 4.6 (copilot)`, `GPT-4.1 (copilot)`
- Subagent-only agents must have `user-invocable: false`
- Content below frontmatter should reference CLAUDE.md, not duplicate it

### Bilingual (EN + PT-BR)

- Every user-facing template must exist in both `en/` and `pt-br/` directories
- PT-BR is **cultural adaptation**, not mechanical translation
- Run `scripts/i18n-diff.sh` before submitting a PR to verify no drift
- If you add a new template to one language, add it to the other too

### Commit Messages

```
type(scope): short description in imperative

Types: feat, fix, refactor, docs, chore, test
Scopes: core, agents, hooks, templates, scripts, docs, i18n
```

---

## Testing

Before submitting a PR, verify:

1. **Shell syntax:** `bash -n` on all `.sh` files
2. **JSON validity:** `python3 -c "import json; json.load(open('file.json'))"` on all `.json` files
3. **i18n parity:** `bash scripts/i18n-diff.sh` — no missing or drifted files
4. **Install test:** Run `install.sh` in a fresh directory and verify it works end-to-end

---

## Architecture

Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) before making structural changes. Key decisions:

- `tao.config.json` is the single source of project-specific values
- Hooks use `python3` for JSON parsing (not `jq`)
- Scripts read config via `python3 -c "import json; ..."` pattern
- Templates use `{{PLACEHOLDER}}` syntax, never `[REPLACE]` or hardcoded values

---

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

## Code of Conduct

Be respectful and constructive. We follow the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
