---
name: security.audit-vulns
description: |
  **Use when:** a PullRequest or release candidate needs SAST + SCA + SBOM
  generation, plus secret-scanning. Triggers on: "/security-audit", "scan this
  PR for vulns".

  **Do NOT use when:** the user wants a threat model (use `threat-model`), a
  privacy assessment (use `run-pia`), or to actually fix a vuln (route to
  `engineering.propose-pr`).

  **Inputs:** PullRequest@v1 or ReleaseCandidate reference.
  **Outputs:** SecurityFinding@v1[] + SBOM@v1 at
  `.agents/state/findings/security/<id>/security/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: auditVulns
bundle_contract_id: security
visibility: public
---

# audit-vulns

Run SAST + SCA + secret-scan + SBOM generation against the target. Each finding cites a CVE / CWE / OWASP rule.

## Procedure

1. **Resolve target** (PR, commit, deployed env).
2. **SAST.** Run the configured analyzer (Semgrep, CodeQL, …). Each finding gets `rule_id`, `severity` (info|low|medium|high|critical), `affected_file:line`, `recommendation`.
3. **SCA.** Read the lockfiles; cross-reference with vuln DB (NVD, GHSA, OSV). Generate SBOM (SPDX or CycloneDX).
4. **Secret scan.** Run a secret-scanner against the diff (and history if requested). Any match is `severity: critical` until verified.
5. **Compose `methodology.risk-assess` inline** for high/critical findings.
6. **Compose `methodology.verify` inline** before promotion.
7. **Write** findings + SBOM at `.agents/state/findings/security/<id>/security/`.

## Hard rules

- **Every finding cites a CVE/CWE/OWASP rule id.**
- **No "looks safe" without a scanner pass.** Scanner output is the ground truth.
- **PII access requires two-person approval.** When the audit needs to inspect actual user data (rare; usually metadata is enough), two-person approval per GOVERNANCE.md checkpoint 8 (M-tier).
