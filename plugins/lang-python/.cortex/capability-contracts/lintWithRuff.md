---
capability_interface_id: lintWithRuff
version: 1
bundle_contract_id: lang-python
schema_in: PullRequest@v1
schema_out: LintReport@v1
---

# lintWithRuff@v1

Runs `ruff check` + `ruff format --check` against a PR's Python diff; emits a `LintReport@v1` with rule id + fix suggestion per violation.

## Inputs

- `PullRequest@v1` with Python diff.
- Project's ruff configuration (auto-detected from `pyproject.toml` or `ruff.toml`).

## Outputs

- `LintReport@v1` at `.agents/state/langs/lang-python/<pr-id>/lint.json` with per-violation rule + severity.

## Non-functional contract

- **Idempotency:** yes (ruff output is deterministic).
- **Latency budget:** p95 ≤ 15 s for a small repo (ruff is fast).
- **Token budget:** ≤ 3K (Haiku-class — almost no LLM reasoning, just orchestration).
- **HITL:** mandatory before applying `ruff --fix` autocorrections.

## Failure modes

- No ruff config in the project → propose a starter config; do NOT add without HITL.
- Auto-fix without HITL → PEP blocks.
- Project config requires stricter rules than installed ruff supports → emit warning, run with available rules.

## Fixtures

Golden: `ruff-flags-unused-import`.
Adversarial: `ruff-auto-fix-without-hitl` (PEP blocks).
