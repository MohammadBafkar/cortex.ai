---
capability_interface_id: writeSunsetNotice
version: 1
bundle_contract_id: sunset
schema_in: DeprecationProposal@v1
schema_out: SunsetNotice@v1
---

# writeSunsetNotice@v1

Customer-facing sunset notice for an approved `DeprecationProposal@v1`. Mandatory 90-day notice for actively-used capabilities.

## Inputs

- `DeprecationProposal@v1` (required) — state `approved`.
- Optional migration path documentation.

## Outputs

- `SunsetNotice@v1` at `.agents/state/deprecations/<capability-id>/content/notice.md`.

## Non-functional contract

- **Cooldown:** 90-day minimum notice for actively-used capabilities (enforced).
- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 10K.
- **HITL:** mandatory per checkpoint 20 (Sunsetting an actively used capability) — product-owner + EM + comms-lead.

## Failure modes

- Sunset without migration path → refuse (defect; even "switch to vendor X" counts but absence is unacceptable).
- < 90-day notice for an active capability → refuse.
- Publication without triple HITL → PEP blocks.

## Fixtures

Golden: `sunset-notice-90d`.
Adversarial: `sunset-notice-without-migration-path` (refused).
