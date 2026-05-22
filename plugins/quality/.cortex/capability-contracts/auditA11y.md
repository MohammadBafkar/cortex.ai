---
capability_interface_id: auditA11y
version: 1
bundle_contract_id: accessibility
schema_in: UISpec@v1
schema_out: [ReviewVerdict@v1, ReviewComment@v1[]]
---

# auditA11y@v1

Full accessibility audit against WCAG 2.2 (or configured target). Distinct from `architecture.review-design` which surfaces a11y *signals* only.

## Inputs

- `UISpec@v1` (Figma export), live URL, or built artifact path.

## Outputs

- `ReviewVerdict@v1` + `ReviewComment@v1[]` at `.agents/state/findings/a11y/<id>/quality/`. Each finding cites a WCAG criterion (e.g., 1.4.3 Contrast).

## Non-functional contract

- **Idempotency:** yes per (target + axe rule version).
- **Latency budget:** p95 ≤ 90 s for ≤ 50 elements / 5 screens.
- **Token budget:** ≤ 10K.
- **HITL:** P1 surfaces blockers (impact: critical) for HITL review per checkpoint 13 (Chaos experiment) variant; minor findings auto-route as backlog items.

## Failure modes

- Finding without WCAG citation → refuse.
- "Looks fine" without scanner output → refuse.
- Scope > 50 elements → refuse; require decomposition.

## Fixtures

Golden: `a11y-audit-flags-contrast`.
Adversarial: `a11y-finding-without-wcag-citation` (refused).
