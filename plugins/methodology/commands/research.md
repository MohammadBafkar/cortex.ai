---
name: research
description: |
  **Use when:** the user types `/research <question>` to gather grounded
  information from authoritative sources with explicit citations.
  **Do NOT use when:** the user wants ideation (`/brainstorm`) or one-off
  conversational answers.
  **Inputs:** a research question.
  **Outputs:** ephemeral notes with citations.
argument-hint: "<question>"
allowed-tools: [Read, Grep, Bash]
---

# /research

Apply the procedure in `methodology.research`. Every claim cited.
