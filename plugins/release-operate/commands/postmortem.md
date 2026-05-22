---
name: postmortem
description: |
  **Use when:** `/postmortem [incident-id]` to author a blameless postmortem
  on a resolved incident.
  **Do NOT use when:** the incident is still active (use `/incident-from-alert`).
  **Inputs:** incident-id.
  **Outputs:** Postmortem@v1.
argument-hint: "<incident-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /postmortem
Dispatch `incident-commander` to author the postmortem.
