---
name: platform.run-dr-drill
description: |
  **Use when:** the team needs to exercise the BackupPolicy via a controlled
  recovery — restore into a sandbox env, verify integrity, measure actual
  RTO/RPO against targets.
  **Do NOT use when:** there is a real incident (use `release-operate.mitigate`),
  the user wants a backup policy (use `define-backup-policy`), or production
  data needs to be touched (refuse — DR drills run against sandbox copies).
  **Inputs:** BackupPolicy@v1.
  **Outputs:** DRDrillRecord@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runDRDrill
bundle_contract_id: resilience-dr
visibility: public
---

# run-dr-drill

Restore from a recent backup into a sandbox env; verify; measure.

## Procedure

1. **Provision a sandbox env** (cannot share network or data with prod).
2. **Restore** the most recent backup per the BackupPolicy.
3. **Verify integrity** — schema checks + a sampled-row deep-check + the application's bring-up health endpoint.
4. **Measure RTO + RPO** vs targets in the policy. Flag misses.
5. **Compose `methodology.risk-assess` inline** for any miss.
6. **Tear down** the sandbox env.
7. **Write** DRDrillRecord with the timeline + measurement deltas + any flagged risks.

## Hard rules

- **Never restore into prod.** Refuse hard.
- **Tear-down is mandatory.** Sandbox envs accumulate cost; drill must clean up.
- **Cadence enforced.** Per `GOVERNANCE.md` §2.5 — every named env runs a DR drill at the policy's stated cadence.
