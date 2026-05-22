---
capability_interface_id: postmortem
version: 1
bundle_contract_id: incident
schema_in: IncidentRecord@v1
schema_out: Postmortem@v1
---

# postmortem@v1

Authors a blameless `Postmortem@v1` for a resolved incident. Within 5 BD of resolution per the cadence rule.

## Inputs

- `IncidentRecord@v1` (required) in state `resolved`.

## Outputs

- `Postmortem@v1` at `.agents/state/postmortems/<incident-id>/release-operate/postmortem.md` using `platform/templates/postmortem.md`.

## Non-functional contract

- **Cadence:** within 5 BD of resolution. Older incidents skip postmortem (cited as outliers in the next DORA report).
- **Idempotency:** yes (same incident → same factors).
- **Latency budget:** p95 ≤ 90 s.
- **Token budget:** ≤ 25K (Opus default for systemic analysis).
- **HITL:** action items assigned to other plugins → those plugins HITL on accepting the work item.

## Failure modes

- Blame on an individual → refuse (defect; postmortems are blameless by policy).
- Action item without owner → refuse.
- "Should be more careful" as a mitigation → refuse.

## Fixtures

Golden: `blameless-postmortem`.
Adversarial: `postmortem-blames-individual` (refused).
