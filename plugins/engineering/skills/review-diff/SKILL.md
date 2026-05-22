---
name: engineering.review-diff
description: |
  **Use when:** the user asks to review a pull request, a diff, a pasted patch, or a
  recently modified file for correctness, style, or maintainability. Triggers on:
  "review my PR", "look at this diff", "what do you think of this change", "/review".

  **Do NOT use when:** the user is asking for a security audit (use `security.audit`
  when admitted), an accessibility review (use `quality.audit-a11y` when admitted),
  a performance review (use `quality.benchmark` when admitted), or writing or fixing
  code (use `engineering.propose-pr`).

  **Inputs:** PullRequest@v1 (artifact id), optional UserStory@v1, optional ADR@v1.
  **Outputs:** ReviewComment@v1[] and one ReviewVerdict@v1, both written to
  `.agents/state/reviews/<pr-id>/engineering/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: reviewDiff
bundle_contract_id: code-review
visibility: public
---

# review-diff

You are the reviewer. Read the linked `PullRequest@v1` envelope, the parent `UserStory@v1`, and any referenced `ADR@v1`. Produce zero or more `ReviewComment@v1` artifacts and exactly one `ReviewVerdict@v1`.

## Procedure

1. **Load the PR.** Read the envelope at `.agents/state/prs/<pr-id>/engineering/pr.json`. Read the diff itself via the GitHub MCP connector (`connector-github`) when admitted, or via `git diff` against the merge-base for MVP1.

2. **Verify SoD.** If the reviewer's `principal_id` equals the PR's `author_principal_id`, refuse with a clear message ("self-review is prohibited by SoD policy"). The platform PreToolUse hook would block the artifact write anyway; refusing here gives a better UX.

3. **Apply the rubric.** For each diff hunk, check: correctness (does it do what the story asks?), maintainability (will another engineer understand it in six months?), edge cases (off-by-one, empty input, error path), and adherence to the referenced ADR. Each comment MUST cite a `ReviewRubric` item id.

4. **Verify.** Invoke `methodology.verify` inline before emitting the verdict — confirm the review is grounded in the user story, not just style preferences.

5. **Write comments.** For each finding, write a `ReviewComment@v1` JSON file at `.agents/state/reviews/<pr-id>/engineering/comments/<n>.json` with: `pr_id`, `path`, `line_range`, `rubric_id`, `severity` (info | minor | major | blocking), `message`, `suggested_fix` (optional).

6. **Write the verdict.** Write a `ReviewVerdict@v1` at `.agents/state/reviews/<pr-id>/engineering/verdict.json` with: `pr_id`, `reviewer_principal_id`, `decision` (one of `approve` | `request_changes` | `comment`), `summary`, `comment_ids[]`, `methodology_invoked: [verify]`, `trust_label`, `state: proposed`.

7. **Announce.** Emit a plain-prose line summarizing the verdict ("Review of PR-12: approve with 2 minor comments"). Suppressed automatically in `CLAUDE_CODE_NON_INTERACTIVE=1`.

## Per-path ownership

You write only under `.agents/state/reviews/<pr-id>/engineering/`. Other reviewers (`quality.review-test-coverage`, `security.review-vulns` at P1) write under their own contributor subdirs at the same `<pr-id>` parent. The composite `verdict.json` at the PR root is owned by the orchestrator (`marketplace.merge-review`), not by any contributor. Per `ARCHITECTURE.md` §8.1.

## Do NOT

- **Do NOT modify code.** Writing or editing code under review is forbidden. PEP hook blocks.
- **Do NOT approve your own PR.** SoD enforced by the platform.
- **Do NOT write to another contributor's subdir.** PEP hook blocks.
- **Do NOT exceed five inner iterations** of refining a comment. Escalate to HITL after the cap.

## Latency and token budget

- p95 ≤ 30 s for a small PR (≤ 200 LOC).
- ≤ 15K tokens.
- These budgets are tracked by the platform PostToolUse hook; the workflow surfaces a warning at 60% of the session ceiling.
