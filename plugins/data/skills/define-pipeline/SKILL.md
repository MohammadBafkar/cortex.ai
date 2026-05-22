---
name: data.define-pipeline
description: |
  **Use when:** a new data pipeline (ETL/ELT/streaming) needs definition —
  source, schema, transformations, sink, schedule, SLAs.
  **Do NOT use when:** the user wants ML training (`train-model`),
  experimentation (`run-experiment`), or operational alerts (use
  `release-operate.observe`).
  **Inputs:** DataSourceSpec@v1.
  **Outputs:** DataPipeline@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: definePipeline
bundle_contract_id: data-engineering
visibility: public
---

# define-pipeline

Define an end-to-end data pipeline with explicit schemas + privacy classification.

## Procedure

1. **Read** the DataSourceSpec + applicable PIA.
2. **Per source field**, set data class (`internal | confidential | pii_restricted`). PII flows require explicit handling per the PIA.
3. **Transformations** + their effect on data classes (e.g., aggregation might downgrade `pii_restricted` → `internal`).
4. **Sink** with retention policy + cross-region copy if class ≥ `confidential`.
5. **Schedule + SLAs** (freshness, completeness).
6. **Compose `methodology.risk-assess` inline** — loss, corruption, schema drift.
7. **Compose `methodology.verify` inline.**
8. **Write** DataPipeline + the dbt/airflow/spark spec alongside.

## Hard rules

- **Every field has a data class.**
- **PII flows require PIA + lawful basis.**
- **No pipeline without freshness SLA.**
