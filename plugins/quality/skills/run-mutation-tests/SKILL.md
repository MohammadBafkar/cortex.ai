---
name: quality.run-mutation-tests
description: |
  **Use when:** a TestSuite@v1 exists and the team wants to verify test
  *quality* via mutation testing — does each test actually catch a mutated
  version of the code? Triggers on: "mutate this suite", "what's the mutation
  score?".

  **Do NOT use when:** the user wants a regular test run (use `run-unit-tests`
  or `platform.run-pipeline`), benchmark (`benchmark`), or accessibility audit
  (`audit-a11y`).

  **Inputs:** TestSuite@v1.
  **Outputs:** MutationReport@v1 at
  `.agents/state/runs/<id>/quality/mutation.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runMutationTests
bundle_contract_id: test-authoring
visibility: public
---

# run-mutation-tests

Generate mutated variants of the source under test; verify each mutation is caught by at least one test. Surface low-coverage cases for `review-test-coverage` follow-up.

## Procedure

1. **Identify the source files under test** from the suite's `cases[].source_files` hints.
2. **Invoke the mutation runner** (mutpy, stryker, mull, etc. per the project's stack).
3. **Compute the mutation score:** killed / (killed + survived). Survived = a mutation that no test caught — a real test-quality gap.
4. **Author the report.** Per-mutation outcomes + score + recommended additional cases.

## Hard rules

- **Bounded scope.** Mutate ≤ 200 LOC per run; larger surfaces need decomposition.
- **No production-code edits.** The mutation runner writes to a sandbox copy.

## Latency budget

p95 ≤ 5 min for a small surface — mutation testing is genuinely slow.
