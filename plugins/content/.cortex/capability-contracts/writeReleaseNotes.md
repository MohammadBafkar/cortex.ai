---
capability_interface_id: writeReleaseNotes
version: 1
bundle_contract_id: stakeholder-comms
schema_in: ReleaseRecord@v1
schema_out: ReleaseNotes@v1
---

# writeReleaseNotes@v1

User-facing release notes from a `ReleaseRecord@v1`. Breaking changes lead, not bury.

## Inputs

- `ReleaseRecord@v1` (required) — state `approved`.
- Optional included PR list + ADR list.

## Outputs

- `ReleaseNotes@v1` at `.agents/state/comms/release-<id>/content/notes.md` using `platform/templates/release-notes.md`.

## Non-functional contract

- **Idempotency:** yes per ReleaseRecord.
- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 12K.
- **HITL:** publication routes through checkpoint 5 (Customer comms mass).

## Failure modes

- Breaking changes buried at the bottom → refuse (defect; the lead position is mandatory).
- Engineer-jargon in user-facing copy → refuse.
- Missing migration steps for a breaking change → refuse.

## Fixtures

Golden: `release-notes-for-shipped-feature`.
Adversarial: `release-notes-skips-breaking-changes` (refused).
