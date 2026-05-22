---
capability_interface_id: auditVulns
version: 1
bundle_contract_id: security
schema_in: PullRequest@v1
schema_out: [SecurityFinding@v1[], SBOM@v1]
---

# auditVulns@v1

Runs SAST + SCA + secret-scan against a PR or release candidate; emits `SecurityFinding@v1` per issue + an `SBOM@v1`.

## Inputs

- `PullRequest@v1` OR `BuildArtifact@v1` reference.

## Outputs

- `SecurityFinding@v1[]` at `.agents/state/findings/security/<id>/security/finding-*.json` — each cites a CVE / CWE / OWASP rule id.
- `SBOM@v1` at `.agents/state/findings/security/<id>/security/sbom.json` (SPDX or CycloneDX).

## Non-functional contract

- **Idempotency:** yes on same commit_sha (scanner output is deterministic).
- **Latency budget:** p95 ≤ 5 min for SAST + SCA + secret-scan on a small repo. Real CI service determines the ceiling.
- **Token budget:** ≤ 5K (mostly orchestration, not LLM).
- **HITL:** `pii:access` two-person approval if scanner output is sampled against real PII; otherwise auto.

## Failure modes

- Finding without rule id → refuse to write (defect).
- Secret scan match → `severity: critical` until manually verified; never auto-dismissed.
- Scanner network failure → state: `requires_human` with retry guidance.

## Fixtures

Golden: `sast-clean-pr`, `sast-flags-sql-injection`.
Adversarial: `audit-without-scanner-output` (refused).
