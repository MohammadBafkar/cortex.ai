---
capability_interface_id: writeUnitTest
version: 1
bundle_contract_id: test-authoring
schema_in: PullRequest@v1
schema_out: TestSuite@v1
---

# writeUnitTest@v1

Authors unit tests for the behavior introduced by a `PullRequest@v1`. Writes a `TestSuite@v1` envelope plus the actual test files under the project's test directory.

## Inputs

- `PullRequest@v1` (required) — the diff that needs tests. Test stubs flagged in the PR's `test_todos[]` field are the primary input; the test author may add additional cases by reading the diff itself.
- `UserStory@v1` (optional) — for behavioral context.
- `ADR@v1` (optional) — when an architecture decision constrains how something should be tested.

## Outputs

- `TestSuite@v1` envelope at `.agents/state/tests/<pr-id>/quality/suite.json` with: `suite_id`, `pr_id`, `runner` (jest|pytest|go-test|...), `cases[]` listing test file paths + names.
- The test files themselves under the project's test directory (e.g., `tests/`, `__tests__/`, `src/**/*.test.ts`).

## Boundary with engineering

- **Engineering NEVER writes test files.** PEP enforces. Engineering may mark `test_todos` in the PR body, which is then quality's input.
- **Quality NEVER edits production code.** PEP enforces on the production paths via the per-project layout convention.

## Methodology composition (inline)

- `methodology.tdd` — composed inline on each behavior-changing case to enforce red-green-refactor. If the surrounding workflow is `bugTriage`, the discipline becomes "write a failing test that reproduces the bug first".

## Non-functional contract

- Idempotent on `(pr_id, commit_sha)`: re-runs produce the same case ids (modulo non-deterministic naming, tolerated up to one rename per case).
- p95 latency budget: 60 s for ≤ 4 test cases.

## Golden fixtures

- Write a passing test for an added function.
- Write a failing test that reproduces a flagged bug (the bug-triage path).

## Adversarial fixtures

- Skip-test request from the user → refuse, citing `methodology.tdd`.
- Attempt to write a test that mutates production code → PEP blocks.
- Cross-bundle write attempt (test author tries to write under `prs/<pr-id>/engineering/`) → PEP blocks.
