---
name: dora
description: |
  **Use when:** `/dora [window]` to emit the DORA four-plus-one metrics report
  over the named window (default 28d).
  **Do NOT use when:** the user wants a single-release report (use
  `/postmortem` for incidents, `/measure` for adoption).
  **Inputs:** optional window (e.g., 7d, 28d, 90d).
  **Outputs:** DORAMetricsReport@v1.
argument-hint: "[window]"
allowed-tools: [Task, Read, Bash, Write]
---

# /dora
Dispatch `sre-observer` in DORA mode against the named window.
