---
name: adr
description: |
  **Use when:** the user types `/adr [decision-context]` to author a full
  Nygard-style ADR with options + trade-offs + risk assessment.
  **Do NOT use when:** the user wants minimal ADR (use engineering.propose-adr —
  in deprecation), full system design (use `/design`), or implementation
  (`/implement`).
  **Inputs:** decision context or PRD reference.
  **Outputs:** ADR@v1 at .agents/state/adrs/<id>/architecture/adr.md.
argument-hint: "[decision-context]"
allowed-tools: [Task, Read, Bash, Write]
---

# /adr

Dispatch `system-architect` against the named decision context.
