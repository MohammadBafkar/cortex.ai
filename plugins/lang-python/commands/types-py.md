---
name: types-py
description: |
  **Use when:** `/types-py [pr-id]` to propose type annotations for unannotated
  Python functions/methods in the PR.
  **Inputs:** pr-id.
  **Outputs:** TypeAnnotationProposal@v1 (unified diff; not auto-applied).
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /types-py
Dispatch a sonnet-class subagent to propose annotations. No auto-apply.
