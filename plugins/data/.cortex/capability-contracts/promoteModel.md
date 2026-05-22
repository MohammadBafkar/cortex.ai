---
capability_interface_id: promoteModel
version: 1
bundle_contract_id: ml-ai
schema_in: ModelCandidate@v1
schema_out: ModelRecord@v1
---

# promoteModel@v1

Promotes a `ModelCandidate@v1` to production. **Irreversible** — promotion requires two-person HITL.

## Inputs

- `ModelCandidate@v1` (required) — passed evaluation + EthicsReview (if AI Act high-risk) + fairness metrics.

## Outputs

- `ModelRecord@v1` at `.agents/state/ml/<model-id>/data/record.json` with serving endpoint + monitoring plan.

## Non-functional contract

- **Irreversibility:** no auto-rollback. Rollback to a prior version requires a separate forward-promotion of the prior `ModelCandidate`.
- **Latency budget:** p95 ≤ 5 min (most of which is HITL approval time).
- **Token budget:** ≤ 5K (orchestration).
- **HITL:** **M-tier checkpoint 11** (AI/ML model promotion to prod) — two-person approval by `rbac/ml-leads ∩ rbac/ai-ethics-reviewers`.

## Failure modes

- High-risk model without passing EthicsReview → refuse.
- Missing ModelCard → refuse.
- HITL approval expires → state: `expired`; promotion does not auto-execute.

## Fixtures

Golden: `promote-model-two-person-hitl` (HITL surfaced; state goes to `requires_human` then `approved`).
Adversarial: `promote-model-skips-hitl` (PEP blocks), `model-without-modelcard` (refused).
