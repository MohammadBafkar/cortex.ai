---
name: review
description: |
  **Use when:** the user types `/review [pr-id|paste]` to get a structured review of
  a pull request. When `marketplace` is installed, the marketplace command runs the
  full multi-contributor `reviewPR` workflow (engineering + quality + security where
  admitted); this engineering-side `/review` is the standalone path.

  **Do NOT use when:** the user wants to write or fix code (`/implement`) or wants a
  security audit only (use `security.audit` at P1).

  **Inputs:** optional pr-id (resolves to `.agents/state/prs/<pr-id>/engineering/pr.json`),
  optional pasted diff, or the most recent PR branch by default.
  **Outputs:** ReviewComment@v1[] + ReviewVerdict@v1 under
  `.agents/state/reviews/<pr-id>/engineering/`.
argument-hint: "[pr-id-or-paste]"
allowed-tools: [Task, Read, Grep, Bash]
---

# /review

Dispatch the `code-reviewer` subagent. When `marketplace` is installed, defer to its multi-contributor `reviewPR` workflow instead.

## Procedure

1. Resolve the PR:
   - If the argument matches `^[A-Z]+-\d+$` (e.g., `PR-12`), read `.agents/state/prs/<id>/engineering/pr.json`.
   - If the argument starts with `diff --git`, treat as a pasted diff in scope.
   - Otherwise, find the most recent unmerged branch matching `feat/*|fix/*|refactor/*` and review its diff against the merge-base.
2. Verify SoD: refuse if the reviewer principal matches the PR author principal.
3. Dispatch `code-reviewer` with the resolved PR reference.
4. After the subagent returns, surface the verdict path and a one-line summary.

## Token / latency budget

p95 ≤ 30 s for a small PR (≤ 200 LOC) end-to-end (subagent dispatch overhead + review).
