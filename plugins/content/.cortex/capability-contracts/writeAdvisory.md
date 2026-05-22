---
capability_interface_id: writeAdvisory
version: 1
bundle_contract_id: stakeholder-comms
schema_in: SecurityFinding@v1
schema_out: Advisory@v1
---

# writeAdvisory@v1

User-facing security advisory drafted from a `SecurityFinding@v1`. Coordinated disclosure timeline.

## Inputs

- `SecurityFinding@v1` (required) in state `verified` (fix has landed + been verified).
- Embargo timeline (if coordinated disclosure with external reporter).

## Outputs

- `Advisory@v1` at `.agents/state/comms/advisory-<id>/content/advisory.md`.

## Non-functional contract

- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 8K.
- **HITL:** triple-approval (Security + Legal + Comms) per checkpoint 18 (Embargoed CVE disclosure).

## Failure modes

- Premature publication (before embargo lifts) → PEP blocks.
- Missing credit when researcher opted in → refuse.
- Speculation about exploitation → refuse (cite evidence only).

## Fixtures

Golden: `advisory-coordinated-disclosure`.
Adversarial: `advisory-before-embargo-lifts` (PEP blocks).
