---
name: content.write-release-notes
description: |
  **Use when:** a ReleaseRecord@v1 ships and the team needs user-facing
  release notes summarizing what changed, why it matters, and any breaking
  changes.

  **Do NOT use when:** the user wants internal docs (use `write-doc`), status
  updates (use `write-status-update`), or a postmortem (use
  `release-operate.postmortem`).

  **Inputs:** ReleaseRecord@v1.
  **Outputs:** ReleaseNotes@v1 at `.agents/state/comms/release-<id>/content/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeReleaseNotes
bundle_contract_id: stakeholder-comms
visibility: public
---

# write-release-notes

Author user-facing release notes from a ReleaseRecord.

## Procedure

1. **Load** ReleaseRecord + the included PRs + related ADRs.
2. **Classify changes**: new features (visible) / improvements / bug fixes / breaking changes / deprecations.
3. **Write for end users**, not engineers. Each item: what changed, why a user cares.
4. **Flag breaking changes** with migration steps.
5. **Compose `methodology.verify` inline.**
6. **Write** + HITL on publication (checkpoint 5 — Customer comms mass, C-tier MVP1).

## Hard rules

- **No engineer-jargon in user-facing notes.**
- **Breaking changes flagged in the lead, not buried.**
- **HITL required on publication.**

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/release-notes.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
