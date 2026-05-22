---
capability_interface_id: reviewTestCoverage
version: 1
bundle_contract_id: test-authoring
schema_in: PullRequest@v1
schema_out: [ReviewVerdict@v1, ReviewComment@v1[]]
---

# reviewTestCoverage@v1

Reviews a `PullRequest@v1` from the test-coverage perspective. Produces per-contributor `ReviewVerdict@v1` and `ReviewComment@v1` records under `.agents/state/reviews/<pr-id>/quality/`. The orchestrator (`marketplace.merge-review`) merges these with engineering's review and writes the PR-level composite verdict.

## Inputs

- `PullRequest@v1` (the diff)
- `TestSuite@v1` + `TestRun@v1` (when present — usually for the same `pr-id`)
- `UserStory@v1` (optional)

## Outputs

- `ReviewVerdict@v1` at `.agents/state/reviews/<pr-id>/quality/verdict.json`
- `ReviewComment@v1[]` at `.agents/state/reviews/<pr-id>/quality/comments/<n>.json`

## What this review checks (vs engineering.review-diff)

| Concern | Owned by |
| --- | --- |
| Correctness, maintainability, style, edge cases | engineering.review-diff |
| **Test coverage adequacy** | quality.review-test-coverage |
| **Test quality (assertion strength, mutation score, no flakes)** | quality.review-test-coverage |
| Security findings, vuln scans | security (P1) |
| Accessibility findings | quality (P1, separate skill) |

This skill MUST cite a coverage- or test-quality-related rubric on every comment. A comment about a missing function (engineering territory) is misplaced and should be reflected back into engineering's review.

## Per-path ownership

Writes under `.agents/state/reviews/<pr-id>/quality/` (composite contributor subdir). PEP enforces — quality cannot write under `engineering/` or any other contributor's subdir.

## Non-functional contract

- p95 latency: 30 s for a small PR.
