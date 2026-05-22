---
name: prd
description: |
  **Use when:** the user types `/prd [opportunity-id]` to draft a PRD from an
  OpportunityBrief.
  **Do NOT use when:** the user wants ideation (`/brainstorm`), code
  (`/implement`), or epic decomposition (`/decompose`).
  **Inputs:** opportunity-id resolving to .agents/state/intakes/<id>/product/brief.json.
  **Outputs:** PRD@v1 at .agents/state/prds/<id>/product/prd.md.
argument-hint: "<opportunity-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /prd

Dispatch `product-manager` to draft a PRD against the named OpportunityBrief.
