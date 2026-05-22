---
name: sunset-notice
description: |
  **Use when:** `/sunset-notice [proposal-id]` to author a customer notice for
  an approved deprecation.
  **Inputs:** proposal-id.
  **Outputs:** SunsetNotice@v1.
argument-hint: "<proposal-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /sunset-notice
Dispatch `sunset-officer`.
