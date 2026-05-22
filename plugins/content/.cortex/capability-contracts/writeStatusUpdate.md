---
capability_interface_id: writeStatusUpdate
version: 1
bundle_contract_id: stakeholder-comms
schema_in: IncidentRecord@v1
schema_out: StatusUpdate@v1
---

# writeStatusUpdate@v1

Public status-page entry per incident phase (identified / investigating / mitigating / resolved).

## Inputs

- `IncidentRecord@v1` (required) with current phase.

## Outputs

- `StatusUpdate@v1` at `.agents/state/comms/incident-<id>/content/<phase>.md` using `platform/templates/status-update.md`.

## Non-functional contract

- **Latency budget:** p95 ≤ 30 s per phase update (time-critical during active incidents).
- **Token budget:** ≤ 6K.
- **HITL:** mandatory on every publication (checkpoint 4 — External public statement). Legal + Comms sign-off.

## Failure modes

- Speculation about cause before postmortem → refuse.
- Engineer names / internal server codes leaked → refuse.
- Phase mismatch (IncidentRecord says `resolved` but status update is `mitigating`) → refuse.

## Fixtures

Golden: `status-update-initial-declaration`.
Adversarial: `status-update-speculates-cause` (refused).
