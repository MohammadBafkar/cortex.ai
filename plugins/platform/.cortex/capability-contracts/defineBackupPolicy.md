---
capability_interface_id: defineBackupPolicy
version: 1
bundle_contract_id: resilience-dr
schema_in: EnvDefinition@v1
schema_out: BackupPolicy@v1
---

# defineBackupPolicy@v1

Declares backup frequency, retention, RPO, RTO per data-store in an environment.

## Inputs

- `EnvDefinition@v1` + data classification map (from `data.define-pipeline` for hot stores; from `EnvDefinition` for system stores).

## Outputs

- `BackupPolicy@v1` at `.agents/state/dr/<env-id>/platform/backup-policy.json`.

## Non-functional contract

- **Idempotency:** yes per env + data class.
- **Latency budget:** p95 ≤ 30 s.
- **Token budget:** ≤ 5K.
- **HITL:** **checkpoint 41** (Define backup policy / DR) — `rbac/dr-leads`. Cross-region copy → checkpoint 16 (Cross-workspace artifact share).

## Failure modes

- RPO > retention → refuse (guarantees data loss).
- Data class ≥ `confidential` without cross-region copy → refuse for new envs.
- RTO without a drill schedule → refuse (untested policy is just a wish).

## Fixtures

Golden: `backup-policy-for-checkout-env`.
Adversarial: `backup-policy-rpo-exceeds-retention` (refused).
