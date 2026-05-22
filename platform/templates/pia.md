<!--
Template: PrivacyImpactAssessment — GDPR Art. 35 / CCPA equivalent.
Authored by: security.run-pia.
Required: lawful basis per data flow; mitigations are concrete (not "we'll be careful").
HITL: mandatory DPO sign-off for high-risk processing.
Remove this block before promotion.
-->

# Privacy Impact Assessment: <feature / system>

- **Status:** proposed
- **Date:** <YYYY-MM-DD>
- **Author:** <privacy lead>
- **PRD:** <link or id>
- **DPO sign-off required:** <yes if high-risk processing | no>
- **Regulations in scope:** <GDPR | CCPA | HIPAA | PCI-DSS | LGPD | ...>

## Data Flows

| Flow # | Source | Sink | Data class | Volume | Retention |
| --- | --- | --- | --- | --- | --- |
| 1 | <e.g., signup form> | <e.g., users table> | <pii_restricted> | <est. records/day> | <e.g., 7 years> |
| 2 | ... | ... | ... | ... | ... |

## Personal Data Inventory

<Per data flow, list the fields, their data class, and whether they're
identifiers, special-category, or derived.>

| Flow | Field | Class | Special category? | Identifier? |
| --- | --- | --- | --- | --- |
| 1 | email | pii_restricted | no | direct |
| 1 | full_name | pii_restricted | no | direct |
| ... | ... | ... | ... | ... |

## Lawful Basis (per flow)

<Mandatory. Each flow cites one of: consent | contract | legitimate interest |
legal obligation | vital interest | public task. The basis MUST be in the
applicable regulation's enumerated list.>

| Flow | Lawful basis | Citation |
| --- | --- | --- |
| 1 | consent | <link to consent record / mechanism> |
| 2 | contract | <link to ToS clause> |

## Risks

<Per `methodology.risk-assess`. Common risks: re-identification, secondary use,
retention overrun, cross-border transfer, breach notification SLA.>

| Risk | Likelihood × Impact | Mitigation |
| --- | --- | --- |
| <named risk> | <L × M / M × H / ...> | <concrete mitigation> |

## Mitigations (operational)

<Each is a concrete action, not a wish. Reference the implementing PR / ADR.>

- **Encryption at rest:** <AES-256 + KMS — implemented in PR-...>
- **Retention enforcement:** <cron deletes after N days — implemented in PR-...>
- **DSAR support:** <export endpoint at /privacy/export, ≤ 30d SLA — PR-...>
- **Erasure path:** <DataErasureRecord written by SUN bundle on request — workflow ...>
- **Cross-border transfers:** <SCCs in place + region-pinned — IaC ref ...>

## Breach Notification Plan

- **Trigger:** <when does the clock start?>
- **Internal SLA:** <hours from detection to internal escalation>
- **Regulatory SLA:** <e.g., 72h for GDPR Art. 33>
- **Customer comms:** owned by `content.write-status-update` + `content.write-advisory`.

## HITL

- [ ] Privacy officer review (this document)
- [ ] DPO sign-off (mandatory if high-risk processing per Art. 35)
- [ ] Legal review (cross-border transfers, special-category data)
- [ ] Workspace admin approval for any production data access (checkpoint 14)

## References

- PRD: <link>
- SystemDesignDoc: <link>
- Related ThreatModels: <ids>
- DPA register: <link>
