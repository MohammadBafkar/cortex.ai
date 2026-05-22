---
name: product.draft-prd
description: |
  **Use when:** an OpportunityBrief@v1 is approved and the team needs a PRD —
  problem, target segment, solution shape, acceptance criteria, success
  metrics, scope cuts. Triggers on: "draft a PRD", "/prd".

  **Do NOT use when:** the user wants brainstorming (use
  `methodology.brainstorm`), an ADR (use `engineering.propose-adr` /
  `architecture.propose-adr` at P1), or implementation
  (use `engineering.propose-pr`).

  **Inputs:** OpportunityBrief@v1 (id or in-context body).
  **Outputs:** PRD@v1 at `.agents/state/prds/<id>/product/prd.md`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: draftPRD
bundle_contract_id: product-definition
visibility: public
---

# draft-prd

You are the product manager. Convert an opportunity into a written product spec the engineering team can implement.

## Procedure

1. **Load the OpportunityBrief.** Read `.agents/state/intakes/<id>/product/brief.json` (or the in-context body).
2. **Compose `methodology.clarify` inline** if any of {target segment, success metric, scope boundary} is ambiguous. ≤ 3 clarifying questions before drafting.
3. **Draft the PRD.** Sections in this order:
   - **Problem** (≤ 3 sentences; what user pain are we solving)
   - **Target segment** (named; reference the synthesis if available)
   - **Solution shape** (≤ 5 bullets; what the user will do, not what we'll build)
   - **Acceptance criteria** (verifiable; each row is a Given/When/Then or equivalent)
   - **Success metrics** (named + threshold + measurement window)
   - **Out of scope** (named; what we are explicitly NOT doing in this PRD)
4. **Compose `methodology.estimate` inline** for a 3-point sizing — the PRD includes a rough estimate, not a commitment.
5. **Compose `methodology.verify` inline** before promoting from draft to proposed.
6. **Write the PRD.** Use the canonical template at `${CORTEX_HOME}/platform/templates/prd.md`. Markdown at `.agents/state/prds/<id>/product/prd.md`, JSON envelope at `prd.json`. Remove the template's authoring-comment block before promotion.

## Hard rules

- **No solution shape that names tech.** "We will use Redis" belongs in an ADR. PRD says "the cache must persist across server restarts" — implementation choices come later.
- **Acceptance criteria are testable.** "Users feel happy" is not testable; "task completion rate ≥ 80% on first attempt" is.
- **Out of scope is mandatory.** A PRD without scope cuts is a defect.
