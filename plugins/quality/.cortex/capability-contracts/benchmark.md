---
capability_interface_id: benchmark
version: 1
bundle_contract_id: performance
schema_in: PullRequest@v1
schema_out: BenchmarkResult@v1
---

# benchmark@v1

Captures a perf baseline and diffs against the prior baseline. Driven by `skills/benchmark/scripts/compare-perf.py`.

## Inputs

- `PullRequest@v1` with perf-sensitive changes.
- Baseline `BenchmarkResult@v1` at `.agents/state/runs/baseline/quality/benchmark.json`.

## Outputs

- `BenchmarkResult@v1` at `.agents/state/runs/<pr-id>/quality/benchmark.json` with metrics + `comparison` field.

## Non-functional contract

- **Same-hardware invariant:** baseline + candidate must run on the same hardware class. Cross-hardware comparisons are refused.
- **Latency budget:** dominated by the benchmark itself. Orchestration overhead p95 ≤ 30 s.
- **Token budget:** ≤ 5K (Haiku-class).
- **HITL:** ≥ 25% p95 regression on any metric → state: `requires_human`; HITL on whether to merge.

## Failure modes

- Baseline missing → capture candidate as the new baseline; do not compare.
- Cross-hardware comparison requested → refuse.
- Bounded run time exceeded → refuse with `/benchmark --long` guidance.

## Fixtures

Golden: `benchmark-flags-regression`.
Adversarial: `benchmark-different-hardware` (refused).
