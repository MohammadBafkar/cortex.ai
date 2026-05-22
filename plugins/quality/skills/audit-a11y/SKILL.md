---
name: quality.audit-a11y
description: |
  **Use when:** a UISpec@v1 or actual UI implementation needs a full
  accessibility audit against WCAG 2.2 (or the configured target). Used by
  the reviewPR workflow's quality-side a11y contributor when UI is in scope.
  Triggers on: "/a11y", "audit accessibility".

  **Do NOT use when:** the user wants architectural design review (use
  `architecture.review-design` — surfaces signals only), test coverage
  (use `review-test-coverage`), or code review (use `engineering.review-diff`).

  **Inputs:** UISpec@v1 OR a deployed URL OR a built artifact path.
  **Outputs:** ReviewVerdict@v1 + ReviewComment@v1[] at
  `.agents/state/findings/a11y/<id>/quality/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: auditA11y
bundle_contract_id: accessibility
visibility: public
---

# audit-a11y

Run an axe-core (or equivalent) pass + manual heuristic review against the configured WCAG target.

## Procedure

1. **Resolve the audit target.** UISpec (static), URL (live), or built artifact path.
2. **Run axe-core or equivalent.** Capture every violation with rule id, impact (minor/serious/critical), and selector.
3. **Manual heuristic pass.** Focus order, keyboard navigation, screen-reader announcements — things automated tools miss.
4. **Author findings.** Per finding: WCAG criterion (e.g., 1.4.3 Contrast), impact, suggested fix, citation in axe-core or WCAG.
5. **Compose `methodology.verify` inline** to confirm every finding is grounded.
6. **Write** ReviewVerdict + ReviewComment under `.agents/state/findings/a11y/<id>/quality/`.

## Hard rules

- **Every finding cites a WCAG criterion** (or equivalent standard).
- **No "looks fine" without ran-the-checker confirmation.**
- **Bounded scope.** ≤ 50 elements / 5 screens per run.
