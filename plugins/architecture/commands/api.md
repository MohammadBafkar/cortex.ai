---
name: api
description: |
  **Use when:** the user types `/api [design-id]` to author a versioned API
  contract from a SystemDesignDoc.
  **Do NOT use when:** the user wants implementation (`/implement`) or
  reference docs (use `content.api-reference` at P1).
  **Inputs:** design-id.
  **Outputs:** APIContract@v1 + the actual schema file.
argument-hint: "<design-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /api

Dispatch `api-architect` against the named SystemDesignDoc.
