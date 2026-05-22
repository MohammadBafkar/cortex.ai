---
capability_interface_id: emitDORA
version: 1
bundle_contract_id: release
schema_in: ReleaseRecord@v1[]
schema_out: DORAMetricsReport@v1
---

# emitDORA@v1

Computes DORA four-plus-one metrics (deploy frequency, lead time, change failure rate, MTTR, reliability) over a window. Helper at `skills/emit-dora/scripts/compute-dora-metrics.sh`.

## Inputs

- `ReleaseRecord@v1[]` + `IncidentRecord@v1[]` over the window (default 28d).
- SLO compliance from the audit log (`attributes.slo_compliance_pct`).

## Outputs

- `DORAMetricsReport@v1` at `.agents/state/finops/<period>/release-operate/dora.json` with the four-plus-one + an archetype label.

## Non-functional contract

- **Idempotency:** yes per window.
- **Latency budget:** p95 ≤ 30 s (mostly a single jq pass over the audit log; Haiku-class).
- **Token budget:** ≤ 5K.
- **HITL:** none for emission; checkpoint 39 (Board update authoring) applies when the report is rolled up.

## Failure modes

- No releases in window → emit with `deploy_frequency: 0` + a `note` flag; never fabricate.
- Insufficient SLO data → `reliability: null`; do not interpolate.
- Archetype assignment with no numeric basis → refuse (per the hard rule in the SKILL.md).

## Fixtures

Golden: `dora-28d-window`.
Adversarial: `dora-fabricated-archetype` (refused).
