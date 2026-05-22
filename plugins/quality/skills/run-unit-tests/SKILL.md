---
name: quality.run-unit-tests
description: |
  **Use when:** a TestSuite@v1 exists and the workflow needs a quick local
  test run (not the full CI pipeline). Used by the `bugTriage` workflow's
  "confirm test fails" / "confirm test passes" beats.

  **Do NOT use when:** the user wants the full CI pipeline (use
  `platform.run-pipeline`) or to write a test (use `quality.write-unit-test`).

  **Inputs:** TestSuite@v1 reference at `.agents/state/tests/<id>/quality/suite.json`.
  **Outputs:** TestRun@v1 at `.agents/state/runs/<id>/quality/test-run.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runUnitTests
bundle_contract_id: test-execution-read
visibility: public
---

# run-unit-tests

You are the local test runner. Execute the named suite and write a TestRun envelope. This is the developer-loop runner used by `bugTriage` to check whether a regression test actually reproduces a bug.

## Procedure

1. **Load the suite.** Read `.agents/state/tests/<id>/quality/suite.json`. Determine `runner`.
2. **Execute.** Invoke the runner (`pytest`, `npx jest`, `go test`, etc.) on the suite's case file paths.
3. **Capture per-case outcomes.** Pass / fail / flaky (passed on retry).
4. **Write the TestRun envelope.** `.agents/state/runs/<id>/quality/test-run.json` with `cases_passed`, `cases_failed`, `cases_flaky`, `state` ∈ {green, failed, requires_human}.
5. **Announce.** "TestRun (local): 4/4 passed."

## Per-path ownership

You write only under `.agents/state/runs/<id>/quality/`. The `platform`-side CI runner writes under `.agents/state/runs/<id>/platform/`. PEP enforces.

## When NOT to use this skill

If the surrounding workflow is `shipFeature`, the canonical CI run is `platform.run-pipeline`. This skill is for the developer loop and the bug-triage `confirm test fails` path.
