---
name: content.write-status-update
description: |
  **Use when:** an IncidentRecord@v1 is open and the team needs a status-page
  update (initial declaration, mitigation in progress, resolved).
  **Do NOT use when:** the user wants release notes (use `write-release-notes`)
  or a postmortem (use `release-operate.postmortem`).
  **Inputs:** IncidentRecord@v1.
  **Outputs:** StatusUpdate@v1 at `.agents/state/comms/incident-<id>/content/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeStatusUpdate
bundle_contract_id: stakeholder-comms
visibility: public
---

# write-status-update

Author a public status-page update appropriate to the incident phase.

## Procedure

1. **Read** the IncidentRecord + telemetry context.
2. **Pick the template** for the phase: identified / investigating / mitigating / resolved.
3. **Write succinctly.** Lead with what the user experiences, then what we know, then what's next. No internal-only details (server names, person names).
4. **HITL on publication** (checkpoint 4 — External public statement). Legal + Comms sign-off when the incident is customer-facing.
5. **Compose `methodology.verify` inline.**
6. **Write** + queue for publication.

## Hard rules

- **No internal-only details.**
- **HITL on every publication.**
- **No speculation about cause.** Wait for the postmortem.

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/status-update.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
