---
capability_interface_id: mitigateIncident
version: 1
bundle_contract_id: incident
schema_in: IncidentRecord@v1
schema_out: IncidentRecord@v1
---

# mitigateIncident@v1

Advances an `IncidentRecord@v1` through `triaged → mitigating → resolved` states. The mitigation actions themselves (rollback, traffic-shift, feature-flag flip) are delegated to the appropriate plugin; this capability *coordinates*.

## Inputs

- `IncidentRecord@v1` (required) in state `triaged`.

## Outputs

- The same `IncidentRecord@v1` advanced through state transitions, with `mitigation_actions[]` appended at each step. State transitions are explicit envelope writes; the parent workflow executor observes them.

## Non-functional contract

- **Latency budget:** dominated by the actual mitigation actions. Coordination overhead p95 ≤ 30 s per state transition.
- **Token budget:** ≤ 12K.
- **HITL:** required at each state transition for Sev0/1 (checkpoint 2 — Production rollback variant). Sev2/3 auto-progresses with audit log only.

## Failure modes

- Mitigation action fails (e.g., rollback target unreachable) → escalate to break-glass; state stays `mitigating` with `attempts[]` recorded.
- Resolution prematurely declared → IC must explicitly re-open; conformance fixture catches "resolved → re-opened" within 1h as a defect.

## Fixtures

Golden: `incident-mitigate-via-rollback`.
Adversarial: `mitigation-without-hitl-on-sev1` (PEP blocks).
