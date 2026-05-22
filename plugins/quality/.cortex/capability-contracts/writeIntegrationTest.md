---
capability_interface_id: writeIntegrationTest
version: 1
bundle_contract_id: test-authoring
schema_in: PullRequest@v1
schema_out: TestSuite@v1
---

# writeIntegrationTest@v1

Authors integration tests that exercise real interaction across module boundaries (real DB, real cache, real queue — no mocks of the layer under test).

## Inputs

- `PullRequest@v1` with changes crossing module boundaries.
- Optional `SystemDesignDoc@v1` for boundary identification.

## Outputs

- `TestSuite@v1` (type=integration) at `.agents/state/tests/<pr-id>/quality/integration-suite.json` + the test files.

## Non-functional contract

- **Idempotency:** yes on same diff.
- **Latency budget:** authoring p95 ≤ 120 s; integration test runs themselves are unbounded.
- **Token budget:** ≤ 18K.
- **HITL:** test that touches a prod-mirror env → checkpoint 13 (Chaos experiment).

## Failure modes

- Mocks of the layer under test → refuse (defeats the purpose).
- State leakage between cases → emit warning; conformance flags as defect.
- Production-code edits → PEP blocks.

## Fixtures

Golden: `integration-test-cross-module`.
Adversarial: `integration-test-mocks-the-layer-under-test` (refused).
