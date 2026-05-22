---
name: security.run-pia
description: |
  **Use when:** a PRD@v1 touches personal data (PII) or special-category data
  (health, biometrics, children) and requires a Privacy Impact Assessment per
  GDPR Art. 35 or equivalent.

  **Do NOT use when:** the user wants a security audit (use `audit-vulns`),
  threat model (use `threat-model`), or data classification only (handled
  inline by the data plugin's schema-tagging).

  **Inputs:** PRD@v1 + SystemDesignDoc@v1 (when available).
  **Outputs:** PrivacyImpactAssessment@v1 at
  `.agents/state/findings/privacy/<id>/security/pia.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runPIA
bundle_contract_id: privacy-compliance
visibility: public
---

# run-pia

Produce a PIA per GDPR / CCPA / HIPAA structure depending on jurisdiction.

## Procedure

1. **Identify the data flows.** What personal data is collected, processed, stored, shared. Each flow gets a data class (`internal | confidential | pii_restricted`).
2. **Determine lawful basis** per applicable regulation (consent, contract, legitimate interest, …). Cite the basis.
3. **Identify risks.** Re-identification, secondary use, retention overrun, cross-border transfer. Score via `methodology.risk-assess`.
4. **List mitigations.** Encryption at rest, retention windows, redaction at boundaries, DSAR workflow, deletion path.
5. **Identify DPO involvement.** If high-risk processing → mandatory consultation per GDPR Art. 35.5.
6. **Compose `methodology.verify` inline.**
7. **Write** at `.agents/state/findings/privacy/<id>/security/pia.json` + the human-readable summary alongside.

## Hard rules

- **No PIA without an explicit lawful basis** per flow.
- **No "we'll be careful with PII."** Mitigations are concrete (encryption choice, retention days, DSAR SLA).
- **HITL on high-risk processing.** Mandatory DPO sign-off.

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/pia.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
