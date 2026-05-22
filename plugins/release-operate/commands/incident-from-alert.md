---
name: incident-from-alert
description: |
  **Use when:** an Alert fires; `/incident-from-alert [alert-id]` triages.
  **Do NOT use when:** the alert is informational only (use `observe`).
  **Inputs:** alert-id.
  **Outputs:** IncidentRecord@v1.
argument-hint: "<alert-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /incident-from-alert
Dispatch `incident-commander` to triage.
