---
name: build
description: |
  **Use when:** the user types `/build [pr-id]` to run the CI pipeline (build +
  lint + test + package) and produce a signed BuildArtifact.
  **Do NOT use when:** the user wants only the test phase (use `/test`), only
  the apply phase (use `/apply`), or a full release (use `/release` once
  release-operate is admitted at P1).
  **Inputs:** optional pr-id (resolves to .agents/state/prs/<id>/engineering/pr.json);
  defaults to the most recent unmerged feat/fix/refactor branch.
  **Outputs:** PipelineRun + (on green) signed BuildArtifact.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash]
---

# /build

Apply the procedure in `platform.run-pipeline`. Resolve the PR, dispatch the CI pipeline, capture the run record, sign the artifact on green.
