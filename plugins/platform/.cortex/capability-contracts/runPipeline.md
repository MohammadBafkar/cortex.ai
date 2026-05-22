---
capability_interface_id: runPipeline
version: 1
bundle_contract_id: ci-cd
schema_in: PullRequest@v1
schema_out: [PipelineRun@v1, BuildArtifact@v1]
---

# runPipeline@v1

Triggers a CI pipeline against the branch named in the `PullRequest@v1` envelope, captures the run, and produces a signed `BuildArtifact@v1` on green.

## Inputs

- `PullRequest@v1` (required) — the diff being built. Must be in state `proposed` or `approved`. The envelope's `branch` is used as the build target.
- `TestSuite@v1` (optional) — when present, the pipeline includes the test step. Without it, the pipeline runs build + linters only.
- `ReviewVerdict@v1` (optional, P1+) — when the composite verdict at `.agents/state/reviews/<pr-id>/verdict.json` is `request_changes` or absent, the pipeline still runs but the resulting `BuildArtifact` is marked `gated`.

## Outputs

- `PipelineRun@v1` written to `.agents/state/runs/<run-id>/platform/run.json` with: `run_id`, `pr_id`, `commit_sha`, `stages[]`, `state` (running | green | failed | gated).
- `BuildArtifact@v1` written to `.agents/state/builds/<build-id>/platform/artifact.json` on green. Signed via `signArtifact@v1`. Promoted to CAS on SessionEnd.

## Methodology composition (inline)

- `methodology.verify` — composed before promoting the BuildArtifact from `proposed` to `approved`.

## Non-functional contract

- Idempotent on the same `commit_sha`: re-runs do not produce a new build; the existing artifact id is returned.
- p95 latency budget: 90 s for a small repo (no external deploys); the actual CI service determines the real ceiling.
- Token budget: ≤ 5K tokens — `runPipeline` is mostly orchestration, not LLM-heavy.

## Failure handling

- CI flake: 1 automatic retry; on second failure, `PipelineRun.state = failed` and the artifact envelope is not written.
- Network partition: the run is marked `requires_human`; the user can `/resume <run-id>` once connectivity returns.

## Golden fixtures (Phase 3)

- A clean PR with passing tests → `PipelineRun.state = green` + signed `BuildArtifact`.
- A PR with one failing test → `PipelineRun.state = failed`; no BuildArtifact written.

## Adversarial fixtures (Phase 3)

- PullRequest envelope claims a commit_sha that doesn't exist on the branch → blocked by CI; `state = failed`.
- An attempt to write `BuildArtifact` directly (skipping the pipeline) → PEP hook blocks at the workspace path.
