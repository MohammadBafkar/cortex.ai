---
capability_interface_id: runUnitTests
version: 1
bundle_contract_id: test-execution-read
schema_in: TestSuite@v1
schema_out: TestRun@v1
---

# runUnitTests@v1

Executes a `TestSuite@v1` locally (outside the full CI pipeline) and produces a `TestRun@v1`. This is the **read-side** of test execution — the full pipeline is owned by `platform.run-pipeline`.

## Inputs

- `TestSuite@v1` (required) — written by `quality.write-unit-test`.

## Outputs

- `TestRun@v1` at `.agents/state/runs/<run-id>/quality/test-run.json` with: `suite_id`, `cases_passed`, `cases_failed`, `coverage`, `state`.

## Why two test-run capabilities

- `quality.run-unit-tests` is the local, fast, developer-loop run used during the `bugTriage` "confirm test fails" / "confirm test passes" beats. It runs outside CI.
- `platform.run-tests` is the CI-side run that produces the authoritative `TestRun@v1` for the build pipeline.

Both write to `runs/<id>/quality/` vs `runs/<id>/platform/` respectively — distinct contributor subdirs prevent overlap.

## Non-functional contract

- Idempotent on `(suite_id, commit_sha)`.
- p95 latency budget: 30 s for a small suite.

## Failure modes

- Suite file missing → `state: failed`, `failure_reason: missing_suite`.
- Test runner not installed → `state: requires_human` with installation guidance.
