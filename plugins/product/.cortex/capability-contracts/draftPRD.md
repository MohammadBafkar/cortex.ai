---
capability_interface_id: draftPRD
version: 1
bundle_contract_id: product-definition
schema_in: OpportunityBrief@v1
schema_out: PRD@v1
---

# draftPRD@v1

Authors a `PRD@v1` from an approved `OpportunityBrief@v1`. See `product.draft-prd` SKILL.md for the procedure; this file establishes the contract envelope.

## Inputs

- `OpportunityBrief@v1` (required) in state `approved`. `proposed` briefs are refused — promote the brief first.

## Outputs

- `PRD@v1` at `.agents/state/prds/<id>/product/prd.md` + JSON envelope at `prd.json`. Template at `platform/templates/prd.md`. Required sections: Problem, Target Segment, Solution Shape, Acceptance Criteria, Success Metrics, Out of Scope.

## Non-functional contract

- **Idempotency:** yes on same brief + same model.
- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 20K.
- **HITL:** tech lead + PM approval per `GOVERNANCE.md` §1 task #2 before promotion `proposed` → `approved`.

## Failure modes

- Solution-shape names specific tech → refuse (that's an ADR concern; per the hard rule in the SKILL.md).
- Acceptance criteria unmeasurable → refuse with explicit "rewrite as Given/When/Then" message.
- Missing Out of Scope section → refuse (defect).

## Fixtures

Golden: `draft-prd-from-brief` (all required sections present).
Adversarial: `prd-without-acceptance-criteria`, `prd-names-tech-in-solution-shape`.
