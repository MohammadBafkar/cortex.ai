---
name: brainstorm
description: |
  **Use when:** the user types `/brainstorm <topic>` to expand the option space on
  any topic before narrowing.
  **Do NOT use when:** the user wants a specific artifact (PRD, ADR, PR) — those
  belong to capability skills.
  **Inputs:** any topic.
  **Outputs:** ephemeral options. No artifact written.
argument-hint: "<topic>"
allowed-tools: [Read]
---

# /brainstorm

Apply the procedure in `methodology.brainstorm`. The slash command is a thin trigger — the actual procedure lives in the skill body. Read it and follow it.

The brainstorm skill is *ephemeral by design*. Do not write anything to authoritative-artifact subdirs (the PEP hook will block, but better to refuse first with a clear message and suggest the right capability skill).
