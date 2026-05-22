---
name: ethics-review
description: |
  **Use when:** `/ethics-review [prd-id]` to classify a PRD under EU AI Act
  risk levels + propose mitigations.
  **Do NOT use when:** the user wants privacy assessment (`security.run-pia`).
  **Inputs:** prd-id.
  **Outputs:** EthicsReview@v1.
argument-hint: "<prd-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /ethics-review
Dispatch `governance-officer`.
