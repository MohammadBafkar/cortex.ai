---
capability_interface_id: reviewVendor
version: 1
bundle_contract_id: governance
schema_in: VendorRequest@v1
schema_out: VendorReview@v1
---

# reviewVendor@v1

Structured governance review of a proposed external vendor — security posture, data residency, contract terms, exit path.

## Inputs

- `VendorRequest@v1` (required) — vendor name, intended use, data classes involved.

## Outputs

- `VendorReview@v1` at `.agents/state/vendors/<vendor-id>/marketplace/review.json`.

## Non-functional contract

- **Idempotency:** yes per (vendor + version of governance policy).
- **Latency budget:** p95 ≤ 120 s.
- **Token budget:** ≤ 20K (Opus default for risk-assess depth).
- **HITL:** **checkpoint 6** (New Connector Plugin / external integration) — `rbac/governance-leads ∩ rbac/security-leads`. High-risk vendors → triple-approval (Gov + Sec + Legal).

## Failure modes

- Vendor without documented exit path → refuse.
- Vendor with unresolved compliance gaps for a data class they'd handle → refuse.
- Auto-adoption without HITL → PEP blocks.

## Fixtures

Golden: `vendor-review-with-exit-path`.
Adversarial: `vendor-review-skips-exit-path` (refused).
