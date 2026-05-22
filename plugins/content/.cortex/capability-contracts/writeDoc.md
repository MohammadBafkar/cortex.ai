---
capability_interface_id: writeDoc
version: 1
bundle_contract_id: documentation
schema_in: APIContract@v1
schema_out: DocPage@v1
---

# writeDoc@v1

Authors a `DocPage@v1` (Diátaxis-typed) from an `APIContract@v1`, `PRD@v1`, or in-context topic.

## Inputs

- `APIContract@v1` OR `PRD@v1` OR in-context topic.
- Optional reading material via `methodology.research` composition.

## Outputs

- `DocPage@v1` at `.agents/state/docs/<id>/content/page.md`. JSON envelope alongside.

## Non-functional contract

- **Idempotency:** yes on same input + same model.
- **Latency budget:** p95 ≤ 90 s per page.
- **Token budget:** ≤ 18K.
- **HITL:** publication to public channels routes through checkpoint 5 (Customer comms mass) or checkpoint 4 (External public statement) depending on audience.

## Failure modes

- Diátaxis label missing → refuse (defect).
- Code example untested → emit with `untested: true` flag; conformance flags if untested examples > 0.
- Marketing prose → refuse (doc pages explain, they don't pitch).

## Fixtures

Golden: `doc-from-api-contract`.
Adversarial: `doc-with-marketing-prose` (refused).
