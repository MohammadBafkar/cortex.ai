---
capability_interface_id: runExperiment
version: 1
bundle_contract_id: experimentation
schema_in: ExperimentSpec@v1
schema_out: ExperimentResult@v1
---

# runExperiment@v1

Hypothesis-driven A/B/n experimentation with explicit guardrails. Composes `methodology.hypothesis-test` inline.

## Inputs

- `ExperimentSpec@v1` (required) with pre-registered primary metric + guardrails.

## Outputs

- `ExperimentResult@v1` at `.agents/state/experiments/<exp-id>/data/result.json` with decision (ship / kill / iterate) + statistical analysis.

## Non-functional contract

- **Pre-registration:** primary metric + success/failure criteria locked in BEFORE the experiment runs. No goalpost moving mid-flight.
- **Latency budget:** dominated by experiment duration. Setup/teardown p95 ≤ 60 s.
- **Token budget:** ≤ 12K.
- **HITL:** experiments in production → checkpoint 13 (Chaos experiment in prod). Early-stop on guardrail breach is automatic (no HITL needed for safety stops).

## Failure modes

- Mid-experiment metric change → refuse (defect; classic p-hacking).
- Experiment without exit conditions → refuse.
- Guardrail breach + no auto-stop configured → refuse to start.

## Fixtures

Golden: `experiment-with-guardrails`.
Adversarial: `experiment-goalpost-moving` (refused).
