---
name: marketplace.review-vendor
description: |
  **Use when:** the team proposes a new external vendor (SaaS, API, model
  provider, OSS supplier) and needs a structured governance review covering
  security posture, data residency, contract terms, exit path.

  **Do NOT use when:** the user wants license review only (use `review-license`)
  or ethics review only (use `review-ethics`).

  **Inputs:** VendorRequest@v1.
  **Outputs:** VendorReview@v1 at `.agents/state/vendors/<id>/marketplace/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewVendor
bundle_contract_id: governance
visibility: public
---

# review-vendor

Structured vendor review with explicit exit path.

## Procedure

1. **Compose `methodology.research` inline** — pull the vendor's public security posture (SOC2 / ISO 27001 / Trust Center), incident history, financial stability indicators.
2. **Compose `methodology.risk-assess` inline** — data residency, lock-in, regulatory exposure.
3. **Verify alignment** with `security` plugin's privacy requirements.
4. **Document the exit path.** "If we drop this vendor in 18 months, what does that take?" — if the answer is "rewrite everything", flag as high risk.
5. **HITL** per checkpoint 6 (New Connector Plugin / external integration, C-tier MVP1).
6. **Compose `methodology.verify` inline.**
7. **Write** VendorReview.

## Hard rules

- **No vendor without documented exit path.**
- **Triple-approval** for high-risk vendors (Governance + Security + Legal).
