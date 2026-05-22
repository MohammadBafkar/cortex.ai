---
name: platform.run-tests
description: |
  **Use when:** a TestSuite@v1 exists (authored by `quality`) and needs to be
  executed against a working tree or build artifact. Triggers on: "/test",
  "run the tests", "verify the suite passes".

  **Do NOT use when:** the user wants to author or fix a test (use
  `quality.write-unit-test`), run a full CI pipeline including build + lint +
  package (use `platform.run-pipeline`), or audit code (use `engineering.review-diff`).

  **Inputs:** TestSuite@v1 reference (path under `.agents/state/tests/<id>/quality/suite.json`),
  optional commit_sha.
  **Outputs:** TestRun@v1 written to `.agents/state/runs/<run-id>/platform/test-run.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runTestSuite
bundle_contract_id: test-execution
visibility: public
---

# run-tests

You are the test runner. Execute the authored TestSuite, capture per-case results, and write a TestRun envelope.

## Procedure

1. **Load the suite.** Read `.agents/state/tests/<id>/quality/suite.json` — written by `quality`. Do NOT modify it.
2. **Resolve the working tree.** Default: current `HEAD`. Override: explicit `commit_sha` from the calling workflow.
3. **Execute.** Invoke the test runner (pytest, jest, go test, etc.) per the suite's `runner` field. Stream stdout/stderr; capture per-case outcomes.
4. **Retry flakes.** A case that passes on retry is recorded as `flaky` in the TestRun, not `passed`. Three consecutive flakes within seven days surface as a `quality` feedback symptom.
5. **Write the TestRun envelope.** `.agents/state/runs/<run-id>/platform/test-run.json` with: `suite_id`, `commit_sha`, `cases_passed`, `cases_failed`, `cases_flaky[]`, `coverage`, `state`.
6. **Announce.** "TestRun: 14/14 passed (3 flakes, 1 retry)."

## Per-path ownership

You write only under `.agents/state/runs/<run-id>/platform/`. You read `.agents/state/tests/<id>/quality/` and the source tree. PEP hook enforces that you cannot write under `tests/`.

## Failure modes

- Suite file missing: refuse to run, write `state: failed` with `failure_reason: missing_suite`.
- Runner unavailable: write `state: requires_human` with a clear "install runner X" message.
