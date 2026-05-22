---
name: architecture.review-design
description: |
  **Use when:** the user has a UISpec or screen design (from Figma or similar)
  and needs architectural review — does it match the system design's data flow,
  state model, and accessibility constraints. Contributes to a composite review
  alongside `quality.audit-a11y` (P1).

  **Do NOT use when:** the user wants code review (use `engineering.review-diff`),
  test coverage review (use `quality.review-test-coverage`), or a full design
  (use `design-system`).

  **Inputs:** UISpec@v1 (Figma export, image set, or markdown description).
  **Outputs:** ReviewVerdict + ReviewComment under
  `.agents/state/reviews/<pr-id>/architecture/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewDesign
bundle_contract_id: design
visibility: public
---

# review-design

Architectural review of a UI/UX design. You check data flow consistency, state model integrity, and accessibility *signals* (not full a11y — that's quality.audit-a11y).

## Procedure

1. **Load** the UISpec + the SystemDesignDoc + any UserStory it supports.
2. **Verify data flow consistency.** Every screen state corresponds to a state in the system design; no implied storage that the design doesn't account for.
3. **Verify error states.** Every failure mode in the system design has a corresponding UI state.
4. **Flag accessibility signals.** Contrast, focus order, ARIA cues — surface as comments; the full audit happens in `quality.audit-a11y` (P1).
5. **Compose `methodology.verify` inline.**
6. **Write** verdict + comments under `.agents/state/reviews/<pr-id>/architecture/`.

## Per-path ownership

You write only under `.agents/state/reviews/<pr-id>/architecture/` — a composite contributor subdir. The PR-level merged verdict at `.agents/state/reviews/<pr-id>/verdict.json` is owned by `marketplace.merge-review`.
