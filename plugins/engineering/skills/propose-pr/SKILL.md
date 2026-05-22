---
name: engineering.propose-pr
description: |
  **Use when:** the user asks to implement a feature, fix a bug, refactor existing code,
  or otherwise produce a `PullRequest@v1` from a `UserStory@v1` or equivalent intent.
  Triggers on: "implement", "build", "add", "fix", "refactor", "/implement".

  **Do NOT use when:** the user wants to write or run tests (use `quality.write-unit-test`
  or `quality.run-unit-tests`), review an existing diff (use `engineering.review-diff`),
  propose an architecture decision (use `engineering.propose-adr`), or brainstorm
  options (use `methodology.brainstorm`).

  **Inputs:** UserStory@v1 (artifact id or in-context body), optional PRD@v1, optional ADR@v1.
  **Outputs:** PullRequest@v1 written to `.agents/state/prs/<pr-id>/engineering/pr.json` and
  the file diffs themselves on a feature branch.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: implementChange
bundle_contract_id: code-authoring
visibility: public
---

# propose-pr

You are the implementer. Read the linked `UserStory@v1` (and any referenced `PRD@v1` / `ADR@v1`). Produce code changes on a feature branch and write a `PullRequest@v1` envelope describing the work.

## Procedure

1. **Clarify if needed.** If the user story is ambiguous, invoke `methodology.clarify` inline — read the methodology SKILL.md in the current context and follow it. Ask at most three structured questions before any edit. Do NOT Task-dispatch a methodology subagent (subagents cannot nest — see `ARCHITECTURE.md` §6.13).

2. **Decompose.** Invoke `methodology.plan-work` inline to decompose the change into at most 5 verifiable steps. Each step states what changes and how the change will be verified.

3. **Test-first per step.** For each step that introduces or changes observable behavior, invoke `methodology.tdd` inline. The actual test authoring belongs to `quality.write-unit-test` (P1+ for full coverage; MVP1 the engineering implementer marks the test as a TODO in the PR body so `quality.test-author` can pick it up). Do NOT write test files yourself — that authority belongs to `quality`. The platform PreToolUse hook blocks any `engineering` write under `.agents/state/tests/` or `tests/` directories not previously owned by `engineering`.

4. **Generate the diff.** Make the file edits. Stage them on a feature branch named `feat/<slug>` for new behavior, `fix/<slug>` for bug fixes, or `refactor/<slug>` for behavior-preserving changes.

5. **Verify.** Before opening the PR, invoke `methodology.verify` inline to confirm the diff actually solves the user story. If verification fails, return to step 2 (bounded — at most 5 inner iterations before escalating to HITL).

6. **Write the PullRequest envelope.** Author a `PullRequest@v1` JSON envelope at `.agents/state/prs/<pr-id>/engineering/pr.json` with: `pr_id`, `user_story_ref`, `branch`, `commit_sha`, `diff_summary`, `methodology_invoked: [plan-work, tdd, verify]`, `trust_label`, and `state: proposed`.

7. **Announce.** Emit a plain-prose line summarizing what was produced ("Opened branch `feat/oauth-login` with 4 file changes and a PullRequest envelope at .agents/state/prs/PR-12/engineering/"). Do NOT prefix with `[Plugin:Component]` markers — structured telemetry is the machine record.

## Cross-bundle handoff

After step 6, the parent workflow executor continues the `RoutePlan` — typically
to `quality.write-unit-test` reading the same `pr-id`. Your job ends with the
PullRequest envelope; do not write under `tests/<pr-id>/quality/` or
`runs/<pr-id>/platform/`.

## Permission scopes (declared in manifest.json)

- `git:write` (medium) — to create branches and commits.
- `github:pr:write` (medium, when `connector-github` is installed) — to push branches; local MVP runs may operate without it.

## Failure handling

- If the platform PEP hook blocks a write (cross-path violation), the envelope is marked `state: failed` with `failure_reason: pep_block`; the orchestrator surfaces the violation to the user.
- If the token budget hits 100%, the next tool call fails closed; the user can `/reset-budget` or raise the ceiling.
- If `methodology.verify` fails after 5 inner iterations, the envelope is marked `state: requires_human`; HITL surfaces the gap.
