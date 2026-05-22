---
capability_interface_id: writeXunitTest
version: 1
bundle_contract_id: lang-dotnet
schema_in: PullRequest@v1
schema_out: TestSuite@v1
---

# writeXunitTest@v1

Specializes `quality.writeUnitTest@v1` for C#/.NET projects. Authors xUnit-idiomatic unit tests (Fact/Theory, Moq/NSubstitute, IClassFixture, FluentAssertions).

## Inputs

- `PullRequest@v1` with changes under `*.cs` files.

## Outputs

- `TestSuite@v1` (type=unit, runner=xunit) at `.agents/state/langs/lang-dotnet/<pr-id>/suite.json` + the test files under the matching `*.Tests` project (project convention).

## Competing-providers rule

Per `ARCHITECTURE.md` §9.4, when both `quality.write-unit-test` and `lang-dotnet.write-xunit-test` are admitted, the workspace's pin (default: language-detect → if .NET, prefer `lang-dotnet.write-xunit-test`) selects the provider. Workspaces that pin MSTest or NUnit override this.

## Non-functional contract

- **Idempotency:** yes on same diff + same model.
- **Latency budget:** p95 ≤ 60 s for ≤ 4 test cases (matches `quality`'s budget).
- **Token budget:** ≤ 12K.
- **HITL:** none for authoring; only the platform CI gate determines whether tests must pass before merge.

## Failure modes

- PR has no `*.cs` files → refuse and hand off to generic `quality.write-unit-test`.
- `[Fact(Skip = "…")]` without a real reason → refuse.
- Production-code edits → PEP blocks.
- MSTest/NUnit attributes used in an xUnit project → refuse and rewrite using xUnit idioms.

## Fixtures

Golden: `xunit-test-for-added-method`, `xunit-test-with-theory`, `xunit-bug-reproduction`.
Adversarial: `xunit-skip-without-reason` (refused), `xunit-modifies-production-code` (PEP blocks).
