---
name: advisory
description: |
  **Use when:** `/advisory [finding-id]` to author a security advisory under
  coordinated disclosure.
  **Do NOT use when:** the user wants engineering fix (use
  `engineering.propose-pr`) or PIA (use `security.run-pia`).
  **Inputs:** finding-id.
  **Outputs:** Advisory@v1.
argument-hint: "<finding-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /advisory
Dispatch `comms-lead`.
