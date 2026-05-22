---
name: finops
description: |
  **Use when:** `/finops [service]` to pull cost telemetry + unit economics.
  **Do NOT use when:** the user wants product adoption (use `/measure`).
  **Inputs:** service name (or release-id).
  **Outputs:** FinOpsReport@v1.
argument-hint: "<service-or-release>"
allowed-tools: [Task, Read, Bash, Write]
---

# /finops
Dispatch `finops-officer`.
