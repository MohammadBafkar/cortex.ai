---
name: release-operate.triage-incident
description: |
  **Use when:** an Alert fires and the team needs structured incident triage —
  severity assignment, scope estimation, IC assignment, communication start.
  Triggers on: "/incident-from-alert", "page received: X".
  **Do NOT use when:** the user wants postmortem (use `postmortem`), release
  rollback (`/rollback`), or alert *definition* (use `observe`).
  **Inputs:** Alert@v1.
  **Outputs:** IncidentRecord@v1 at
  `.agents/state/incidents/<id>/release-operate/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: triageIncident
bundle_contract_id: incident
visibility: public
---

# triage-incident

Triage a fired alert into an IncidentRecord with severity, scope, and an assigned Incident Commander.

## Procedure

1. **Load** the Alert + the SLO + recent deploys (DORA emitter uses this).
2. **Compose `methodology.debug` inline.** One hypothesis at a time; what changed?
3. **Score severity.** SEV0 (full outage), SEV1 (partial outage / data loss), SEV2 (degraded), SEV3 (annoyance).
4. **Estimate scope.** Affected users / services / regions.
5. **Assign IC.** Pull from rota; if unavailable, surface HITL (checkpoint 2 — M-tier).
6. **Open status page** (HITL on customer comms — checkpoint 4 / 5).
7. **Write** IncidentRecord.

## Hard rules

- **Sev0/1 declarations require HITL ack within 10 min.**
- **Status page updates are HITL on customer-facing language.**
- **No incident without an IC.**
