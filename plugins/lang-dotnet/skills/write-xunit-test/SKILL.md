---
name: lang-dotnet.write-xunit-test
description: |
  **Use when:** a C#/.NET PullRequest@v1 introduces or changes behavior that
  needs xUnit-idiomatic unit tests — Fact/Theory + InlineData, IClassFixture
  for shared setup, Moq or NSubstitute for mocks, FluentAssertions for
  expressive checks. Specializes `quality.write-unit-test` for .NET.

  **Do NOT use when:** the user wants generic unit tests (use
  `quality.write-unit-test` — it auto-detects the test runner and routes
  here when .NET is the language), integration tests
  (`quality.write-integration-test`), or non-.NET tests. Also skip if the
  workspace pins MSTest or NUnit (this skill targets xUnit only; another
  language-skillset can ship MSTest later).

  **Inputs:** PullRequest@v1 with changes under `*.cs` files.
  **Outputs:** TestSuite@v1 at `.agents/state/langs/lang-dotnet/<pr-id>/`
  plus the actual test files under the matching `<Project>.Tests/` project.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeXunitTest
bundle_contract_id: lang-dotnet
visibility: public
---

# write-xunit-test

Author xUnit-idiomatic unit tests for C#/.NET behavior changes. Specializes `quality.write-unit-test` — competes via the competing-providers rule (SPEC.md) when the project is .NET.

## Procedure

1. **Verify the PR touches `.cs` files.** If not, refuse and hand off to the generic `quality.write-unit-test`.

2. **Confirm xUnit is the test framework.** Inspect the matching `*.Tests.csproj` for `<PackageReference Include="xunit" … />`. If the project uses MSTest (`Microsoft.VisualStudio.TestTools.UnitTesting`) or NUnit (`NUnit`), refuse and surface that — don't produce a hybrid.

3. **Read the diff.** Identify the changed types, methods, and behavior. Compose `methodology.read-code` inline if the touched code is unfamiliar.

4. **Locate the matching test project.** Convention:
   - `src/MyLib/MyLib.csproj` → `tests/MyLib.Tests/MyLib.Tests.csproj`
   - Or, single-folder projects: `MyLib/MyLib.csproj` + `MyLib.Tests/MyLib.Tests.csproj`

   If the matching test project doesn't exist, refuse (creating a test project is a separate change that needs an engineer's call).

5. **Compose `methodology.tdd` inline.** Per the discipline, the failing test exists first. If `bugTriage` is the surrounding workflow, the test reproduces the bug before any fix lands.

6. **Author the tests using xUnit idioms:**
   - **`[Fact]`** for one-shot cases; **`[Theory] + [InlineData(…)]`** for cases that vary only by inputs — never a sequence of near-duplicate `[Fact]` methods.
   - **`IClassFixture<T>`** for shared per-class setup; **`ICollectionFixture<T>`** for cross-class shared state (rare).
   - **`Moq.Mock<T>`** or **`NSubstitute`** for mocks; follow the project's choice. Mixed-style is a refusal.
   - **`FluentAssertions`** when the project already uses it (preferable; reads as "x should be y").
   - **`Assert.ThrowsAsync<T>`** for async exception paths — NOT `[Fact]` with a try/catch.
   - One test = one assertion goal — split when you need multiple unrelated assertions.
   - Test names: `MethodUnderTest_Scenario_ExpectedBehavior` (e.g., `Add_NegativeOperands_ReturnsNegativeSum`).

7. **Author the TestSuite envelope** at `.agents/state/langs/lang-dotnet/<pr-id>/suite.json` with: `runner: "xunit"`, `cases[]`, `target_framework`, `dependencies` (from the test csproj).

8. **Compose `methodology.verify` inline** before promoting.

9. **Announce.** "Wrote 4 xUnit cases for PR-12 covering Add(), the overflow case, and ArgumentNullException on null operands."

## Hard rules (.NET-specific)

- **No `[Fact(Skip = "...")]` without a real reason.** Surface the unmet precondition; a bare skip is a refusal-to-decide.
- **No `[Theory]` without `[InlineData]` / `[MemberData]`** — a Theory with no data attribute is meaningless.
- **No `Thread.Sleep` in tests.** Use `Task.Delay` with cancellation, or restructure to test the contract not the timing.
- **No production-code edits.** PEP enforces. Quality NEVER writes production code.
- **No mixing Moq and NSubstitute** in the same project.

## Failure handling

- xUnit not installed → `state: requires_human` with `dotnet add package xunit xunit.runner.visualstudio` guidance.
- Coverage tooling absent (`coverlet.collector`) → emit warning; conformance does not block on this in lang-dotnet's MVP slice.
- `*.cs` files unparseable → refuse and surface the parse error.

## Latency budget

p95 ≤ 60 s for ≤ 4 test cases against changed C#.

## References

xUnit idiom guidance lives in `${CLAUDE_PLUGIN_ROOT}/skills/write-xunit-test/references/`.
