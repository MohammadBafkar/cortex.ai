---
name: security.review-iam
description: |
  **Use when:** scheduled quarterly access review per SOC 2 CC6 or whenever a
  new permission scope is proposed. Triggers on: "/access-review", "review who
  has prod access".

  **Do NOT use when:** the user wants to grant a NEW permission (that's the
  permission broker path with HITL checkpoint 7), or audit code-level vulns
  (use `audit-vulns`).

  **Inputs:** PermissionGrant@v1[] from the platform's permission broker.
  **Outputs:** AccessReviewRecord@v1 at
  `.agents/state/iam/<period>/security/access-review.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewIAM
bundle_contract_id: identity-access
visibility: public
---

# review-iam

Walk every active permission grant; check least-privilege; flag stale grants.

## Procedure

1. **Enumerate active grants.** From the platform's permission broker registry.
2. **Per grant**: principal, scope, risk tier, last-used timestamp, approval timestamp, expiry.
3. **Flag** stale grants (not used in N days; threshold per data class), excess privilege (risk tier > role's typical maximum), and orphaned grants (principal no longer exists / left the org).
4. **Compose `methodology.verify` inline** to confirm flags are correct.
5. **Write** the AccessReviewRecord. Each flagged grant gets a recommended action: `revoke` | `time-bound` | `downscale` | `keep` with reason.
6. **HITL** on every flagged grant (checkpoint 7 — Permission scope, C-tier MVP1).

## Hard rules

- **Quarterly cadence enforced by GOVERNANCE.md (SOC 2 CC6).**
- **Every flag has a recommended action + reason.**
- **No mass revocations without HITL.**
