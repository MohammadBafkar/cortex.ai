---
name: quality.write-unit-test
description: |
  **Use when:** a PullRequest@v1 introduces or changes behavior that needs unit
  test coverage. Triggers from the shipFeature workflow's `test_author` state
  and from the bugTriage workflow's `write_regression_test` state. Also
  triggered when the engineering PR body lists `test_todos[]`.

  **Do NOT use when:** the user wants integration / E2E / contract / mutation
  tests (those land in `quality v1.x` at P1), performance tests (use
  `quality.benchmark` at P1), or to modify production code (use
  `engineering.propose-pr` — quality NEVER writes production code).

  **Inputs:** PullRequest@v1 (id), optional UserStory@v1.
  **Outputs:** TestSuite@v1 envelope at `.agents/state/tests/<pr-id>/quality/suite.json`
  plus the actual test files under the project's test directory.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeUnitTest
bundle_contract_id: test-authoring
visibility: public
---

# write-unit-test

You are the test author. Read the PR diff, write unit tests covering the new or changed behavior, and produce a TestSuite envelope.

## Procedure

1. **Load context.** Read `.agents/state/prs/<pr-id>/engineering/pr.json`. Check `test_todos[]` for explicit stubs the engineering implementer flagged.
2. **Read the diff.** Identify the behavior change: new exported function, modified path, added error case.
3. **Compose `methodology.tdd` inline.** Per the methodology, the test should be authored against the new behavior, exercising both the happy path and at least one failure mode. (When the surrounding workflow is `bugTriage`, the discipline is "the test must initially fail to confirm it reproduces the bug".)
4. **Write the test file(s).** Place them under the project's test directory (auto-detect: `tests/`, `__tests__/`, `*.test.{ts,js}`, `*_test.{go,py}`). Do NOT modify production source files — PEP blocks any such write.
5. **Author the TestSuite envelope.** Write `.agents/state/tests/<pr-id>/quality/suite.json` with: `suite_id`, `pr_id`, `runner`, `cases[]` (file path + test name + brief description).
6. **Verify.** Invoke `methodology.verify` inline — confirm every flagged `test_todo` has a corresponding case in the suite.
7. **Announce.** "Wrote 4 unit-test cases for PR-12 covering add(), the empty-input case, and the type-mismatch error."

## Hard rules

- **No production code edits.** PEP enforces.
- **No skipping tests.** If the user requests a skip, refuse and cite `methodology.tdd`.
- **No writing under another bundle's path.** PEP enforces.

## Latency budget

p95 ≤ 60 s for ≤ 4 test cases.
