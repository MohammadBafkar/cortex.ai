---
name: audit
description: |
  **Use when:** the user types `/audit [query]` to inspect the durable audit
  sink — find which plugins ran, which tools were used, latency tails, PEP
  blocks, HITL prompts, token usage.

  **Do NOT use when:** the user wants conformance (`/conformance`), workflow
  dispatch (`/implement`), or plugin feedback aggregation (`/plugin-feedback`).

  **Inputs:** optional jq filter expression.
  **Outputs:** matching TelemetryEvent records.
argument-hint: "[jq-filter]"
allowed-tools: [Task, Read, Bash]
---

# /audit

Dispatch the `audit-officer` subagent. Default filter (no argument): show the last 50 events. With argument: use as a jq filter against the audit log.
