---
capability_interface_id: rollback
version: 1
bundle_contract_id: release
schema_in: ReleaseRecord@v1
schema_out: RollbackRecord@v1
---

# rollback@v1

Reverts a production `ReleaseRecord@v1`. Irreversible (the rollback itself is — there's no "rollback the rollback"; that's just another forward release).

## Inputs

- `ReleaseRecord@v1` (required) — state `approved` and `state.production: live`.

## Outputs

- `RollbackRecord@v1` at `.agents/state/releases/<release-id>/release-operate/rollback.json`.

## Non-functional contract

- **Latency budget:** p95 ≤ 10 min during an active incident — the rollback executes in seconds; the budget is dominated by HITL approval time.
- **Token budget:** ≤ 5K (operational; minimal LLM reasoning).
- **HITL:** **M-tier checkpoint 2** (Production rollback) — `rbac/incident-commanders`, SLA ≤ 10 min during incident. Fallback: auto-rollback if SLO burn ≥ threshold.

## Failure modes

- Rollback target version not preserved → state: `requires_human` with manual-revert guidance.
- IC unavailable + auto-rollback disabled → break-glass invocation (post-hoc audit ≤ 24h).
- Database forward-only migration in the release → refuse; surface to HITL with the manual-recovery runbook.

## Fixtures

Golden: `rollback-canary-stage` (clean rollback before full deploy).
Adversarial: `rollback-without-ic` (refused outside break-glass).
