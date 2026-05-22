---
capability_interface_id: queryAuditLog
version: 1
bundle_contract_id: audit-thin
schema_in: AuditQuery@v1
schema_out: AuditQueryResult@v1
---

# queryAuditLog@v1

Reads the durable audit sink written by `platform/audit/audit-append.sh` and returns matching events.

## Inputs

- `AuditQuery@v1` — a jq filter expression and an optional date range.

## Outputs

- `AuditQueryResult@v1` — the matching `TelemetryEvent@v1` records, plus an `EvidencePack@v1` reference when the query is in support of a compliance audit (P1+ via `security` Privacy & Compliance bundle).

## Procedure

Shells out to `platform/audit/audit-query.sh` with the query expression. The result is rendered to chat (small queries) or written to `.agents/state/workflows/<run-id>/audit-result.json` (large queries).

## Permission scope

- `audit:read` (low, auto-approval). No write paths.

## Cadence

- **On demand** via `/audit <query>`.
- **Weekly digest** via the `aggregateFeedback` capability (PluginFeedback@v1 generation).
- **Per-PR snapshot** at the end of every `shipFeature` workflow (the demo path).
