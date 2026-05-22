---
name: implement
description: |
  **Use when:** the user types `/implement <description-or-capability-id>` to
  ship a feature end-to-end. The marketplace command runs the V1 feature spine:
  engineering authors a PR, quality handles unit tests, platform runs the
  pipeline, and engineering reviews the diff.

  **Do NOT use when:** the user wants only a review (`/review`), only a refactor
  outline without edits (`/refactor`), or to brainstorm (`/brainstorm`).

  **Inputs:** free-text description OR a capability-id resolving to a UserStory
  marker in `.agents/state/intakes/`.
  **Outputs:** PullRequest, TestSuite, TestRun, ReviewVerdict, PipelineRun, plus
  the WorkflowRun trace.
argument-hint: "<description-or-capability-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /implement

Use `marketplace.route` to produce a `RoutePlan` for `shipFeature`, then execute
the plan from this parent command.

This command supersedes the engineering-side `/implement` when both plugins are installed (which is the MVP1 default). The engineering-side `/implement` is the standalone path used when only `engineering` and `methodology` are installed.

## Procedure

1. Resolve `${CLAUDE_PLUGIN_ROOT}/workflows/shipFeature.yaml`.
2. If the argument matches a capability-id pattern (e.g., `C-42`), pass it as `capability_id`; the workflow reads `.agents/state/intakes/C-42.json` as the UserStory.
3. Otherwise, treat the argument as free-text and create an ad-hoc UserStory marker.
4. Execute the route plan from this parent command. Worker subagents are leaves.
