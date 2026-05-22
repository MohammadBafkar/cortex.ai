---
name: engineering.propose-adr
description: |
  **Use when:** the user asks to write an Architecture Decision Record, capture a
  trade-off, or document why a particular technical approach was chosen.
  Triggers on: "write an ADR", "document this decision", "capture the trade-off".

  **Do NOT use when:** the user wants to brainstorm options (use
  `methodology.brainstorm` — ideation precedes ADR authoring), implement code
  (use `engineering.propose-pr`), or write a full architecture design (use
  `architecture.design-system` when the `architecture` plugin admits at P1 —
  this skill is the **minimal architecture** slice in `engineering` and will
  be deprecated when `architecture` ships).

  **Inputs:** PRD@v1 or a clearly stated decision context, optional prior ADRs.
  **Outputs:** ADR@v1 written to `.agents/state/adrs/<adr-id>/engineering/adr.md`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: proposeADR
bundle_contract_id: architecture-lite
visibility: public
---

# propose-adr

You are the architecture-lite author. Produce a Nygard-style ADR that captures the decision, the forces driving it, and the consequences.

## Procedure

1. **Read context.** Read the `PRD@v1` (or the in-context decision request) and any referenced prior ADRs at `.agents/state/adrs/`.

2. **Read the anti-patterns reference.** `${CLAUDE_PLUGIN_ROOT}/skills/propose-adr/references/adr-anti-patterns.md` lists the 8 most common ADR defects. Refuse to emit an ADR that exhibits any of them.

3. **Verify.** Invoke `methodology.verify` inline to confirm the decision actually addresses the PRD. (At P1, `methodology.decompose` and `methodology.risk-assess` are also composed here.)

4. **Write the ADR.** Author at `.agents/state/adrs/<adr-id>/engineering/adr.md` using the canonical template at `${CORTEX_HOME}/platform/templates/adr.md`. Required sections: Title, Status (`proposed` initially), Context, Options Considered, Decision, Consequences, References. Remove the template's authoring-comment block before promotion.

5. **Cross-reference.** If this ADR supersedes a prior one, list the prior ADR id in `References` and mark the prior ADR's status as `superseded` in the new ADR's `Consequences` section. **Do not edit the prior ADR file directly** — the orchestrator handles status transitions through the workflow template.

6. **Announce.** "Drafted ADR-007 'Caching strategy for hot reads' at .agents/state/adrs/ADR-007/engineering/adr.md (status: proposed)."

## Promotion path

- `proposed` → `accepted` requires HITL per `GOVERNANCE.md` §5.2 checkpoint 19 (Architectural exception, C-tier in MVP1).
- `accepted` → `superseded` is set by a later ADR that supersedes this one.
- `accepted` → `deprecated` requires HITL.

## Deprecation when `architecture` plugin admits

When `architecture v1.0` admits at P1, `engineering.propose-adr` enters a 90-day deprecation window. New ADRs are authored by `architecture.propose-adr`; existing ADRs in `.agents/state/adrs/<id>/engineering/` remain readable but write authority transfers. The migration is workflow-template-driven (HITL per checkpoint 10).

## Failure handling

- If the decision is genuinely contested (≥ 2 viable options without consensus), set `Status: proposed (contested)` and flag for HITL. Do not pick a winner from a coin toss.
- If `methodology.verify` fails, return to step 1 — read context again. Bounded ≤ 3 inner iterations.
