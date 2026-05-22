---
name: quality.write-integration-test
description: |
  **Use when:** a PullRequest@v1 introduces behavior that crosses module
  boundaries (database + cache, service + queue, etc.) and needs an
  integration test that exercises the real interaction.

  **Do NOT use when:** the user wants a unit test (use `write-unit-test`),
  contract test (use `write-contract-test`), performance test (use `benchmark`),
  or to modify production code (use `engineering.propose-pr` — quality NEVER
  writes production code).

  **Inputs:** PullRequest@v1 + optional SystemDesignDoc@v1 for module-boundary
  information.
  **Outputs:** TestSuite@v1 (type=integration) at
  `.agents/state/tests/<pr-id>/quality/integration-suite.json` + the test files.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeIntegrationTest
bundle_contract_id: test-authoring
visibility: public
---

# write-integration-test

Author integration tests that exercise the real interaction across module boundaries — real database, real cache, real queue. No mocks of the layer under test.

## Procedure

1. **Load** PR + (optional) SystemDesignDoc to identify the boundaries.
2. **Identify the smallest scope** that exercises the new behavior end-to-end. Avoid full E2E (that's a separate slice in P2); aim for "the new path through 2–3 components".
3. **Compose `methodology.tdd` inline** — the integration test must initially fail against the un-merged code, then pass after the PR is applied.
4. **Compose `methodology.risk-assess` inline.** Highlight test-environment risks (shared DB, port collisions, leaky state).
5. **Author the suite + files.** Test files under `tests/integration/` (or project convention). Envelope at `.agents/state/tests/<pr-id>/quality/integration-suite.json`.
6. **Compose `methodology.verify` inline** before promoting the envelope.

## Hard rules

- **No mocks of the layer under test.** A mock would defeat the point of an integration test. Mocks are allowed at the *outer* boundary (external SaaS, mail provider, etc.).
- **No production-code edits.**
- **State isolation.** Each test must leave the shared environment in the same state it started.

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/test-plan.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
