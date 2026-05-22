---
capability_interface_id: runPIA
version: 1
bundle_contract_id: privacy-compliance
schema_in: PRD@v1
schema_out: PrivacyImpactAssessment@v1
---

# runPIA@v1

Produces a Privacy Impact Assessment per GDPR Art. 35 (or applicable regulation) for any feature touching personal data.

## Inputs

- `PRD@v1` (required).
- Optional `SystemDesignDoc@v1` (for data-flow tracing).

## Outputs

- `PrivacyImpactAssessment@v1` at `.agents/state/findings/privacy/<id>/security/pia.json` using `platform/templates/pia.md`.

## Non-functional contract

- **Idempotency:** yes on same PRD + same regulation.
- **Latency budget:** p95 ≤ 90 s.
- **Token budget:** ≤ 20K.
- **HITL:** mandatory DPO sign-off for AI Act / GDPR high-risk processing per checkpoint 12 (Compliance attestation).

## Failure modes

- Data flow without lawful basis → refuse (defect; every flow needs an enumerated basis from the regulation).
- "We'll be careful with PII" as a mitigation → refuse (defect).
- High-risk processing without DPO escalation → refuse (legal violation).

## Fixtures

Golden: `pia-for-account-export` (lawful basis per flow).
Adversarial: `pia-without-lawful-basis` (refused).
