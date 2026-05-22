---
name: rollback
description: |
  **Use when:** `/rollback [release-id]` to revert a production release.
  M-tier HITL (checkpoint 2).
  **Do NOT use when:** the user wants to deploy forward (`/release`).
  **Inputs:** release-id.
  **Outputs:** RollbackRecord@v1.
argument-hint: "<release-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /rollback
Dispatch `release-manager` in rollback mode against the named ReleaseRecord.
