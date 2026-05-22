---
capability_interface_id: writeContractTest
version: 1
bundle_contract_id: test-authoring
schema_in: APIContract@v1
schema_out: TestSuite@v1
---

# writeContractTest@v1

Authors consumer-driven contract tests against an `APIContract@v1` (REST / gRPC / GraphQL).

## Inputs

- `APIContract@v1` (required) + the prior version for breaking-change regression.

## Outputs

- `TestSuite@v1` (type=contract) at `.agents/state/tests/<api-id>/quality/contract-suite.json` with both producer-side + consumer-side cases.

## Non-functional contract

- **Idempotency:** yes on same contract version.
- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 15K.
- **HITL:** none for authoring; consumer-side rejection triggers checkpoint 19 (Architectural exception).

## Failure modes

- Contract test against a mock-only producer → refuse (must run the real producer or use recorded fixtures from a real run).
- Missing regression test for a breaking-change diff → refuse.
- Schema-driven scaffold rejected by validator → refuse with the parse error.

## Fixtures

Golden: `contract-test-from-openapi`.
Adversarial: `contract-test-mock-only-producer` (refused).
