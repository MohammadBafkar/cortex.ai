<!--
Template: RFC (Request for Comments) — broad-scope, cross-org decision document.
Use when a decision affects multiple teams, multiple plugins, or org-wide policy.
NOT a substitute for an ADR (single architectural decision) or PRD (product requirement).
Authored ad-hoc (no specific capability skill at MVP1 — author manually + circulate).
Remove this comment block before circulating.
-->

# RFC-<id>: <title>

- **Status:** draft <!-- draft | review | accepted | rejected | superseded -->
- **Date:** <YYYY-MM-DD>
- **Author:** <name + team>
- **Reviewers:** <named individuals — each must explicitly approve/reject>
- **Comment window:** <YYYY-MM-DD to YYYY-MM-DD — minimum 1 week for cross-team>
- **Related:** <ADR / PRD / RFC ids>

## Summary

<One paragraph for the executive read. What is being proposed, who is affected,
when does it take effect.>

## Motivation

<Why now? What forced this? Cite the data, incident, or strategic input that
made this RFC necessary. If the answer is "it's a good idea" — it's not ready.>

## Detailed Design

<The proposal. Walk through the change end-to-end:
- What changes for users
- What changes for engineers
- What changes for operators / on-call
- Migration path for anything that breaks>

## Alternatives Considered

<≥ 2 alternatives. The "do nothing" alternative is always one of them — name it
and explain why it's insufficient.>

### Alternative A: <name>

- **Why not:** <specific reason>

### Alternative B: do nothing

- **Why not:** <what breaks if we don't act>

## Risks

<Top risks per `methodology.risk-assess`. For each: scope of harm + mitigation.>

## Open Questions

<Block to promotion. Each question gets a decider.>

- ...

## Adoption Plan

- **Phase 1** (when): <what>
- **Phase 2** (when): <what>
- **Phase 3** (when): <what>
- **Deprecation timeline** (if applicable): <date> for old path; cleanup by <date>.

## References

- ADRs: <ids>
- PRDs: <ids>
- External: <RFC / vendor doc / spec>
