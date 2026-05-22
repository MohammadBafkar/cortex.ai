---
name: plugin-feedback
description: |
  **Use when:** the user types `/plugin-feedback` to aggregate the last N days
  of telemetry into a PluginFeedback@v1 artifact per plugin — symptoms include
  rerouted invocations, frequent HITL overrides, prompt-injection trust-label
  downgrades, conformance regressions.

  **Do NOT use when:** the user wants live audit query (`/audit`) or a one-shot
  conformance run (`/conformance`).

  **Inputs:** optional time window (default: last 7 days).
  **Outputs:** PluginFeedback@v1 per plugin at
  `.agents/state/feedback/<plugin>/<date>.json`.
argument-hint: "[days]"
allowed-tools: [Task, Read, Bash, Write]
---

# /plugin-feedback

Run `bash $CORTEX_HOME/platform/conformance/aggregate-feedback.sh` (P1 deliverable). MVP1 stub: render the symptom inventory from the last 7 days of audit log without producing the typed artifact.
