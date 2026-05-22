---
name: decompose
description: |
  **Use when:** the user types `/decompose [prd-id]` to break a PRD into an
  Epic + 2-8 UserStories.
  **Do NOT use when:** the user wants a PRD itself (`/prd`) or code (`/implement`).
  **Inputs:** prd-id.
  **Outputs:** EpicSpec + UserStory[] under .agents/state/intakes/<epic-id>/product/.
argument-hint: "<prd-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /decompose

Dispatch `product-manager` to decompose the named PRD.
