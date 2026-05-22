---
capability_interface_id: runTestSuite
version: 1
bundle_contract_id: test-execution
schema_in: TestSuite@v1
schema_out: TestRun@v1
---

# runTestSuite@v1

Executes a `TestSuite@v1` (authored by `quality`) inside the CI pipeline and writes a `TestRun@v1`.

## Inputs

- `TestSuite@v1` (required) — written by `quality.write-unit-test` to `.agents/state/tests/<id>/quality/suite.json`. The platform reads it, never writes it.

## Outputs

- `TestRun@v1` written to `.agents/state/runs/<run-id>/platform/test-run.json` with: `run_id`, `suite_id`, `cases_passed`, `cases_failed`, `coverage`, `state`.

## Per-bundle separation

- **Authoring** (`TestSuite`) belongs to `quality`; **execution** (`TestRun`) belongs to `platform`. The PEP hook enforces:
  - `platform` may not write under `.agents/state/tests/` (that's `quality`'s).
  - `quality` may not write under `.agents/state/runs/` (that's `platform`'s).
- Composite review use cases that aggregate test coverage live under `.agents/state/reviews/<pr-id>/quality/` (composite contributor subdir).

## Non-functional contract

- Idempotent on `(suite_id, commit_sha)`.
- p95 latency budget: 60 s for unit tests. Integration/E2E land in `quality v1.x` at P1.

## Failure handling

- Test failure: `TestRun.state = failed`, `cases_failed > 0`. Build artifact downstream is gated.
- Flake: 1 retry on individual cases; persistent flake surfaces as a `quality` feedback symptom.
