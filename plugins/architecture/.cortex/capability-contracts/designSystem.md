---
capability_interface_id: designSystem
version: 1
bundle_contract_id: architecture
schema_in: PRD@v1
schema_out: SystemDesignDoc@v1
---

# designSystem@v1

Produces a `SystemDesignDoc@v1` from an approved `PRD@v1`. Engineering, security, platform read it; they don't co-author it.

## Inputs

- `PRD@v1` (required) in state `approved`.
- Optional prior ADRs + NFR specs.

## Outputs

- `SystemDesignDoc@v1` at `.agents/state/blueprints/<id>/architecture/design.md` using `platform/templates/system-design.md`. JSON envelope alongside.

## Non-functional contract

- **Idempotency:** yes on same PRD + same model.
- **Latency budget:** p95 ≤ 120 s.
- **Token budget:** ≤ 30K (Opus default).
- **HITL:** none at design level; downstream security threat-model triggers checkpoint 6 (Connector Plugin) only when new vendors are introduced.

## Failure modes

- No NFRs named → refuse with "every system design needs measurable NFRs" message.
- No trust boundaries called out → refuse (security can't threat-model without them).
- Single-component design (no decomposition) → refuse; the design is too small to warrant a SystemDesignDoc.

## Fixtures

Golden: `design-checkout-subsystem` (≥ 3 components, NFRs, trust boundaries).
Adversarial: `design-without-nfrs` (refused).
