---
capability_interface_id: reviewIAM
version: 1
bundle_contract_id: identity-access
schema_in: PermissionGrant@v1[]
schema_out: AccessReviewRecord@v1
---

# reviewIAM@v1

Quarterly access review per SOC 2 CC6. Walks every active `PermissionGrant@v1` and flags stale / excess / orphaned grants.

## Inputs

- `PermissionGrant@v1[]` — enumerated from the platform's permission-broker registry.

## Outputs

- `AccessReviewRecord@v1` at `.agents/state/iam/<period>/security/access-review.json`. Each flagged grant has a recommended action: `revoke | time-bound | downscale | keep` with reason.

## Non-functional contract

- **Cadence:** quarterly (enforced by `GOVERNANCE.md` §2.1 SOC 2 CC6 mapping).
- **Idempotency:** yes per quarter.
- **Latency budget:** p95 ≤ 120 s for a registry of ≤ 500 grants.
- **Token budget:** ≤ 12K.
- **HITL:** mandatory for every flagged grant (checkpoint 7 — Permission scope).

## Failure modes

- Mass revocation without HITL → PEP blocks.
- Flag without recommended action → refuse (defect).
- Orphaned-grant detection requires identity-provider connector; if unreachable → state: `requires_human`.

## Fixtures

Golden: `quarterly-access-review` (≥ 1 stale-grant flag).
Adversarial: `iam-mass-revoke-without-hitl` (blocked).
