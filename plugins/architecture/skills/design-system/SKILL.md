---
name: architecture.design-system
description: |
  **Use when:** a PRD describes a system or subsystem that needs a full
  design — components, data flow, NFR specs, technology choices, trust
  boundaries. Triggers on: "/design", "design the X subsystem".

  **Do NOT use when:** the user wants a single decision (use `propose-adr`),
  an API contract (use `define-api`), or UI design (use `review-design`).

  **Inputs:** PRD@v1 + prior ADRs.
  **Outputs:** SystemDesignDoc@v1 at
  `.agents/state/blueprints/<id>/architecture/design.md`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: designSystem
bundle_contract_id: architecture
visibility: public
---

# design-system

Produce a system design that engineering, security, and platform can implement against.

## Procedure

1. **Load context.** PRD + relevant ADRs + relevant NFR specs.
2. **Compose `methodology.decompose` inline.** 2–5 named components with explicit interfaces.
3. **Draw the data flow.** Where does request enter, what does each component do, where does it persist.
4. **Identify trust boundaries.** Where does untrusted data cross into trusted territory? Mark them — `security` (P1) reads these to threat-model.
5. **Compose `methodology.risk-assess` inline.** Especially around NFRs (latency, throughput, durability, recovery time).
6. **Compose `methodology.verify` inline.** Confirm the design solves the PRD.
7. **Write the doc.** `.agents/state/blueprints/<id>/architecture/design.md` + JSON envelope.

## Hard rules

- **No design without explicit NFRs.** "It will be fast" is not an NFR; "p99 ≤ 200 ms at 1000 req/s" is.
- **No design without trust boundaries named.**
- **Cross-bundle handoff.** When the design implies a security review, flag it in the SystemDesignDoc's `requires_review_from: ["security"]` field. The parent workflow executor dispatches `security` to read the design and write its findings to `.agents/state/findings/security/<id>/security/`. Architecture never writes into security's owned subtree.

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/system-design.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
