---
name: release
description: |
  **Use when:** `/release [build-id]` to ship a signed BuildArtifact via staged
  rollout. M-tier HITL on prod GA.
  **Do NOT use when:** the user wants to rollback (`/rollback`) or build only
  (`platform.run-pipeline`).
  **Inputs:** build-id.
  **Outputs:** ReleaseRecord@v1.
argument-hint: "<build-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /release
Dispatch `release-manager` against the named BuildArtifact.
