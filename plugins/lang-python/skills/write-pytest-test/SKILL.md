---
name: lang-python.write-pytest-test
description: |
  **Use when:** a Python PullRequest@v1 introduces or changes behavior that
  needs pytest-idiomatic unit tests — fixtures, parametrize, mark.parametrize,
  monkeypatch, pyfakefs. Specializes `quality.write-unit-test` for Python.

  **Do NOT use when:** the user wants generic unit tests (use
  `quality.write-unit-test` directly — it auto-detects pytest/unittest and
  routes here when Python is the language), integration tests
  (`quality.write-integration-test`), or non-Python tests.

  **Inputs:** PullRequest@v1 with changes under `*.py` files.
  **Outputs:** TestSuite@v1 at `.agents/state/langs/lang-python/<pr-id>/`
  plus the actual test files under `tests/` (or project convention).
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writePytestTest
bundle_contract_id: lang-python
visibility: public
---

# write-pytest-test

Author pytest-idiomatic unit tests for Python behavior changes. Specializes `quality.write-unit-test` — competes via the competing-providers rule (SPEC.md) when the project is Python.

## Procedure

1. **Verify the PR touches Python.** If no `*.py` files in the diff, refuse and hand off to the generic `quality.write-unit-test`.

2. **Read the diff.** Identify the changed functions, classes, modules. Compose `methodology.read-code` inline if the touched code is unfamiliar.

3. **Locate the project's test directory.** Auto-detect: `tests/`, `<package>/tests/`, or per `pyproject.toml` (`[tool.pytest.ini_options] testpaths`). Inherit the project's convention.

4. **Compose `methodology.tdd` inline.** Per the discipline, the failing test exists first. If `bugTriage` is the surrounding workflow, the test reproduces the bug before any fix lands.

5. **Author the tests using pytest idioms:**
   - **fixtures** (`@pytest.fixture`) for shared setup; prefer `scope="function"` unless re-creating is expensive
   - **parametrize** (`@pytest.mark.parametrize`) for cases that vary only by inputs
   - **monkeypatch** for runtime patching; `pyfakefs` for filesystem isolation; `freezegun` for time
   - **`tmp_path`** fixture for temp directories (NOT `tempfile.mkdtemp()` directly)
   - **`capsys` / `caplog`** for capturing stdout/log assertions
   - One test = one assertion goal (use `assertpy` or split if you need multiple)
   - Test names: `test_<function>_<scenario>_<expected>` — readable in the failure summary

6. **Author the TestSuite envelope** at `.agents/state/langs/lang-python/<pr-id>/suite.json` with: `runner: "pytest"`, `cases[]`, `python_version`, `dependencies` (from `pyproject.toml`).

7. **Compose `methodology.verify` inline** before promoting.

8. **Announce.** "Wrote 4 pytest cases for PR-12 covering add(), the empty-input case, and TypeError on non-numeric args."

## Hard rules (Python-specific)

- **No bare `assert True` or `assert ...` in production code paths** — pytest tests are an exception, but production assertions need explanation.
- **No `import *` in tests.**
- **No silent test skips.** `pytest.skip(...)` requires a reason that names the unmet precondition.
- **No production-code edits.** PEP enforces. Quality NEVER writes production code.

## Failure handling

- pytest not installed → `state: requires_human` with `pip install pytest` guidance.
- Coverage tooling absent → emit warning; conformance does not block on this in lang-python's MVP slice.

## Latency budget

p95 ≤ 60s for ≤ 4 test cases against changed Python (in line with `quality.write-unit-test`'s budget).

## References

Pytest idiom guidance lives in `${CLAUDE_PLUGIN_ROOT}/skills/write-pytest-test/references/`. Add new files as the team's idiom set evolves.
