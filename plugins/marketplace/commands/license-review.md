---
name: license-review
description: |
  **Use when:** `/license-review` to walk the dependency manifest and classify
  every license; flag copyleft conflicts.
  **Do NOT use when:** the user wants vendor review (`/vendor-review`).
  **Inputs:** none — reads the lockfile.
  **Outputs:** LicenseReview@v1.
argument-hint: ""
allowed-tools: [Task, Read, Bash, Write]
---
# /license-review
Dispatch `governance-officer`.
