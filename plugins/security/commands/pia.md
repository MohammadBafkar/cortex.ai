---
name: pia
description: |
  **Use when:** the user types `/pia [prd-id]` to author a Privacy Impact
  Assessment for a PRD that touches personal data.
  **Do NOT use when:** the user wants vuln scanning or threat modeling.
  **Inputs:** prd-id.
  **Outputs:** PrivacyImpactAssessment@v1.
argument-hint: "<prd-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /pia

Dispatch `privacy-officer` against the named PRD.
