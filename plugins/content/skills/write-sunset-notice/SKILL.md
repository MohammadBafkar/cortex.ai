---
name: content.write-sunset-notice
description: |
  **Use when:** a DeprecationProposal@v1 is approved and customers need
  notice — what's being sunset, when, the migration path. Triggers in the
  sunsetCapability workflow.
  **Do NOT use when:** the user wants the deprecation decision itself (use
  `product.propose-deprecation` at P1+), or the actual cutover (use
  release-operate.release in reverse).
  **Inputs:** DeprecationProposal@v1.
  **Outputs:** SunsetNotice@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeSunsetNotice
bundle_contract_id: sunset
visibility: public
---

# write-sunset-notice

Author a sunset notice with explicit timelines + migration path.

## Procedure

1. **Load** the DeprecationProposal + the migration path (if available).
2. **Draft the notice** — what's sunset, dates, customer impact, migration steps, support contact.
3. **Customer-language**, not engineer-language.
4. **Compose `methodology.verify` inline.**
5. **HITL** per checkpoint 20 (Sunsetting an actively used capability, C-tier MVP1).
6. **Schedule reminders** — typically 90/30/7-day reminders before cutover.

## Hard rules

- **No sunset without a migration path** (even if the path is "switch to vendor X").
- **HITL mandatory** on publication.
- **Mandatory cooldown:** 90-day minimum notice for an actively-used capability.
