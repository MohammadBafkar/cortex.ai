---
name: biome
description: |
  **Use when:** `/biome [pr-id]` to lint a TS/JS PR with biome.
  **Inputs:** pr-id.
  **Outputs:** LintReport@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /biome
Dispatch `biome-linter`.
