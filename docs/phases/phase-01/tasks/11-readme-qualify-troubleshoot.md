# Task T11 — README: Qualify Claims + Add Troubleshooting

**Phase:** 01 — Vibe Coder Promise Fulfillment
**Complexity:** Medium
**Executor:** Architect (Opus)
**Priority:** P3

---

## Objective

Qualify the misleading claims in README.md and README.pt-br.md ("you don't need to know how to program", "60% savings") and add a Troubleshooting section for common first-run issues.

## Context

The README makes two claims that set wrong expectations: (1) "you don't need to program" — technically the AI writes code, but debugging, reviewing diffs, and understanding errors requires basic technical literacy; (2) "60% savings" — this only accounts for execution costs and ignores brainstorming (Opus) and planning cycles. Qualifying these upfront prevents disappointment and support burden.

## Files to Read (BEFORE editing)

- `README.md` — full file
- `README.pt-br.md` — full file
- `docs/ECONOMICS.md` — to understand the savings model

## Files to Create/Edit

- `README.md` — qualify claims + add troubleshooting
- `README.pt-br.md` — same changes in Portuguese

## Implementation Steps

1. Read both README files completely
2. Find the "you don't need to program" claim and qualify:
   - EN: "TAO handles code generation, but you'll need basic comfort with: reading error messages, reviewing file changes (diffs), and navigating a project structure. No programming language knowledge required — TAO guides you through everything else."
   - PT-BR: "TAO cuida da geração de código, mas você precisará de conforto básico com: ler mensagens de erro, revisar alterações em arquivos (diffs), e navegar a estrutura de um projeto. Nenhum conhecimento de linguagem de programação é necessário — TAO te guia em todo o resto."
3. Find the "60% savings" claim and qualify:
   - EN: "Up to 60% savings on execution costs by routing simple tasks to Sonnet instead of Opus. Note: brainstorming and planning phases use Opus and are not included in this estimate. See [Economics](docs/ECONOMICS.md) for full breakdown."
   - PT-BR: "Até 60% de economia em custos de execução ao rotear tarefas simples para Sonnet em vez de Opus. Nota: fases de brainstorming e planejamento usam Opus e não estão incluídas nesta estimativa. Veja [Economia](docs/ECONOMICS.md) para o detalhamento completo."
4. Add Troubleshooting section before the "Contributing" section:

   **EN:**
   ```markdown
   ## Troubleshooting
   
   | Problem | Cause | Fix |
   |---------|-------|-----|
   | Agent doesn't follow TAO rules | Hooks not activated | Add `"chat.useCustomAgentHooks": true` to `.vscode/settings.json` |
   | "lint tool not found" warning | Lint tool not installed | Install the tool (e.g., `npm install -g eslint`) or set lint to `none` |
   | Agent asks no questions on first run | Normal behavior | Type your project description — TAO will detect it's a new project |
   | Context window fills up quickly | Large project + verbose output | Close and reopen chat periodically; TAO preserves state in files |
   | ABEX check always passes | Expected for lightweight scan | ABEX catches common patterns only; use proper SAST for production |
   ```

   **PT-BR:** (same table, translated)

5. Verify both files are consistent in structure

## Acceptance Criteria

- [ ] "Don't need to program" claim is qualified with what IS needed
- [ ] "60% savings" claim specifies "execution costs only"
- [ ] Troubleshooting table exists in both languages
- [ ] Troubleshooting covers: hooks not active, lint not found, first-run behavior, context window, ABEX
- [ ] Both README files have the same sections in the same order
- [ ] No broken Markdown links
- [ ] Tone remains encouraging, not discouraging

## Notes / Gotchas

- Don't make the qualifications scary — the goal is setting accurate expectations, not discouraging users
- Keep troubleshooting table short (5-7 rows max)
- The context window issue is real but hard to fix — just document it
- Both READMEs must stay perfectly aligned in structure

---

**Expected commit:** `docs(phase-01): T11 — README qualifies claims and adds troubleshooting`
