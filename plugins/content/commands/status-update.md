---
name: status-update
description: |
  **Use when:** `/status-update [incident-id]` to author a public status-page
  update for an active incident.
  **Do NOT use when:** the user wants postmortem (use
  `release-operate.postmortem`).
  **Inputs:** incident-id.
  **Outputs:** StatusUpdate@v1.
argument-hint: "<incident-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /status-update
Dispatch `comms-lead`.
