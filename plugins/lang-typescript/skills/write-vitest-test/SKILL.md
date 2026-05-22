---
name: lang-typescript.write-vitest-test
description: |
  **Use when:** a TypeScript/JavaScript PullRequest@v1 introduces or changes
  behavior that needs vitest-idiomatic unit tests — describe/beforeEach,
  it.each, vi.mock, vi.useFakeTimers, expect.assertions. Specializes
  `quality.write-unit-test` for TS/JS.

  **Do NOT use when:** the user wants generic unit tests (use
  `quality.write-unit-test` directly — it auto-detects the test runner and
  routes here when TS/JS is the language), integration tests
  (`quality.write-integration-test`), end-to-end browser tests
  (use playwright/cypress directly), or non-TS/JS tests.

  **Inputs:** PullRequest@v1 with changes under `*.ts`, `*.tsx`, `*.js`, or
  `*.jsx`.
  **Outputs:** TestSuite@v1 at `.agents/state/langs/lang-typescript/<pr-id>/`
  plus the actual test files under the project's test directory.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeVitestTest
bundle_contract_id: lang-typescript
visibility: public
---

# write-vitest-test

Author vitest-idiomatic unit tests for TypeScript/JavaScript behavior changes. Specializes `quality.write-unit-test` — competes via the competing-providers rule (SPEC.md) when the project is TS/JS.

## Procedure

1. **Verify the PR touches TS/JS.** If no `*.ts|*.tsx|*.js|*.jsx` files in the diff, refuse and hand off to the generic `quality.write-unit-test`.

2. **Confirm vitest is the runner.** Check `package.json` (`"test": "vitest"` or `"vitest"` in devDependencies), `vitest.config.ts`, or `vite.config.ts`. If the project is on Jest, refuse and surface a migration recommendation rather than producing a hybrid.

3. **Read the diff.** Identify the changed functions, modules, exports. Compose `methodology.read-code` inline if the touched code is unfamiliar.

4. **Locate the project's test layout.** Two common patterns:
   - **Colocated:** `src/foo.ts` → `src/foo.test.ts`
   - **Mirrored:** `src/foo.ts` → `tests/foo.test.ts` or `__tests__/foo.test.ts`

   Auto-detect by scanning existing tests; inherit the project's convention.

5. **Compose `methodology.tdd` inline.** Per the discipline, the failing test exists first. If `bugTriage` is the surrounding workflow, the test reproduces the bug before any fix lands.

6. **Author the tests using vitest idioms:**
   - **`describe` + `beforeEach`/`afterEach`** for grouped setup/teardown.
   - **`it.each([…])`** for cases that vary only by inputs — never a sequence of near-duplicate `it` blocks.
   - **`vi.mock("module")`** for module mocks; **`vi.spyOn(obj, "fn")`** for partial mocks; restore in `afterEach`.
   - **`vi.useFakeTimers()`** for time; **`vi.useRealTimers()`** in `afterEach`.
   - **`expect.assertions(n)`** when assertions are inside async/Promise callbacks to detect silent skips.
   - **`expect(…).toMatchInlineSnapshot()`** for object shapes that are stable and easy to read inline.
   - One test = one assertion goal — split when you need multiple unrelated assertions.
   - Test names: `it("returns X when Y", …)` — readable in the failure summary.

7. **Author the TestSuite envelope** at `.agents/state/langs/lang-typescript/<pr-id>/suite.json` with: `runner: "vitest"`, `cases[]`, `node_version`, `dependencies` (from `package.json`).

8. **Compose `methodology.verify` inline** before promoting.

9. **Announce.** "Wrote 4 vitest cases for PR-12 covering add(), the empty-input case, and TypeError on non-numeric args."

## Hard rules (TS/JS-specific)

- **No `it.skip(...)` without a reason.** Surface the unmet precondition; a bare skip is a refusal-to-decide.
- **No type-assertion as a substitute for behavior verification.** `expect(x as Foo)` does not test that `x` is actually a `Foo` at runtime; use a runtime guard.
- **No production-code edits.** PEP enforces. Quality NEVER writes production code.
- **No Jest globals in a vitest project** (`jest.fn()`, `jest.mock()`) — convert to `vi.*`.
- **No `any` in test mocks.** If you can't type the mock, the mock is wrong.

## Failure handling

- vitest not installed → `state: requires_human` with `npm i -D vitest` guidance.
- Coverage tooling absent → emit warning; conformance does not block on this in lang-typescript's MVP slice.

## Latency budget

p95 ≤ 60 s for ≤ 4 test cases against changed TS (in line with `quality.write-unit-test`'s budget).

## References

Vitest idiom guidance lives in `${CLAUDE_PLUGIN_ROOT}/skills/write-vitest-test/references/`. Add new files as the team's idiom set evolves.
