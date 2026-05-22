---
capability_interface_id: writePytestTest
version: 1
bundle_contract_id: lang-python
schema_in: PullRequest@v1
schema_out: TestSuite@v1
---

# writePytestTest@v1

Specializes `quality.writeUnitTest@v1` for Python projects. Authors pytest-idiomatic unit tests (fixtures, parametrize, monkeypatch, tmp_path).

## Inputs

- `PullRequest@v1` with changes under `*.py` files.

## Outputs

- `TestSuite@v1` (type=unit, runner=pytest) at `.agents/state/langs/lang-python/<pr-id>/suite.json` + the test files themselves under the project's test directory.

## Competing-providers rule

Per `ARCHITECTURE.md` §9.4, when both `quality.write-unit-test` and `lang-python.write-pytest-test` are admitted, the workspace's pin (default: language-detect → if Python, prefer `lang-python.write-pytest-test`) selects the provider.

## Non-functional contract

- **Idempotency:** yes on same diff + same model.
- **Latency budget:** p95 ≤ 60 s for ≤ 4 test cases (matches `quality`'s budget).
- **Token budget:** ≤ 12K.
- **HITL:** none for authoring; only the platform CI gate determines whether tests must pass before merge.

## Failure modes

- PR has no `*.py` files → refuse and hand off to generic `quality.write-unit-test`.
- `pytest.skip(...)` without reason → refuse.
- Production-code edits → PEP blocks.

## Fixtures

Golden: `pytest-test-for-added-function`, `pytest-test-with-parametrize`, `pytest-bug-reproduction`.
Adversarial: `pytest-skip-without-reason` (refused), `pytest-modifies-production-code` (PEP blocks).
