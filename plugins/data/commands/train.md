---
name: train
description: |
  **Use when:** `/train [dataset-id]` to train a candidate model.
  **Inputs:** dataset-id + recipe.
  **Outputs:** ModelCandidate@v1.
argument-hint: "<dataset-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /train
Dispatch `ml-engineer`.
