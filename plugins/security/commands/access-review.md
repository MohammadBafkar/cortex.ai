---
name: access-review
description: |
  **Use when:** the user types `/access-review` to walk every active permission
  grant and flag stale/excess/orphaned grants for HITL action.
  **Do NOT use when:** the user wants to grant a new permission (permission
  broker path).
  **Inputs:** none — the permission broker is the source.
  **Outputs:** AccessReviewRecord@v1.
argument-hint: ""
allowed-tools: [Task, Read, Bash, Write]
---

# /access-review

Dispatch `iam-reviewer`.
