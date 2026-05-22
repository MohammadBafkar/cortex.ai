---
name: marketplace.review-license
description: |
  **Use when:** a DependencyManifest@v1 introduces or updates third-party OSS
  dependencies and the team needs a license-compatibility review (copyleft,
  attribution, redistribution).
  **Do NOT use when:** the user wants security vuln scan (use
  `security.audit-vulns`) or vendor review (use `review-vendor`).
  **Inputs:** DependencyManifest@v1 (lockfile-derived).
  **Outputs:** LicenseReview@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewLicense
bundle_contract_id: governance
visibility: public
---

# review-license

Walk every dependency; classify license; flag copyleft conflicts.

## Procedure

1. **Enumerate dependencies + transitive licenses** from the lockfile (cargo, npm, pip, go.sum, …).
2. **Classify** per the org's allowed/forbidden list: permissive (MIT, BSD, Apache 2) / weak copyleft (LGPL, MPL) / strong copyleft (GPL, AGPL) / unknown.
3. **Flag conflicts** (e.g., AGPL pulled into a closed-source SaaS).
4. **HITL** per checkpoint 17 (Copyleft OSS dependency, C-tier MVP1).
5. **Compose `methodology.verify` inline.**
6. **Write** LicenseReview + the attribution file the build needs to ship.

## Hard rules

- **Every dep classified.** Unknown licenses block.
- **HITL on any copyleft adoption.**
