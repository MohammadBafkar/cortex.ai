---
name: lang-python.lint-with-ruff
description: |
  **Use when:** a Python PR needs a lint pass using ruff (the project's
  configured profile). Triggers on: "/ruff", "lint this".
  **Do NOT use when:** the user wants to author tests (use `write-pytest-test`),
  format only (ruff also formats; this skill covers both), or non-Python lint.
  **Inputs:** PullRequest@v1 with Python diff.
  **Outputs:** LintReport@v1 at `.agents/state/langs/lang-python/<pr-id>/lint.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: lintWithRuff
bundle_contract_id: lang-python
visibility: public
---

# lint-with-ruff

Run `ruff check` + `ruff format --check` against the diff. Report violations with rule id + fix suggestion.

## Procedure

1. Confirm the project has `ruff` configured (`pyproject.toml` `[tool.ruff]` or `ruff.toml`). If not, propose a starter config but do NOT add it without HITL.
2. Run `ruff check <changed-files>` + `ruff format --check <changed-files>`.
3. For each violation: rule id, line, severity (auto-fixable / manual), suggestion.
4. Group by category: style / bug-risk / complexity / security.
5. Compose `methodology.verify` inline.
6. Write LintReport.

## Hard rules

- **Don't run `ruff --fix` without HITL.** Surface suggestions; let the user accept or reject.
- **Honor the project's configured profile.** Don't impose stricter rules than configured.
