---
capability_interface_id: defineAPI
version: 1
bundle_contract_id: api-lifecycle
schema_in: SystemDesignDoc@v1
schema_out: APIContract@v1
---

# defineAPI@v1

Authors a versioned `APIContract@v1` (REST / gRPC / GraphQL — one protocol per contract).

## Inputs

- `SystemDesignDoc@v1` (required) — the design names the APIs to spec.
- Optional `APIContract@v1[]` — predecessor versions for breaking-change diff.

## Outputs

- `APIContract@v1` JSON envelope at `.agents/state/apis/<api-id>/architecture/contract.json`.
- The protocol file alongside: `openapi.yaml` (REST) using `platform/templates/api-contract-openapi.yaml`, or `service.proto` (gRPC), or `schema.graphql`.

## Non-functional contract

- **Idempotency:** yes on same design.
- **Latency budget:** p95 ≤ 60 s per contract.
- **Token budget:** ≤ 20K.
- **HITL:** breaking change → mandatory deprecation plan + 90-day notice (per `update_strategy` defaults).

## Failure modes

- Undocumented field → refuse.
- Breaking change without deprecation plan → refuse.
- Mixing protocols in one contract → refuse (one protocol per APIContract).

## Fixtures

Golden: `define-rest-api`.
Adversarial: `api-without-deprecation-plan` (refused).
