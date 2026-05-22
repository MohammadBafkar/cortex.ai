---
capability_interface_id: disclose
version: 1
bundle_contract_id: security
schema_in: SecurityFinding@v1
schema_out: Advisory@v1
---

# disclose@v1

Produces a coordinated-disclosure `Advisory@v1` for an exploited / disclosable `SecurityFinding@v1`. Cross-bundle handoff to `content.write-advisory` for the user-facing draft.

## Inputs

- `SecurityFinding@v1` (required) in state `verified` (fix landed + tested).

## Outputs

- `Advisory@v1` at `.agents/state/advisories/<finding-id>/security/advisory.json` with CVE id (if assigned), affected versions, impact, mitigation, credit.

## Non-functional contract

- **Idempotency:** yes per finding.
- **Latency budget:** p95 ≤ 60 s (mostly templating; content polish happens in `content.write-advisory`).
- **Token budget:** ≤ 10K.
- **HITL:** mandatory triple-approval per checkpoint 18 (Embargoed CVE disclosure) — Security + Legal + Comms.

## Failure modes

- Premature disclosure (before embargo lifts) → PEP blocks.
- Advisory without CVE id when one is assigned upstream → refuse.
- Missing credit when researcher requested it → refuse.

## Fixtures

Golden: `advisory-coordinated-disclosure`.
Adversarial: `advisory-before-embargo-lifts` (blocked).
