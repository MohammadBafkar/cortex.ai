---
name: xunit
description: |
  **Use when:** `/xunit [pr-id]` to author xUnit tests for a C#/.NET PR.
  **Inputs:** pr-id.
  **Outputs:** TestSuite@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /xunit
Dispatch `xunit-author`.
