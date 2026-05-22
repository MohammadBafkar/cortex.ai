---
name: data.run-experiment
description: |
  **Use when:** the team wants a structured A/B/n experiment with explicit
  hypothesis + success metrics + guardrails. Triggers on: "/experiment".
  **Do NOT use when:** the user wants performance benchmarking (use
  `quality.benchmark`) or feature-flag toggling without measurement (use
  `release-operate.release`'s canary).
  **Inputs:** ExperimentSpec@v1.
  **Outputs:** ExperimentResult@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runExperiment
bundle_contract_id: experimentation
visibility: public
---

# run-experiment

Hypothesis-driven A/B/n experimentation with guardrails.

## Procedure

1. **Compose `methodology.hypothesis-test` inline** (P2 — methodology v2.0).
   Hypothesis must be falsifiable.
2. **Define** treatment / control, sample size (power analysis), duration,
   primary metric, guardrail metrics (e.g., latency, error rate), exit
   conditions (early-stop on guardrail breach).
3. **HITL** per checkpoint 13 (Chaos / experiments in prod, C-tier MVP1)
   when the experiment touches prod.
4. **Run** via the experimentation platform.
5. **Analyze.** Statistical significance + practical significance. Reject
   p-hacking — pre-registered metrics only.
6. **Compose `methodology.verify` inline.**
7. **Write** ExperimentResult with decision (ship / kill / iterate).

## Hard rules

- **No pre-registered metric changes mid-flight.**
- **No experiments without exit conditions.**
- **HITL on prod experiments.**
