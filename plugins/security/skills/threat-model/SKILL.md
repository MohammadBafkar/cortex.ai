---
name: security.threat-model
description: |
  **Use when:** a SystemDesignDoc@v1 names trust boundaries and needs a STRIDE
  threat model + mitigations. Triggers on: "/threat-model", "what could
  attackers do here?".

  **Do NOT use when:** the user wants a code-level scan (use `audit-vulns`),
  privacy assessment (use `run-pia`), or implementation (route to
  `engineering.propose-pr`).

  **Inputs:** SystemDesignDoc@v1.
  **Outputs:** ThreatModel@v1 at
  `.agents/state/findings/security/<id>/security/threat-model.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: threatModel
bundle_contract_id: security
visibility: public
---

# threat-model

Apply STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) against the trust boundaries named in the SystemDesignDoc.

## Procedure

1. **Load** SystemDesignDoc + relevant NFRs + the production environment context.
2. **For each trust boundary**: walk STRIDE; for each applicable category, name one specific threat with attacker capability + asset at risk.
3. **Score**: likelihood × impact via `methodology.risk-assess` inline.
4. **For each medium/high threat, propose a mitigation.** Mitigations are concrete (e.g., "mTLS with revocable cert", "rate-limit at the API gateway"), not vague ("be careful").
5. **Compose `methodology.verify` inline** before promotion.
6. **Write** at `.agents/state/findings/security/<id>/security/threat-model.json`.

## Hard rules

- **Every trust boundary gets at least one STRIDE pass.** Skipping a boundary is a defect.
- **No threat without a named asset.** "X could fail" is not a threat; "an attacker with a leaked JWT could read /admin/users" is.
- **Mitigations are concrete or escalated to HITL** for design rework.

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/threat-model.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
