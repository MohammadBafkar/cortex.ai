---
name: release-operate.observe
description: |
  **Use when:** the team needs SLO definitions, Alert rules, and Dashboards for
  a service or environment. Triggers on: "/observe", "define SLOs for X".
  **Do NOT use when:** the user wants to respond to an active alert (use
  `/incident-from-alert`), benchmark a PR (use `quality.benchmark`).
  **Inputs:** EnvironmentRecord@v1 + SystemDesignDoc@v1.
  **Outputs:** SLO@v1[] + Alert@v1[] + Dashboard@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: observe
bundle_contract_id: observability
visibility: public
---

# observe

Define SLOs that map to user-perceptible properties; author Alert rules from those SLOs; build a Dashboard.

## Procedure

1. **Read** the SystemDesignDoc's NFRs + the EnvironmentRecord.
2. **Define SLOs.** Each SLO has: SLI (the measurable signal), target (e.g., 99.5% p99 < 300ms), window (e.g., rolling 28d), error budget.
3. **Define Alerts.** Alert rules derive from SLO error-budget burn rate, not from raw thresholds. Page on burn rate severe enough to exhaust the budget in N hours.
4. **Build the Dashboard** with: error-budget remaining, current burn rate, top 5 endpoints by SLI, recent deploys overlaid (for change-correlation).
5. **Compose `methodology.verify` inline.**
6. **Write** artifacts.

## Hard rules

- **No SLO without an explicit error budget.**
- **No Alert that pages on a raw threshold without burn-rate context.**
