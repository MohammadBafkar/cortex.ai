---
name: platform.define-backup-policy
description: |
  **Use when:** a new env or new data-store needs a backup policy (frequency,
  retention, RPO/RTO, restore drill cadence).
  **Do NOT use when:** the user wants a DR drill (use `run-dr-drill`) or
  privacy retention (use `security.run-pia`).
  **Inputs:** EnvDefinition@v1 + the data classification map.
  **Outputs:** BackupPolicy@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: defineBackupPolicy
bundle_contract_id: resilience-dr
visibility: public
---

# define-backup-policy

Declare backup frequency, retention, RPO (recovery-point objective), and RTO (recovery-time objective) per data-store.

## Procedure

1. **Inventory data-stores** referenced by the EnvDefinition.
2. **Per data-store**, set: backup frequency, retention window, encryption-at-rest, cross-region copy if data class ≥ `confidential`.
3. **Set RPO + RTO targets** per the service's tier.
4. **Compose `methodology.risk-assess` inline** — what does losing the backup itself mean?
5. **Verify** via `methodology.verify`.
6. **Write** the BackupPolicy.

## Hard rules

- **RPO ≤ retention period.** Otherwise we'd guarantee data loss before backup arrives.
- **RTO must be tested.** No policy without a drill (see `run-dr-drill`).
