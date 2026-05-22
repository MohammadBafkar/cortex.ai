---
capability_interface_id: improveDX
version: 1
bundle_contract_id: developer-experience
schema_in: DXSignal@v1
schema_out: DXImprovement@v1
---

# improveDX@v1

Triage a developer-experience signal (onboarding friction, API ergonomics complaint, error-message clarity) into an actionable improvement routed to the owning bundle.

## Inputs

- `DXSignal@v1` (telemetry, survey response, support ticket).

## Outputs

- `DXImprovement@v1` at `.agents/state/support/dx-<id>/content/improvement.json` with owner-bundle hint + expected impact.

## Non-functional contract

- **Idempotency:** yes per signal.
- **Latency budget:** p95 ≤ 45 s.
- **Token budget:** ≤ 8K.
- **HITL:** assignee bundle accepts/rejects via that bundle's own review.

## Failure modes

- Improvement without an owner-bundle hint → refuse (defect; "this should be better" is not an improvement).
- "Rewrite the SDK" as an improvement → refuse (that's a PRD, not a DXImprovement).

## Fixtures

Golden: `dx-signal-into-improvement`.
Adversarial: `dx-improvement-without-owner` (refused).
