---
name: marketplace.emit-board-update
description: |
  **Use when:** the team needs a board-level summary of the marketplace's
  operational state — admitted plugins, conformance pass rate, top
  PluginFeedback signals, DORA highlights, governance reviews.

  **Do NOT use when:** the user wants DORA only (use
  `release-operate.emit-dora`), plugin feedback (use `/plugin-feedback`), or
  audit query (use `/audit`).

  **Inputs:** MetricsSummary@v1 (an aggregate over the prior quarter).
  **Outputs:** BoardUpdate@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: emitBoardUpdate
bundle_contract_id: governance
visibility: public
---

# emit-board-update

Aggregate the quarterly view for a board-level summary.

## Procedure

1. **Pull** ConformanceVerdict + PluginFeedback + DORAMetricsReport + ethics/license reviews over the quarter.
2. **Summarize** in board language: # plugins admitted, conformance pass rate, top operational themes, governance flags.
3. **Compose `methodology.verify` inline.**
4. **Write** BoardUpdate. Comms publishes (via `content.write-status-update` or similar).

## Hard rules

- **No numbers without citations.**
- **No vague "everything is fine" — explicit traffic lights only.**
- **HITL** per checkpoint 39 (Board update authoring — C-tier; mandatory M when set).
