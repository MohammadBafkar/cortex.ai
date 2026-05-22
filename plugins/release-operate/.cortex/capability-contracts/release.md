---
capability_interface_id: release
version: 1
bundle_contract_id: release
schema_in: BuildArtifact@v1
schema_out: ReleaseRecord@v1
---

# release@v1

Staged rollout (canary → expanded → full) with explicit HITL gates per stage.

## Inputs

- `BuildArtifact@v1` (required) — must be signed; signature verified.

## Outputs

- `ReleaseRecord@v1` + `RolloutPlan@v1` at `.agents/state/releases/<id>/release-operate/`.

## Non-functional contract

- **Irreversibility:** every stage transition is irreversible — rollback is a *separate* capability requiring its own HITL.
- **Latency budget:** dominated by stage monitoring windows; the orchestration overhead p95 ≤ 30 s per stage transition.
- **Token budget:** ≤ 10K (mostly orchestration).
- **HITL:** **M-tier checkpoint 1** (Production GA release) mandatory on prod stage. SLA 24h, fail-closed = hold release.

## Failure modes

- Unsigned artifact → refuse.
- Auto-rollback trigger fires during a stage → halt rollout + open IncidentRecord.
- HITL approval expires → state: `expired`; resumable via `/resume <release-id>` after re-request.

## Fixtures

Golden: `staged-release-with-canary`.
Adversarial: `release-without-signed-artifact` (refused), `release-skips-prod-hitl` (PEP blocks).
