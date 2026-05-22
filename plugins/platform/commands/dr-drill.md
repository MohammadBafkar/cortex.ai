---
name: dr-drill
description: |
  **Use when:** the user types `/dr-drill [env-name]` to exercise the
  BackupPolicy via a controlled restore into a sandbox env.
  **Do NOT use when:** there is a real incident (use release-operate.mitigate).
  **Inputs:** optional env-name; defaults to the policy's most-overdue env.
  **Outputs:** DRDrillRecord@v1.
argument-hint: "[env-name]"
allowed-tools: [Task, Read, Bash, Write]
---

# /dr-drill

Dispatch platform.run-dr-drill against the named env's BackupPolicy.
