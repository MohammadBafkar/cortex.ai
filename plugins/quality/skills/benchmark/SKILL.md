---
name: quality.benchmark
description: |
  **Use when:** a PR introduces performance-sensitive behavior and the team
  wants a benchmark + comparison against the baseline. Used by the
  `perfRegression` workflow. Triggers on: "/benchmark", "is this slower?".

  **Do NOT use when:** the user wants a unit test (use `write-unit-test`),
  full CI pipeline (use `platform.run-pipeline`), or production observability
  (`release-operate.observe` at P1).

  **Inputs:** PullRequest@v1.
  **Outputs:** BenchmarkResult@v1 at
  `.agents/state/runs/<id>/quality/benchmark.json` with comparison vs the
  baseline at `.agents/state/runs/baseline/quality/benchmark.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: benchmark
bundle_contract_id: performance
visibility: public
---

# benchmark

Run a perf benchmark + compare against the captured baseline. Flag regressions.

## Procedure

1. **Read PR + identify perf-sensitive surfaces.** From PR file paths + the SystemDesignDoc's `nfr_specs` if present.
2. **Compose `methodology.read-code` inline** to scope the surface.
3. **Run the benchmark.** k6, hyperfine, criterion — per the project's stack.
4. **Compare against baseline.** Invoke `${CLAUDE_PLUGIN_ROOT}/skills/benchmark/scripts/compare-perf.py` with `--baseline` and `--candidate` paths; default `--warn-pct 10` and `--block-pct 25`. Script exits 0 (ok), 1 (warning), 2 (blocking) and emits a JSON diff that goes into the BenchmarkResult envelope's `comparison` field.
5. **Compose `methodology.risk-assess` inline** on any flagged regression.
6. **Write the report.** `.agents/state/runs/<id>/quality/benchmark.json` + per-metric numbers + the diff.

## Hard rules

- **Same hardware as baseline.** Cross-hardware comparisons are noise; refuse if baseline was captured on different specs.
- **Bounded run time.** ≤ 10 min per benchmark; longer runs need `/benchmark --long` and explicit user approval.

## Failure modes

- Baseline missing → capture this run as the baseline; do not compare.
- ≥ 25% p95 regression → `state: requires_human`; HITL on whether to merge.
