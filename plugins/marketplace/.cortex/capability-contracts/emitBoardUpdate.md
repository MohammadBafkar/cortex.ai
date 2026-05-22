---
capability_interface_id: emitBoardUpdate
version: 1
bundle_contract_id: governance
schema_in: MetricsSummary@v1
schema_out: BoardUpdate@v1
---

# emitBoardUpdate@v1

Board-level quarterly summary aggregating ConformanceVerdicts + PluginFeedback + DORA + governance reviews.

## Inputs

- `MetricsSummary@v1` (composed from the prior quarter's signed envelopes in CAS).

## Outputs

- `BoardUpdate@v1` at `.agents/state/governance/board/<quarter>/marketplace/update.md`.

## Non-functional contract

- **Cadence:** quarterly.
- **Idempotency:** yes per quarter once all source envelopes are signed.
- **Latency budget:** p95 ≤ 90 s.
- **Token budget:** ≤ 15K.
- **HITL:** **checkpoint 39** (Board update authoring) — `rbac/governance-leads`. Distribution is owned by `content.write-status-update` per the RACI split.

## Failure modes

- Numbers without citations → refuse (defect; every figure traces to a specific envelope).
- "Everything is fine" without traffic-light data → refuse.
- Quarter not yet closed → state: `requires_human` with the day the quarter matures.

## Fixtures

Golden: `board-update-quarterly`.
Adversarial: `board-update-fabricated-numbers` (refused).
