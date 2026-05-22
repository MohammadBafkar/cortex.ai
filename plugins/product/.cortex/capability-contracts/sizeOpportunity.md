---
capability_interface_id: sizeOpportunity
version: 1
bundle_contract_id: discovery
schema_in: InterviewSynthesis@v1
schema_out: OpportunityBrief@v1
---

# sizeOpportunity@v1

Turns an `InterviewSynthesis@v1` into a sized `OpportunityBrief@v1` — problem, evidence, affected segment, sizing range, confidence band.

## Inputs

- `InterviewSynthesis@v1` (required) with `confidence: medium` or higher. Low-confidence synthesis is refused — narrow the discovery scope first.

## Outputs

- `OpportunityBrief@v1` at `.agents/state/intakes/<id>/product/brief.json` with: `problem`, `evidence[]` (≥ 3 sources cited), `affected_segment`, `sizing_low | expected | high` (3-point), `confidence`.

## Non-functional contract

- **Idempotency:** yes on the same InterviewSynthesis.
- **Latency budget:** p95 ≤ 30 s.
- **Token budget:** ≤ 15K.
- **HITL:** sign-off by product-research-lead before promoting `proposed` → `approved` (per GOVERNANCE.md).

## Failure modes

- Evidence count < 3 → refuse with explicit "insufficient evidence" message.
- Single-point sizing (no confidence band) → refuse — that's a defect per `methodology.estimate`.

## Fixtures

Golden: `opportunity-brief-from-synthesis` (3-point estimate present).
Adversarial: `single-source-evidence-rejected`, `single-point-estimate-rejected`.
