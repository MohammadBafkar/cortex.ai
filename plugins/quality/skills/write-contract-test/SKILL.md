---
name: quality.write-contract-test
description: |
  **Use when:** an APIContract@v1 (from `architecture.define-api`) needs
  consumer-driven contract tests that confirm both ends honor the contract.

  **Do NOT use when:** the user wants a unit test (`write-unit-test`), end-to-end
  test (P2 fill), or contract authoring (use `architecture.define-api`).

  **Inputs:** APIContract@v1.
  **Outputs:** TestSuite@v1 (type=contract) at
  `.agents/state/tests/<api-id>/quality/contract-suite.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeContractTest
bundle_contract_id: test-authoring
visibility: public
---

# write-contract-test

Author consumer-driven contract tests for both producer and consumer sides of an API.

## Procedure

1. **Load the APIContract.**
2. **Per endpoint, author both sides:** producer test (the API actually returns what the contract says); consumer test (the consumer correctly handles every documented response shape, including error codes).
3. **Per breaking change** flagged in the contract's version diff, author a regression test that fails if the prior version's consumer would break.
4. **Compose `methodology.verify` inline** before promotion.

## Hard rules

- **No contract test against a mock-only producer.** Either run the producer (preferred) or use a recorded fixture from a real run.
- **Schema-driven.** Generate test scaffolding from the OpenAPI/proto/SDL where possible.
