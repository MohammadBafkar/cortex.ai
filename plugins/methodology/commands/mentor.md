---
name: mentor
description: |
  **Use when:** the user types `/mentor <concept>` to get a concept explained at
  their level rather than executed.
  **Do NOT use when:** the user wants the thing done, not explained.
  **Inputs:** a concept or area.
  **Outputs:** an explanation tailored to the asker.
argument-hint: "<concept>"
allowed-tools: [Read, Grep]
---

# /mentor

Apply the procedure in `methodology.mentor`. Detect level, pitch the explanation, use concrete examples, soft handoff to next step.
