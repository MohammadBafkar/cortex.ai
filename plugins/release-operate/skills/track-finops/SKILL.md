---
name: release-operate.track-finops
description: |
  **Use when:** the team needs cost telemetry per service or per release —
  current spend, unit economics (cost per request / per user), budget burn.
  Triggers on: "/finops", "cost of running X".
  **Do NOT use when:** the user wants production observability (use `observe`)
  or AdoptionReport (use `product.measure-adoption`).
  **Inputs:** ReleaseRecord@v1 or service name.
  **Outputs:** FinOpsReport@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: trackFinOps
bundle_contract_id: finops
visibility: public
---

# track-finops

Pull cost data per service + per release; compute unit economics; flag budget overruns.

## Procedure

1. **Query the cloud cost connector** (AWS CUR, GCP Billing, etc.).
2. **Attribute** spend per service / tag.
3. **Compute unit economics.** $/request, $/MAU. If the project doesn't have a denominator, use a sensible proxy or flag it.
4. **Compare to budget.** Per service + per quarter.
5. **Flag** budget overruns (> 80% projected for the quarter). Surface HITL per checkpoint 9 (C-tier MVP1, M-tier when activated).
6. **Write** FinOpsReport with attribution + trend + flagged overruns.

## Hard rules

- **No fabricated cost numbers.** Always cite the connector + the query window.
- **Budget overrun > threshold triggers HITL.**
