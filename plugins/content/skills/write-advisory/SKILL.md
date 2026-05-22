---
name: content.write-advisory
description: |
  **Use when:** a SecurityFinding@v1 needs a public security advisory (CVE
  filing, customer notification, embargoed disclosure coordination).
  **Do NOT use when:** the user wants internal-only docs (use `write-doc`) or
  the actual fix (use `engineering.propose-pr`).
  **Inputs:** SecurityFinding@v1.
  **Outputs:** Advisory@v1 at
  `.agents/state/comms/advisory-<id>/content/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeAdvisory
bundle_contract_id: stakeholder-comms
visibility: public
---

# write-advisory

Author a security advisory coordinated with Security + Legal.

## Procedure

1. **Load** the SecurityFinding + any active embargo info.
2. **Determine disclosure path.** Coordinated disclosure (default) vs immediate (if already exploited in the wild).
3. **Write the advisory.** CVE id (if assigned), affected versions, impact, mitigation, credit (per researcher's preference).
4. **HITL** per checkpoint 18 (Embargoed CVE disclosure, C-tier MVP1) — Security + Legal + Comms triple-approval.
5. **Compose `methodology.verify` inline.**
6. **Write** + queue for publication under the agreed timeline.

## Hard rules

- **No premature disclosure.** Respect embargo.
- **Mandatory triple HITL** on disclosure.
- **No speculation about exploitation.** Cite the actual evidence.
