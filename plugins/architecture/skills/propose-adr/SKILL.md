---
name: architecture.propose-adr
description: |
  **Use when:** a PRD or system change needs a recorded architectural decision
  with full risk/trade-off analysis. This is the full-scope version that
  supersedes engineering's MVP1 minimal ADR slice.

  **Do NOT use when:** the user wants a small implementation choice
  (engineering.propose-adr deprecation grace period), ideation
  (`methodology.brainstorm`), or full system design (use `design-system`).

  **Inputs:** PRD@v1 or in-context decision request.
  **Outputs:** ADR@v1 at `.agents/state/adrs/<id>/architecture/adr.md`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: proposeADR
bundle_contract_id: architecture
visibility: public
---

# propose-adr (full-scope)

Author a Nygard-style ADR with explicit decomposition, options, and risk assessment.

## Procedure

1. **Read context.** PRD + prior ADRs.
2. **Compose `methodology.decompose` inline** when the decision actually has sub-parts (a single yes/no doesn't need decomposition).
3. **Generate ≥ 2 options** with explicit trade-offs. The "chosen" option is the one that survives both decompose and risk-assess.
4. **Compose `methodology.risk-assess` inline.** Every medium/high risk gets a mitigation.
5. **Compose `methodology.verify` inline** before promoting to `proposed`.
6. **Write the ADR.** Use the canonical template at `${CORTEX_HOME}/platform/templates/adr.md`. Sections: Title, Status, Context, Decomposition (optional), Options Considered, Decision, Consequences, Risks + Mitigations, References. Remove the template's authoring-comment block before promotion.
7. **Engineering's older ADRs.** Cross-link with the engineering plugin's existing ADRs under `.agents/state/adrs/<id>/engineering/` — they remain readable but new ADRs are owned by architecture.

## Hard rules

- **No ADR without options + trade-offs.** A single-option ADR is a defect.
- **No risk without a mitigation** for medium/high.
- **Idempotent on the same decision context.**
