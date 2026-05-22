---
capability_interface_id: reviewLicense
version: 1
bundle_contract_id: governance
schema_in: DependencyManifest@v1
schema_out: LicenseReview@v1
---

# reviewLicense@v1

Walks every transitive OSS dependency and classifies license (permissive / weak-copyleft / strong-copyleft / unknown).

## Inputs

- `DependencyManifest@v1` derived from lockfiles (cargo / npm / pip / go.sum / gradle).

## Outputs

- `LicenseReview@v1` at `.agents/state/governance/licenses/<period>/marketplace/review.json` + the attribution file the build needs to ship.

## Non-functional contract

- **Idempotency:** yes per (manifest + license-DB version).
- **Latency budget:** p95 ≤ 60 s for a typical lockfile (≤ 500 deps).
- **Token budget:** ≤ 8K (mostly aggregation; Haiku-class).
- **HITL:** **checkpoint 17** (Copyleft OSS dependency) for any AGPL / strong-copyleft adoption.

## Failure modes

- Unknown license → block; require manual classification.
- Copyleft in a closed-source build target → refuse (legal violation).
- License DB unreachable → state: `requires_human`; never assume.

## Fixtures

Golden: `license-review-flags-agpl`.
Adversarial: `license-classifies-unknown-as-permissive` (refused).
