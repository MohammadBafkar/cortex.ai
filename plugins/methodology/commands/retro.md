---
name: retro
description: |
  **Use when:** `/retro [unit-of-work]` to facilitate a structured
  retrospective (4Ls / start-stop-continue / mad-sad-glad).
  **Do NOT use when:** the user wants postmortem (use `release-operate.postmortem`)
  or adoption (use `product.measure-adoption`).
  **Inputs:** unit-of-work + optional frame name.
  **Outputs:** ephemeral retro notes.
argument-hint: "<unit-of-work>"
allowed-tools: [Read, Write]
---
# /retro
Apply the procedure in `methodology.retro`. 4Ls by default; blameless.
