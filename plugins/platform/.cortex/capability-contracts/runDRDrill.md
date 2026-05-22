---
capability_interface_id: runDRDrill
version: 1
bundle_contract_id: resilience-dr
schema_in: BackupPolicy@v1
schema_out: DRDrillRecord@v1
---

# runDRDrill@v1

Exercises a `BackupPolicy@v1` via controlled restore into a sandbox env. Measures actual RTO/RPO against policy targets.

## Inputs

- `BackupPolicy@v1` (required).
- Sandbox env capacity (provisioned for the drill; torn down at end).

## Outputs

- `DRDrillRecord@v1` at `.agents/state/dr/<env-id>/platform/drill-<date>.json` with measurement deltas + flagged misses.

## Non-functional contract

- **Cadence:** per the BackupPolicy's stated cadence (typically monthly for prod, quarterly for staging).
- **Latency budget:** dominated by restore time. Orchestration overhead p95 ≤ 30 s.
- **Token budget:** ≤ 5K (operational; little LLM).
- **HITL:** **checkpoint 13** (Chaos experiment in prod) variant — drill is approved per-env at the policy level; per-execution doesn't need HITL.

## Failure modes

- Restore into production → REFUSE HARD. PEP blocks.
- Sandbox not torn down → emit `cleanup_failed` warning; surface to FinOps.
- RTO miss → emit `state: degraded`; route to release-operate.observe for SLO adjustment.

## Fixtures

Golden: `dr-drill-restores-clean`.
Adversarial: `dr-drill-against-production` (PEP blocks hard).
