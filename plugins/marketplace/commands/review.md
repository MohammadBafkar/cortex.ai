---
name: review
description: |
  **Use when:** the user types `/review [pr-id]` to get a composite, parallel
  review across all admitted reviewer bundles. MVP1: engineering + quality.
  P1: + security. The marketplace command runs the `reviewPR` route, fans out
  admitted reviewers in parallel, and merges per-path verdicts.

  **Do NOT use when:** the user wants to author or fix code (`/implement`), do
  a security audit only (`security.audit` at P1), or run conformance
  (`/conformance`).

  **Inputs:** optional pr-id (resolves to `.agents/state/prs/<id>/engineering/pr.json`).
  **Outputs:** per-contributor ReviewVerdict envelopes + composite PR-level
  verdict at `.agents/state/reviews/<pr-id>/verdict.json`.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash]
---

# /review

Use `marketplace.route` to produce a `reviewPR` route plan, then execute it from
this parent command.

## Procedure

1. Resolve the PR — if no argument, use the most recent unmerged `feat/*|fix/*|refactor/*` branch.
2. Verify SoD precondition: refuse if the reviewer principal matches the PR author principal.
3. Dispatch leaf reviewer workers with `pr_id` set.
