---
capability_interface_id: definePipeline
version: 1
bundle_contract_id: data-engineering
schema_in: DataSourceSpec@v1
schema_out: DataPipeline@v1
---

# definePipeline@v1

Authors a `DataPipeline@v1` — source, schema, transformations, sink, schedule, SLAs.

## Inputs

- `DataSourceSpec@v1` (required).
- Applicable `PrivacyImpactAssessment@v1` if PII flows are in scope.

## Outputs

- `DataPipeline@v1` at `.agents/state/data/<pipeline-id>/data/pipeline.json` + the dbt/airflow/spark spec alongside.

## Non-functional contract

- **Idempotency:** yes (same source spec → same pipeline).
- **Latency budget:** p95 ≤ 60 s for a single pipeline.
- **Token budget:** ≤ 15K.
- **HITL:** PII flows → mandatory PIA + lawful-basis citation (per `runPIA`). Cross-region/cross-cloud data movement → checkpoint 16 (Cross-workspace artifact share).

## Failure modes

- Field without data class → refuse (defect; every field is classified).
- PII flow without lawful basis → refuse.
- Pipeline without freshness SLA → refuse.

## Fixtures

Golden: `pipeline-with-pii-flow` (PIA + classification per field).
Adversarial: `pipeline-skips-pii-classification` (refused).
