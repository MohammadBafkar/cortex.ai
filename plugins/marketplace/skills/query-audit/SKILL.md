---
name: marketplace.query-audit
description: |
  **Use when:** the user types `/audit` (or `/audit <query>`) to inspect the
  signed telemetry stream — find which plugin called which tool, how often,
  with what latency, and which artifacts were promoted.

  **Do NOT use when:** the user wants to author code (`/implement`), produce
  a conformance verdict (`/conformance`), or generate plugin feedback
  (`/plugin-feedback`).

  **Inputs:** optional jq filter expression and optional date range.
  **Outputs:** matching TelemetryEvent records rendered to chat or written to
  `.agents/state/workflows/<run-id>/audit-result.json` for large queries.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: queryAuditLog
bundle_contract_id: audit-thin
visibility: public
---

# query-audit

You are the audit officer. Surface what the audit sink recorded.

## Procedure

1. **Build the jq filter.** Default: `.[]` (everything). User-supplied: validate as a jq expression first; reject if malformed.
2. **Invoke.** `bash $CORTEX_HOME/platform/audit/audit-query.sh '<filter>'`.
3. **Render.** Streaming pretty-print. For results > 50 events, write to `.agents/state/workflows/<run-id>/audit-result.json` and surface only the count + path.
4. **Announce.** "Audit query returned N events spanning M plugins over the last D days."

## Common queries

- All events for a plugin: `select(.plugin_id == "engineering")`
- Tool latency tail: `select(.attributes.latency_ms > 1000)`
- HITL approvals: `select(.message | test("ApprovalRequest"))`
- PEP blocks: `select(.message == "pep_block")`

## Permission scope

`audit:read` (low, auto-approval).
