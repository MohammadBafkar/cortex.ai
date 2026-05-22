---
name: promote-model
description: |
  **Use when:** `/promote-model [candidate-id]` to promote a ModelCandidate
  to prod. Requires two-person HITL (checkpoint 11).
  **Inputs:** candidate-id.
  **Outputs:** ModelRecord@v1.
argument-hint: "<candidate-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /promote-model
Dispatch `ml-engineer` in promote mode.
