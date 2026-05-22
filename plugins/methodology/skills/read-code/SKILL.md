---
name: methodology.read-code
description: |
  **Use when:** a capability skill needs to orient in an unfamiliar codebase or
  module before authoring changes. Typically composed inline by
  `engineering.propose-pr` (refactor flow), `architecture.design-system`
  (P1), or by onboarding `mentor` sessions.

  **Do NOT use when:** the user wants a full code review (use
  `engineering.review-diff`), security audit (`security.audit` at P1), or
  refactor authoring (`engineering.propose-pr` with refactor branch).

  **Inputs:** a target — file, module, or pattern — plus the calling
  capability's reason for reading.
  **Outputs:** ephemeral. A structured orientation: entry points, call graph
  sketch, key invariants, test coverage estimate, owning bundle/team.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# read-code

Build a navigable mental model of a code region before authoring against it. Surface invariants and call-graph shape; do not propose changes.

## Procedure

1. **State the target** in one sentence.
2. **Identify entry points.** What functions are exported / called from outside the module? `grep`/`Glob` for the public surface.
3. **Sketch the call graph.** ≤ 5 nodes: each is "X calls Y under condition Z". Ignore trivial helpers.
4. **Surface invariants.** What MUST be true about the module's state at rest? (e.g., "the cache is never empty unless config.preload=false".) Invariants come from comments, assertion statements, and tests.
5. **Estimate test coverage.** Read the corresponding test file(s); note untested branches.
6. **Name the owner.** Search `CODEOWNERS`, recent `git blame`, or the plugin manifest for the responsible bundle.
7. **Do NOT propose changes.** Read-code is read-only. The calling capability decides what to author.

## Hard rules

- **No code edits.** PEP enforces.
- **Bounded scope.** Up to ~500 LOC per invocation; larger targets need `methodology.decompose` first.
- **No artifact writes.**

## Latency budget

p95 ≤ 30 s for ≤ 500 LOC.
