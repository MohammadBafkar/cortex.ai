---
name: refactor
description: |
  **Use when:** the user types `/refactor <target>` to apply a safety-net-first
  refactor: read-code → impact-analysis → cover the riskiest branches with
  tests → edit → review → CI. This is incubating and is not part of the V1
  default spine.

  **Do NOT use when:** the user wants new behavior (`/implement`), only a code
  read-through (use `methodology.read-code` directly when admitted at P1+), or
  to delete a capability (`/deprecate` at P1).

  **Inputs:** target (file, module, or pattern) + optional scope qualifier.
  **Outputs:** PullRequest + TestSuite (covering risky branches) + TestRun +
  ReviewVerdict + BuildArtifact.
argument-hint: "<target>"
allowed-tools: [Task, Read, Bash, Write]
---

# /refactor

Use `marketplace.route` to produce a `refactorWithSafety` route plan. Execute
only when the required methodology and quality skills are installed.

This workflow differs from `/implement` in that it leads with `methodology.read-code` and `methodology.risk-assess` (P1+) to scope the refactor and identify risky branches; then `quality.write-unit-test` covers those branches before any edit happens.
