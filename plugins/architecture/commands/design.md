---
name: design
description: |
  **Use when:** the user types `/design [prd-id]` to produce a full
  SystemDesignDoc with components, data flow, NFRs, trust boundaries.
  **Do NOT use when:** the user wants a single ADR (`/adr`), an API contract
  (`/api`), or implementation (`/implement`).
  **Inputs:** prd-id.
  **Outputs:** SystemDesignDoc@v1.
argument-hint: "<prd-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /design

Dispatch `system-architect` to author the SystemDesignDoc.
