---
name: implement
description: |
  **Use when:** the user types `/implement <description-or-capability-id>` to ship a
  feature, fix a bug, or refactor. Triggers the engineering implementer subagent
  (or the cross-bundle `shipFeature` workflow when `marketplace.route`
  is the orchestrator).

  **Do NOT use when:** the user wants only a review (`/review`), only a refactor
  outline without edits (`/plan`), or to brainstorm (`/brainstorm`).

  **Inputs:** free-text description OR a capability-id resolving to a UserStory in
  `.agents/state/intakes/`.
  **Outputs:** PullRequest@v1 envelope + a feature branch with the change.
argument-hint: "<description-or-capability-id>"
allowed-tools: [Task, Read, Bash, Edit, Write]
---

# /implement

Dispatch the `code-author` subagent with the user's intent as the prompt. When `marketplace` is installed, the marketplace's `/implement` command supersedes this one and runs the full `shipFeature` workflow (code → tests → review → CI → audit); this engineering-side `/implement` is the standalone path used when only `engineering` and `methodology` are installed.

## Procedure (this command)

1. If `marketplace` is installed and reports a `shipFeature` workflow, defer to that — emit a single line indicating the workflow id and exit.
2. Otherwise, dispatch the `code-author` subagent with:
   - `task`: the user's argument body.
   - `working_dir`: the current workspace root.
   - `intake_marker`: if the argument matches a capability-id pattern (e.g., `C-42`), the path `.agents/state/intakes/<id>.json` is included as a referenced input.
3. After the subagent returns, surface the PullRequest envelope path and a one-line summary to the user.

## Token / latency budget

This command itself is light — under 1s p95 to dispatch. The subagent's own budgets apply (see `propose-pr/SKILL.md`).
