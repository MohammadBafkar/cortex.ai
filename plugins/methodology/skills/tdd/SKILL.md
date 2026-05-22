---
name: methodology.tdd
description: |
  **Use when:** a capability skill (typically `engineering.propose-pr` or
  `quality.write-unit-test`) needs to enforce a test-first discipline before
  implementing or changing observable behavior.

  **Do NOT use when:** the change is purely a comment, formatting, dead-code
  removal, or otherwise has no observable behavior change. Also not for
  refactors that are guaranteed behavior-preserving and already covered
  by existing tests.

  **Inputs:** a behavior-change description and the relevant code paths.
  **Outputs:** ephemeral guidance shaping the surrounding capability skill's
  procedure. Does NOT write test files itself — `quality.write-unit-test`
  is the authority for test authorship.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# tdd

Enforce the red-green-refactor discipline for any change that introduces or alters observable behavior.

## Procedure

1. **Restate the behavior change** in one sentence.
2. **Verify a failing test exists for the new behavior** (red). If none exists, identify the missing test case explicitly — the surrounding capability skill is responsible for either marking a TODO for `quality.write-unit-test` to pick up, or (when admitted) dispatching `quality` directly via the workspace handoff.
3. **Implement the minimum change to make the test pass** (green).
4. **Refactor** for clarity and structure while keeping the test green.
5. **Verify no other test regressed.** If the surrounding capability skill is `engineering.propose-pr`, this means re-running the existing test suite via `quality.run-unit-tests` after the change.

## Hard refusals

- **Refuse to skip the test.** If a user asks "just implement it without the test", refuse and explain: untested behavior changes are a conformance violation under this skill. The user can choose not to invoke `tdd`, but invoking `tdd` and then skipping is a defect.
- **Do NOT write test files yourself.** Test authorship belongs to `quality`. You guide the surrounding capability skill.

## Inline composition

`engineering.propose-pr` composes `tdd` inline once per behavior-changing step. `quality.write-unit-test` composes `tdd` inline as its primary procedure. No subagent dispatch.

## Latency budget

- p95 ≤ 5 s per turn (this is methodology guidance, not LLM-heavy reasoning).
