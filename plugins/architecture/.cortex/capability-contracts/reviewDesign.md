---
capability_interface_id: reviewDesign
version: 1
bundle_contract_id: design
schema_in: UISpec@v1
schema_out: [ReviewVerdict@v1, ReviewComment@v1[]]
---

# reviewDesign@v1

Architectural review of a `UISpec@v1` — data-flow consistency, state-model integrity, accessibility signals. Contributes to a composite review alongside `quality.audit-a11y`.

## Inputs

- `UISpec@v1` (Figma export, image set, or markdown description).
- Optional `SystemDesignDoc@v1` + `UserStory@v1` for cross-check.

## Outputs

- `ReviewVerdict@v1` + `ReviewComment@v1[]` at `.agents/state/reviews/<pr-id>/architecture/`.

## Per-path ownership

Composite contributor subdir under `reviews/` (per `state-ownership.json` composite list). The PR-level merged `verdict.json` is owned by `marketplace.merge-review`, NOT by any contributor.

## Non-functional contract

- **Idempotency:** yes on same UISpec.
- **Latency budget:** p95 ≤ 45 s per design.
- **Token budget:** ≤ 12K.
- **HITL:** none for advisory; required only when the merged composite verdict is `request_changes` on PR-blocking issues.

## Failure modes

- Cross-bundle write into `quality/` or `engineering/` subdir → PEP blocks.
- Self-review (reviewer == designer) → blocked by SoD.

## Fixtures

Golden: `review-mobile-checkout-design`.
Adversarial: `review-edits-design-file` (PEP blocks edit attempt).
