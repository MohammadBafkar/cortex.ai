---
capability_interface_id: writeVitestTest
version: 1
bundle_contract_id: lang-typescript
schema_in: PullRequest@v1
schema_out: TestSuite@v1
---

# writeVitestTest@v1

Specializes `quality.writeUnitTest@v1` for TypeScript/JavaScript projects. Authors vitest-idiomatic unit tests (it.each, describe/beforeEach, vi.mock, expect.assertions).

## Inputs

- `PullRequest@v1` with changes under `*.ts`, `*.tsx`, `*.js`, or `*.jsx` files.

## Outputs

- `TestSuite@v1` (type=unit, runner=vitest) at `.agents/state/langs/lang-typescript/<pr-id>/suite.json` + the test files themselves (typically `*.test.ts` colocated with sources or under `tests/`, per project convention).

## Competing-providers rule

Per `ARCHITECTURE.md` §9.4, when both `quality.write-unit-test` and `lang-typescript.write-vitest-test` are admitted, the workspace's pin (default: language-detect → if TS/JS, prefer `lang-typescript.write-vitest-test`) selects the provider.

## Non-functional contract

- **Idempotency:** yes on same diff + same model.
- **Latency budget:** p95 ≤ 60 s for ≤ 4 test cases.
- **Token budget:** ≤ 12K.
- **HITL:** none for authoring; only the platform CI gate determines whether tests must pass before merge.

## Failure modes

- PR has no TS/JS files → refuse and hand off to generic `quality.write-unit-test`.
- `it.skip(...)` without reason → refuse.
- Production-code edits → PEP blocks.
- Jest-style API used despite project being on vitest → refuse and re-write.

## Fixtures

Golden: `vitest-test-for-added-function`, `vitest-test-with-each`, `vitest-bug-reproduction`.
Adversarial: `vitest-skip-without-reason` (refused), `vitest-modifies-production-code` (PEP blocks).
