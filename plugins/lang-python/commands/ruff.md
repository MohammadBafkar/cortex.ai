---
name: ruff
description: |
  **Use when:** `/ruff [pr-id]` to lint Python code via ruff.
  **Inputs:** pr-id.
  **Outputs:** LintReport@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /ruff
Dispatch `ruff-linter`.
