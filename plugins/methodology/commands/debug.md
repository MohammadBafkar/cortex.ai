---
name: debug
description: |
  **Use when:** the user types `/debug <symptoms>` to systematically debug a
  failure — form one hypothesis, test cheaply, advance or abandon, repeat.
  **Do NOT use when:** the user wants ideation (`/brainstorm`), step planning
  (`/plan`), or post-mortem authoring (use `release-operate.postmortem` at P1).
  **Inputs:** a failure description.
  **Outputs:** ephemeral debug log; no authoritative artifact.
argument-hint: "<symptoms>"
allowed-tools: [Read, Grep, Bash]
---

# /debug

Apply the procedure in `methodology.debug`. One hypothesis at a time, bounded ≤ 5 iterations before HITL.
