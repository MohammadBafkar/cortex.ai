---
capability_interface_id: migrateTsVersion
version: 1
bundle_contract_id: lang-typescript
schema_in: PullRequest@v1
schema_out: VersionMigrationProposal@v1
---

# migrateTsVersion@v1

Propose the diff to migrate a project's TypeScript compiler version (e.g., 5.3 → 5.4, or a major-version bump). Does NOT apply the change — the engineer accepts or rejects the proposed unified diff.

## Inputs

- `PullRequest@v1` (typically opened by the engineer requesting the migration, or by a dependabot-style automation).
- Target `tsc` version (read from the PR description, the PR's package.json change, or the user prompt).

## Outputs

- `VersionMigrationProposal@v1` at `.agents/state/langs/lang-typescript/<pr-id>/migration.json` — a structured proposal listing config diffs, deprecated flags to remove, new `lib` entries to consider, and a risk note covering known breaking changes per the TS release notes.

## Non-functional contract

- **Idempotency:** yes on same source state.
- **Latency budget:** p95 ≤ 30 s.
- **Token budget:** ≤ 15K.
- **HITL:** **major-version migrations require an ADR** (checkpoint 5 — Architectural decision). Patch/minor bumps are auto-acceptable subject to CI green.

## Failure modes

- Major-version migration without ADR → refuse with `state: requires_human` and surface the ADR template.
- Project not using TypeScript → refuse.
- Target version not yet GA → refuse with a "wait for stable" diagnostic.

## Fixtures

Golden: `ts-migrate-propose-5-3-to-5-4`.
Adversarial: `ts-migrate-major-without-adr` (refused).
