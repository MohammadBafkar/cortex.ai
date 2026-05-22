---
capability_interface_id: measureAdoption
version: 1
bundle_contract_id: delivery
schema_in: ReleaseRecord@v1
schema_out: AdoptionReport@v1
---

# measureAdoption@v1

Compares a shipped feature's actuals against the PRD's named success metrics.

## Inputs

- `ReleaseRecord@v1` (required) — state `approved`, ≥ N days post-deploy (window per metric).
- `PRD@v1` — the originating spec containing the named success metrics.

## Outputs

- `AdoptionReport@v1` at `.agents/state/roadmaps/<feature-id>/product/adoption.json` with per-metric outcomes + continue/pivot/kill recommendation.

## Non-functional contract

- **Idempotency:** yes — same `ReleaseRecord` + window yields the same report.
- **Latency budget:** p95 ≤ 30 s (mostly query time against observability connector).
- **Token budget:** ≤ 8K.
- **HITL:** when the recommendation is `pivot` or `kill`, HITL by PM + EM before action.

## Failure modes

- PRD has no named success metrics → refuse; surface the PRD defect upstream.
- Metric window not yet elapsed → state: `requires_human` with the date the window matures.
- Connector lookup fails → state: `failed` with the missing-dependency reason.

## Fixtures

Golden: `measure-adoption-of-shipped-feature` (numbers cite real ReleaseRecord).
Adversarial: `adoption-report-without-actuals` (no numbers cited → refused).
