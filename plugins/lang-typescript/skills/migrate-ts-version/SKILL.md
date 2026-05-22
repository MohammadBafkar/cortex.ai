---
name: lang-typescript.migrate-ts-version
description: |
  **Use when:** the project is bumping its TypeScript compiler version
  (e.g., 5.3 → 5.4 or 4.x → 5.x) and wants a structured migration proposal
  with config diffs, deprecated-flag removals, lib updates, and a risk note.
  Triggers on: "/ts-migrate", "upgrade TypeScript".
  **Do NOT use when:** the user wants to bump a runtime dep (use generic
  `engineering.propose-dep-bump`), migrate from JS to TS
  (use `engineering.propose-conversion`), or skip the proposal and apply
  directly — this skill produces a proposal, not an apply.
  **Inputs:** PullRequest@v1 with the target TS version in the PR description,
  package.json change, or user prompt.
  **Outputs:** VersionMigrationProposal@v1 — a structured proposal as a unified
  diff plus risk notes.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: migrateTsVersion
bundle_contract_id: lang-typescript
visibility: public
---

# migrate-ts-version

Propose the diff to migrate a project's TypeScript compiler version. Do NOT apply.

## Procedure

1. **Identify current + target versions.** Read from `package.json` devDependencies and the PR description. If ambiguous, refuse with a `requires_human` envelope.

2. **Classify the bump:**
   - **Patch** (5.3.2 → 5.3.3): low risk; emit minimal proposal.
   - **Minor** (5.3 → 5.4): low-to-medium risk; review the TS release notes for breaking changes within the minor.
   - **Major** (4.x → 5.x): **HITL-gated.** Refuse with `state: requires_human` and surface the ADR template.

3. **Read the project's tsconfig(s).** Some projects have multiple — `tsconfig.json`, `tsconfig.build.json`, `tsconfig.test.json`, etc. Inspect each.

4. **Compose `methodology.read-code` inline** for any tsconfig you don't fully understand.

5. **Identify changes needed:**
   - Removed/renamed compiler flags (e.g., `suppressImplicitAnyIndexErrors` removed in 5.5).
   - `lib` updates (e.g., new global types added in ES2024).
   - Behavioral changes flagged in the release notes (e.g., `--moduleResolution` defaults changing).
   - `@types/*` packages that need a bump to match.

6. **Compose `methodology.risk-assess` inline.** What can break for callers? What runtime code might newly fail to compile?

7. **Compose `methodology.verify` inline** before emitting.

8. **Emit the proposal** as a `VersionMigrationProposal@v1`:
   - `current_version`, `target_version`, `classification` (patch|minor|major)
   - `tsconfig_diffs[]` — unified diffs per tsconfig file
   - `package_json_diff` — unified diff for `devDependencies`
   - `risk_notes[]` — references to specific TS release-notes sections
   - `requires_adr` (boolean — true for major bumps)

## Hard rules

- **Never auto-apply a major-version bump.** Refuse and produce an ADR template.
- **Don't downgrade silently.** A target < current is a refusal unless explicitly framed as a rollback (in which case route through `release-operate.rollback`).
- **Don't introduce strictness regressions.** Removing `strict: true` or relaxing flags inside this migration is a separate change and needs its own ADR.

## Failure handling

- Target version not yet GA → refuse with "wait for stable" diagnostic.
- Project not using TypeScript → refuse (out of scope; route to `engineering.propose-conversion` if the user actually wants TS adoption).
