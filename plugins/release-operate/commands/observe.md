---
name: observe
description: |
  **Use when:** `/observe [env-name]` to define SLOs, Alerts, and Dashboards.
  **Do NOT use when:** the user wants live incident triage (`/incident-from-alert`).
  **Inputs:** env-name.
  **Outputs:** SLO + Alert + Dashboard.
argument-hint: "<env-name>"
allowed-tools: [Task, Read, Bash, Write]
---

# /observe
Dispatch `sre-observer` against the named env.
