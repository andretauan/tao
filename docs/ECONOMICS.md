# Model Economics — TAO Cost Optimization

> How TAO routes tasks to the cheapest model that can handle them, and why this matters for your GitHub Copilot budget.

---

## The Cost Problem

GitHub Copilot charges premium requests based on model multipliers. Without routing, developers default to the most expensive model for everything — including tasks a cheaper model handles perfectly.

**Monthly Copilot allowance:** ~300 premium requests (may vary by plan)

---

## Model Tiers

| Model | Multiplier | Role in TAO | Best For |
|---|---|---|---|
| **Claude Opus 4.6** | 3x | @Wu (brainstorm), Shen (complex), Shen-Architect | Architecture, security, trade-offs, debugging |
| **Claude Sonnet 4.6** | 1x | @Tao (orchestrator) | CRUD, views, bug fixes, tests, routine features |
| **GPT-4.1** | **0x (free)** | @Di (DBA), @Qi (deploy), fallback | Migrations, schema, git operations |

**Source:** [GitHub Premium Requests Documentation](https://docs.github.com/en/copilot/managing-copilot/monitoring-usage-and-entitlements/about-premium-requests)

---

## Routing Logic

TAO's orchestrator (@Tao) evaluates each task and routes to the cheapest sufficient model:

```
Task arrives
  ├── Marked "Executor: Architect" in STATUS.md?  → Shen (Opus, 3x)
  ├── High complexity + design trade-offs?          → Shen (Opus, 3x)
  ├── Security-critical (auth, crypto)?             → Shen (Opus, 3x)
  ├── Bug failed 3x?                               → Shen (Opus, 3x)
  ├── Database operation?                           → Di (GPT-4.1, free)
  ├── Git commit/push?                              → Qi (GPT-4.1, free)
  └── Everything else                               → Tao direct (Sonnet, 1x)
```

---

## Session Cost Comparison

### Without TAO (Opus for everything)

| Item | Calculation | Cost |
|---|---|---|
| 6 tasks × ~8 turns | 48 turns × 3x | **144 requests** |
| **Monthly capacity** | 300 / 144 | **~2 sessions** |

### With TAO (intelligent routing)

| Item | Calculation | Cost |
|---|---|---|
| 4 routine tasks (Sonnet) | 32 turns × 1x | 32 |
| 2 complex tasks (Opus via Shen) | 20 turns × 3x | 60 |
| DB/Deploy ops (GPT-4.1) | N turns × 0x | 0 |
| Hooks (lint, context) | deterministic × 0x | 0 |
| **Total** | | **92 requests** |
| **Monthly capacity** | 300 / 92 | **~3.2 sessions (+60%)** |

### Best Case (mostly CRUD project)

| Item | Calculation | Cost |
|---|---|---|
| 5 routine tasks (Sonnet) | 40 turns × 1x | 40 |
| 1 complex task (Opus) | 10 turns × 3x | 30 |
| DB/Deploy ops | free | 0 |
| **Total** | | **70 requests** |
| **Monthly capacity** | 300 / 70 | **~4.3 sessions (+115%)** |

---

## Zero-Cost Operations

These operations consume **0 premium requests**:

| Operation | How |
|---|---|
| **PostToolUse lint hook** | Deterministic script — no LLM involved |
| **SessionStart context hook** | Deterministic script — reads files, outputs JSON |
| **Pre-commit hook** | Git hook — runs lint commands from tao.config.json |
| **Di (DBA) operations** | GPT-4.1 is free tier |
| **Qi (Deploy) operations** | GPT-4.1 is free tier |
| **Tao GPT-4.1 fallback** | If Sonnet rate-limited, Tao falls back to free tier |

---

## Where Opus Pays for Itself

Opus costs 3x per request, but specific tasks justify the cost:

### Brainstorm & Planning (@Wu)

A bad plan from Sonnet costs 6+ execution cycles in rework. A thorough brainstorm in Opus costs ~10 turns × 3x = 30 requests — and saves all the rework.

**Rule:** The cost of a bad plan >>> the cost of using Opus to plan.

### Security-Critical Code (Shen)

Auth bypass, crypto implementation, race conditions — these are areas where Sonnet's limitations cause real security vulnerabilities. Opus catches edge cases that prevent costly hotfixes.

### Complex Debugging (Shen)

When a bug survives 3 fix attempts, switching to Opus often resolves it in one pass. 3 failed Sonnet attempts = 24 wasted requests. 1 successful Opus attempt = 30 requests but actually solves it.

---

## Configuring Models

Models are set in `tao.config.json`:

```json
{
  "models": {
    "orchestrator": "Claude Sonnet 4.6 (copilot)",
    "complex_worker": "Claude Opus 4.6 (copilot)",
    "free_tier": "GPT-4.1 (copilot)"
  }
}
```

To update models across all agent files after changing config:

```bash
bash scripts/update-models.sh          # Apply changes
bash scripts/update-models.sh --dry-run # Preview changes
```

---

## Model Fallback

Agents can define fallback models for rate-limit scenarios:

```yaml
model:
  - Claude Sonnet 4.6 (copilot)
  - GPT-4.1 (copilot)
```

If the primary model is unavailable, VS Code automatically uses the next in the list.

---

## Optimizing Your Budget

1. **Let @Tao route** — don't manually select Opus for routine tasks
2. **Use @Wu for planning** — invest Opus upfront to avoid rework
3. **Batch DB tasks** — @Di uses the free tier, so DB operations cost nothing
4. **Let hooks lint** — 0 cost, catches errors before the LLM needs to fix them
5. **Review STATUS.md executor column** — ensure complex tasks are marked correctly so Shen handles them instead of Tao struggling and wasting turns
