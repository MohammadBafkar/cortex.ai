---
name: measure
description: |
  **Use when:** the user types `/measure [feature-id]` to assess adoption
  of a shipped feature against its PRD success metrics.
  **Do NOT use when:** the user wants engineering benchmarks (use `quality.benchmark`),
  postmortem (use `release-operate.postmortem`), or auditing (`/audit`).
  **Inputs:** feature-id resolving to a ReleaseRecord + the originating PRD.
  **Outputs:** AdoptionReport@v1.
argument-hint: "<feature-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /measure

Dispatch `product-manager` to produce an AdoptionReport for the named feature.
