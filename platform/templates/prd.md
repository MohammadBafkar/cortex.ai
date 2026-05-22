<!--
Template: PRD (Product Requirements Document).
Authored by: product.draft-prd.
Required sections: Problem, Target segment, Solution shape, Acceptance criteria,
Success metrics, Out of scope.
Forbidden in solution shape: naming specific tech (that's an ADR).
Forbidden in acceptance criteria: unmeasurable statements like "users feel happy".
Remove this comment block before promoting to `proposed`.
-->

# PRD: <feature name>

- **Status:** draft <!-- draft | proposed | approved | superseded -->
- **Date:** <YYYY-MM-DD>
- **PM:** <name>
- **Tech lead:** <name>
- **OpportunityBrief:** <link or id>
- **Estimated size:** <S | M | L> — confidence: <low | medium | high>

## Problem

<≤ 3 sentences. What user pain are we solving? Who feels it? Why now? Cite the
synthesis or signal that surfaced this problem.>

## Target Segment

<Named segment(s) from `product.synthesize-interviews`. Reference the
InterviewSynthesis. If a segment isn't named in research, it doesn't exist —
add a discovery step before this PRD.>

## Solution Shape

<≤ 5 bullets describing **what the user will do**, not what we'll build.
Examples:
- "Users export their account data to a CSV from the Settings page."
- "Users see a one-time prompt confirming the export and an email when ready."
Do NOT name specific tech here — that's an ADR.>

## Acceptance Criteria

<Each row is a verifiable claim. Given/When/Then format preferred.>

1. **Given** ..., **when** ..., **then** ...
2. **Given** ..., **when** ..., **then** ...

## Success Metrics

| Metric | Threshold | Window | Measurement |
| --- | --- | --- | --- |
| <name> | <e.g., ≥ 80%> | <e.g., 7d post-launch> | <how measured> |

## Risks

<Top 3-5 risks (cite `methodology.risk-assess`). For each: likelihood × impact + mitigation.>

## Out of Scope

<Explicit list of what we are NOT doing in this PRD. Mandatory section — a PRD
without scope cuts is a defect.>

- ...
- ...

## Open Questions

<Anything blocking promotion to `approved`. Each question names its decider.>

- ...

## References

- OpportunityBrief: <link>
- Related ADRs: <list>
- Prior PRDs (if iterating): <list>
