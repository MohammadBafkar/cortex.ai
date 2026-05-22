---
capability_interface_id: aggregateFeedback
version: 1
bundle_contract_id: plugin-conformance-eval
schema_in: TelemetryEvent@v1[]
schema_out: PluginFeedback@v1
---

# aggregateFeedback@v1

Aggregates passive telemetry symptoms into a weekly `PluginFeedback@v1` per plugin. Driven by `platform/conformance/aggregate-feedback.sh`.

## Inputs

- `TelemetryEvent@v1[]` from the durable audit sink over the window (default 7d).

## Outputs

- `PluginFeedback@v1` per plugin per period at `.agents/state/feedback/<plugin>/<date>.ndjson`. Promoted to CAS with mutable ref `feedback_<plugin>_<window-end>`.

## Symptoms detected

- Rerouted invocations, HITL overrides, prompt-injection trust-label downgrades, conformance regressions, token-budget warnings/blocks, PEP blocks, nested-dispatch attempts, hook timeouts, perf-budget overruns.

## Non-functional contract

- **Cadence:** weekly (cron) plus on-demand via `/plugin-feedback`.
- **Idempotency:** yes per window.
- **Latency budget:** p95 ≤ 60 s for a week of audit log on a single-org workspace.
- **Token budget:** none — pure shell/jq aggregation.
- **HITL:** action items flagged `blocking` route to the owning plugin's maintainer.

## Failure modes

- Empty audit sink → emit envelope with all symptom counts = 0 + note flag.
- Plugin id matches no installed plugin → emit anyway (orphan-plugin marker for cleanup).

## Fixtures

Golden: `aggregate-feedback-weekly-cron`.
Adversarial: `aggregate-feedback-fabricates-events` (refused).
