---
name: platform.run-pipeline
description: |
  **Use when:** a PullRequest@v1 has been authored (and reviewed, at P1+) and
  needs a CI pipeline run — build + tests + signed BuildArtifact. Triggers on:
  "/build", "run CI on this PR", "build PR-12". Also auto-triggered by the
  hook on `gh pr create`.

  **Do NOT use when:** the user wants to author code (use `engineering.propose-pr`),
  write tests (use `quality.write-unit-test`), or apply IaC to an environment
  (use `platform.apply-iac` — separate capability with HITL).

  **Inputs:** PullRequest@v1 (id), optional TestSuite@v1 reference.
  **Outputs:** PipelineRun@v1 + (on green) signed BuildArtifact@v1 at
  `.agents/state/runs/<run-id>/platform/` and `.agents/state/builds/<build-id>/platform/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runPipeline
bundle_contract_id: ci-cd
visibility: public
---

# run-pipeline

You are the CI/CD orchestrator. Read the PullRequest envelope, trigger the pipeline against the named branch + commit, write the run record, and (on green) sign the build artifact.

## Procedure

1. **Load the PR envelope.** Read `.agents/state/prs/<pr-id>/engineering/pr.json`. Verify `state ∈ {proposed, approved}` and that `commit_sha` exists on the branch.

2. **Resolve the test suite.** If `.agents/state/tests/<pr-id>/quality/suite.json` exists, the pipeline includes the test step. If not, MVP1 falls back to build + linters only and emits a warning telemetry event flagging missing test coverage.

3. **Trigger CI.** Via `connector-github-actions` (or local `make ci` for MVP1 dev). Wait for completion; capture `stages[]` (build, lint, test, package).

4. **Write the run record.** Author `PipelineRun@v1` at `.agents/state/runs/<run-id>/platform/run.json` with stages, durations, and final state.

5. **On green, sign the artifact.** Invoke `signArtifact@v1` (same plugin, internal). Write `BuildArtifact@v1` at `.agents/state/builds/<build-id>/platform/artifact.json` with `signature`, `sbom_ref` (when SBOM is available — P1 via `security`), `provenance`.

6. **Verify.** Invoke `methodology.verify` inline before marking either artifact `approved` — confirm the build genuinely succeeded and was not approved on a flake retry.

7. **Announce.** "PipelineRun PR-12: green (build 24s, test 12s, package 8s); BuildArtifact signed and promoted."

## Per-path ownership

You write only under `.agents/state/runs/<run-id>/platform/` and `.agents/state/builds/<build-id>/platform/`. You **never** write under:

- `.agents/state/prs/<pr-id>/engineering/` (engineering owns the PR envelope)
- `.agents/state/tests/<pr-id>/quality/` (quality owns the TestSuite; you may read it, never write)
- `.agents/state/reviews/<pr-id>/<any>/` (reviewers own those)

PEP hook enforces.

## Failure modes

- CI flake: 1 automatic retry on the failing stage. On persistent failure, write `state: failed` and surface to the user.
- Build artifact written but signature failed: `state: requires_human`; admin can `/resume <run-id>` after fixing signing config.
