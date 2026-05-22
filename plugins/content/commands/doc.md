---
name: doc
description: |
  **Use when:** `/doc [api-id|topic]` to author a doc page.
  **Do NOT use when:** the user wants release notes (`/release-notes`).
  **Inputs:** api-id, topic, or PRD reference.
  **Outputs:** DocPage@v1.
argument-hint: "<api-id-or-topic>"
allowed-tools: [Task, Read, Bash, Write]
---
# /doc
Dispatch `technical-writer`.
