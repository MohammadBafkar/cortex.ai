---
name: csproj-audit
description: |
  **Use when:** `/csproj-audit [pr-id]` to audit `*.csproj` files for
  modernization opportunities.
  **Inputs:** pr-id.
  **Outputs:** ModernizationReport@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /csproj-audit
Dispatch `csproj-auditor`.
