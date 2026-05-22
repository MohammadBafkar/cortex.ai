---
name: plan
description: |
  **Use when:** the user types `/plan <goal>` to decompose a goal into ≤ 5
  verifiable steps before doing the work.
  **Do NOT use when:** the goal is already clear and small, or the user wants
  ideation (use `/brainstorm`), or a written PRD (use `/prd` when admitted).
  **Inputs:** a goal description.
  **Outputs:** ephemeral plan note (optionally saved to
  `.agents/state/methodology/plan-work/<session>.md`).
argument-hint: "<goal>"
allowed-tools: [Read, Write]
---

# /plan

Apply the procedure in `methodology.plan-work`. ≤ 5 steps, each with explicit verification.
