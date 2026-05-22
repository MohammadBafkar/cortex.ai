---
capability_interface_id: lintWithBiome
version: 1
bundle_contract_id: lang-typescript
schema_in: PullRequest@v1
schema_out: LintReport@v1
---

# lintWithBiome@v1

Runs `biome check` against the diff using the project's configured profile. Reports violations with rule id + fix suggestion. Does NOT apply fixes automatically.

## Inputs

- `PullRequest@v1` with TS/JS diff.
- A `biome.json` / `biome.jsonc` configured at the workspace root (or fallback profile if the workspace pins one).

## Outputs

- `LintReport@v1` at `.agents/state/langs/lang-typescript/<pr-id>/lint.json`.

## Non-functional contract

- **Idempotency:** yes on same diff.
- **Latency budget:** p95 ≤ 10 s for diff-scoped lint.
- **Token budget:** ≤ 6K.
- **HITL:** `biome check --write` (the auto-fix path) is HITL-gated; this skill emits the suggestion list only.

## Failure modes

- No biome config → propose a starter config but do NOT add it without HITL.
- Auto-fix without HITL → PEP blocks.
- Stricter rules than configured profile → refuse.

## Fixtures

Golden: `biome-flags-unused-import`.
Adversarial: `biome-auto-write-without-hitl` (PEP blocks).
