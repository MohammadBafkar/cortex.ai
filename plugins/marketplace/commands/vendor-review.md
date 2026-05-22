---
name: vendor-review
description: |
  **Use when:** `/vendor-review [vendor-name]` to review a proposed external
  vendor with explicit exit path.
  **Do NOT use when:** the user wants license review (`/license-review`) or
  ethics review (`/ethics-review`).
  **Inputs:** vendor-name.
  **Outputs:** VendorReview@v1.
argument-hint: "<vendor-name>"
allowed-tools: [Task, Read, Bash, Write]
---
# /vendor-review
Dispatch `governance-officer`.
