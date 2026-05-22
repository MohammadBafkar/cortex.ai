---
capability_interface_id: reviewEthics
version: 1
bundle_contract_id: governance
schema_in: PRD@v1
schema_out: EthicsReview@v1
---

# reviewEthics@v1

Ethics review aligned with EU AI Act risk classification + NIST AI RMF. Triggered for features with potential ethical impact (bias-sensitive ML, dark-pattern UX, surveillance, AI Act high-risk).

## Inputs

- `PRD@v1` (required).
- Optional `ThreatModel@v1` + `PIA@v1` for context.

## Outputs

- `EthicsReview@v1` at `.agents/state/ethics/<feature-id>/marketplace/review.json` with EU AI Act risk class + mitigations + monitoring plan.

## Non-functional contract

- **Idempotency:** yes per (PRD + version of governance policy).
- **Latency budget:** p95 ≤ 120 s.
- **Token budget:** ≤ 25K (Opus default for ethical reasoning).
- **HITL:** mandatory on EU AI Act high-risk classifications. Triggers checkpoint 11 (AI/ML model promotion) for models.

## Failure modes

- "Ethics by hope" — vague mitigations like "we'll be careful" → refuse.
- High-risk feature without monitoring plan → refuse.
- Prohibited use case under EU AI Act → block; no mitigation path.

## Fixtures

Golden: `ethics-review-high-risk`.
Adversarial: `ethics-review-vague-mitigations` (refused).
