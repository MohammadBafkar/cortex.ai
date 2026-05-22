---
capability_interface_id: trackFinOps
version: 1
bundle_contract_id: finops
schema_in: ReleaseRecord@v1
schema_out: FinOpsReport@v1
---

# trackFinOps@v1

Pulls cost telemetry per service or per release and emits a `FinOpsReport@v1`. Computes unit economics ($/request, $/MAU) when denominators are available.

## Inputs

- `ReleaseRecord@v1` OR a service name + time window.
- Cloud cost connector (`connector-aws-cur` / GCP Billing / Azure Cost Mgmt) for the raw spend data.

## Outputs

- `FinOpsReport@v1` at `.agents/state/finops/<period>/release-operate/`.

## Non-functional contract

- **Idempotency:** yes per window.
- **Latency budget:** p95 ≤ 60 s for a week's spend on a small org (dominated by connector lookup).
- **Token budget:** ≤ 8K (mostly aggregation; Haiku-class workload).
- **HITL:** budget overrun > threshold → checkpoint 9 (Budget overage) escalation.

## Failure modes

- Cost connector unreachable → state: `requires_human` with retry guidance; never fabricate numbers.
- Denominator missing (no MAU source) → emit unit economics as `null` with explanation; do not infer.
- Cross-cloud aggregation requested without all connectors → refuse; per-cloud reports only.

## Fixtures

Golden: `finops-monthly-attribution`.
Adversarial: `finops-fabricated-numbers` (refused).
