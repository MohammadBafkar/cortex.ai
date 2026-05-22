---
name: marketplace.review-ethics
description: |
  **Use when:** a PRD@v1 proposes a feature with potential ethical impact —
  bias-sensitive ML inference, dark-pattern UX, surveillance functionality,
  AI Act high-risk category. Triggers under the EU AI Act / NIST AI RMF.

  **Do NOT use when:** the user wants security (use `security.audit-vulns`)
  or privacy assessment (use `security.run-pia`).

  **Inputs:** PRD@v1.
  **Outputs:** EthicsReview@v1 at `.agents/state/ethics/<id>/marketplace/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewEthics
bundle_contract_id: governance
visibility: public
---

# review-ethics

Structured ethics review aligned with EU AI Act risk classification + NIST AI RMF.

## Procedure

1. **Classify under EU AI Act**: prohibited / high-risk / limited-risk / minimal-risk.
2. **Identify potentially affected populations** + bias vectors.
3. **Compose `methodology.risk-assess` inline** — what's the harm if the system is wrong?
4. **Mitigations:** human oversight, transparency to users, opt-out, recourse.
5. **HITL** on high-risk classifications (mandatory per EU AI Act).
6. **Compose `methodology.verify` inline.**
7. **Write** EthicsReview with classification + mitigations + monitoring plan.

## Hard rules

- **No high-risk feature ships without documented mitigations.**
- **HITL mandatory** on high-risk classifications.
- **No "ethics by hope".** Mitigations are testable.
