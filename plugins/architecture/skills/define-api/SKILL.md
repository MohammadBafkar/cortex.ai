---
name: architecture.define-api
description: |
  **Use when:** a SystemDesignDoc names external or internal APIs that need
  versioned contracts (OpenAPI, gRPC proto, GraphQL schema). Triggers on:
  "/api", "define the contract for X".

  **Do NOT use when:** the user wants implementation (use
  `engineering.propose-pr`) or runtime API reference docs
  (those are derived by `content.api-reference` at P1).

  **Inputs:** SystemDesignDoc@v1.
  **Outputs:** APIContract@v1 at
  `.agents/state/apis/<api-id>/architecture/manifest.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: defineAPI
bundle_contract_id: api-lifecycle
visibility: public
---

# define-api

Author a versioned, machine-readable API contract.

## Procedure

1. **Load** the SystemDesignDoc and any predecessor APIContracts (for backward-compat checks).
2. **Choose the protocol.** REST / gRPC / GraphQL — one per APIContract; multi-protocol is two contracts.
3. **Define resources / methods / messages.** Every field has a type and a description; every error has a code and a sample.
4. **Versioning.** `v1` initial. Breaking changes require a new major + a deprecation plan for the prior; `content.deprecation-notice` at P1 produces the user comms.
5. **Compose `methodology.verify` inline** to confirm the contract matches the design.
6. **Write.** `.agents/state/apis/<api-id>/architecture/manifest.json` + the actual OpenAPI/proto/SDL file alongside.

## Hard rules

- **No undocumented field.**
- **No breaking change without deprecation plan.** P1 enforces via the content plugin.
- **Idempotent on the same SystemDesignDoc.**

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/api-contract-openapi.yaml`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
