---
name: security-audit
description: |
  **Use when:** the user types `/security-audit [pr-id]` to run SAST + SCA +
  secret-scan + SBOM against a PR or release candidate.
  **Do NOT use when:** the user wants threat modeling (`/threat-model`) or PIA
  (`/pia`).
  **Inputs:** optional pr-id.
  **Outputs:** SecurityFinding@v1[] + SBOM@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---

# /security-audit

Dispatch `security-auditor` against the named PR.
