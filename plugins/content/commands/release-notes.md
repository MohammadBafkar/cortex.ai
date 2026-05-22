---
name: release-notes
description: |
  **Use when:** `/release-notes [release-id]` to author user-facing release notes.
  **Do NOT use when:** the user wants internal docs (`/doc`).
  **Inputs:** release-id.
  **Outputs:** ReleaseNotes@v1.
argument-hint: "<release-id>"
allowed-tools: [Task, Read, Bash, Write]
---
# /release-notes
Dispatch `technical-writer`.
