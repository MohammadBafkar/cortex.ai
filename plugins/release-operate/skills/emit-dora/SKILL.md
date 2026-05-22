---
name: release-operate.emit-dora
description: |
  **Use when:** the team wants a DORA metrics report (deploy frequency, lead
  time for changes, change failure rate, mean time to restore, reliability).
  Triggers on: "/dora", weekly cron.
  **Do NOT use when:** the user wants a single-release postmortem (use
  `postmortem`) or product adoption (use `product.measure-adoption`).
  **Inputs:** ReleaseRecord@v1[] over the window + IncidentRecord@v1[] over
  the same window.
  **Outputs:** DORAMetricsReport@v1 at
  `.agents/state/finops/<period>/release-operate/dora.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: emitDORA
bundle_contract_id: release
visibility: public
---

# emit-dora

Compute the four-plus-one DORA metrics from durable telemetry. Per the 2025 DORA report the four metrics are:

- **Deploy frequency** — releases per day per service.
- **Lead time for changes** — commit → production duration.
- **Change failure rate** — deploys that caused incident / rollback / hotfix as a fraction of all deploys.
- **Mean time to restore (MTTR)** — incident open → resolved duration.
- (Plus) **Reliability** — SLO compliance fraction.

## Procedure

1. **Define the window** (default: last 28d).
2. **Invoke the helper script.**
   ```
   bash ${CLAUDE_PLUGIN_ROOT}/skills/emit-dora/scripts/compute-dora-metrics.sh \
        --days 28 [--service <name>]
   ```
   The script reads the durable audit sink + CAS-promoted ReleaseRecord / IncidentRecord history, computes the four-plus-one metrics, classifies the archetype per the 2025 DORA AI Capabilities Model thresholds, and emits a single-line `DORAMetricsReport@v1` on stdout.
3. **Compose `methodology.verify` inline** — do the numbers correlate with what the team knows happened? If a metric is wildly out of line with intuition, re-check the source-data filters (service tag mismatch is the most common cause).
4. **Add the comparison** — diff this window's report vs the prior window's mutable CAS reference `dora_<service>_<window>`. Surface deltas.
5. **Write** the final report to `.agents/state/finops/<period>/release-operate/dora.json`; promote to CAS on SessionEnd.

## Hard rules

- **No metric without a citation** — every number traces back to specific Release / Incident / SLO records.
- **No fabricated archetype assignment** — derive from the metric profile, do not vibe.
