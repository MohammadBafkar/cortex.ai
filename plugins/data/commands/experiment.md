---
name: experiment
description: |
  **Use when:** `/experiment [spec-id]` to design and run an A/B/n experiment.
  **Inputs:** spec-id.
  **Outputs:** ExperimentResult@v1.
argument-hint: "<spec-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /experiment
Dispatch `experimenter`.
