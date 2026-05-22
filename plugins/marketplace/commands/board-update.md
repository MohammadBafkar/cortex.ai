---
name: board-update
description: |
  **Use when:** `/board-update [quarter]` to author a board-level summary of
  the marketplace's operational state.
  **Do NOT use when:** the user wants DORA-only (`/dora`) or audit query
  (`/audit`).
  **Inputs:** optional quarter.
  **Outputs:** BoardUpdate@v1.
argument-hint: "[quarter]"
allowed-tools: [Task, Read, Bash, Write]
---
# /board-update
Dispatch `governance-officer`.
