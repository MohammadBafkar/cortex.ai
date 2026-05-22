---
name: release-operate.postmortem
description: |
  **Use when:** an IncidentRecord@v1 is resolved (`state=resolved`) and the
  team needs a blameless postmortem with timeline, contributing factors,
  action items. Triggers on: "/postmortem [incident-id]".
  **Do NOT use when:** the incident is still active (use `triage-incident`),
  or a routine retrospective (use `methodology.retro` at P2).
  **Inputs:** IncidentRecord@v1 (resolved).
  **Outputs:** Postmortem@v1 at
  `.agents/state/postmortems/<incident-id>/release-operate/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: postmortem
bundle_contract_id: incident
visibility: public
---

# postmortem

Blameless postmortem with timeline, contributing factors, and assignable action items.

## Procedure

1. **Reconstruct the timeline** from telemetry, chat logs, deploy records. Per minute or per-event.
2. **Identify contributing factors.** Multiple, not "the cause". Apply 5-whys until reaching organizational / system / process roots.
3. **Compose `methodology.risk-assess` inline** for the contributing factors — which could happen again?
4. **Write action items.** Each: owner-bundle, severity (info|minor|major|blocking), expected completion date. Action items get filed into the appropriate plugin's workspace state (e.g., engineering for code fixes, security for vuln remediation).
5. **Compose `methodology.verify` inline** — does the postmortem cover what actually happened, not what we wish had happened?
6. **Write** Postmortem.

## Hard rules

- **Blameless.** No individual blamed; systemic causes only.
- **Action items must have owners.** No "we should…" without an assignee.
- **Postmortem within 5 BD of resolution.** Older incidents skip postmortem (cited as outliers in the next DORA cycle).

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/postmortem.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
