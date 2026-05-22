---
name: marketplace.merge-review
description: |
  **Use when:** a reviewPR workflow has populated `.agents/state/reviews/<pr-id>/`
  with one or more per-contributor ReviewVerdict envelopes and needs the composite
  PR-level verdict written. Triggers from the parent workflow executor after the
  parallel review fan-out completes.

  **Do NOT use when:** the user wants to author a single-contributor review
  (use `engineering.review-diff` directly), produce a build artifact, or
  query the audit log.

  **Inputs:** pr-id and the composite review tree under
  `.agents/state/reviews/<pr-id>/<contributor>/verdict.json`.
  **Outputs:** ReviewVerdict@v1 written to
  `.agents/state/reviews/<pr-id>/verdict.json` (PR-level composite — owned by the
  orchestrator, NOT by any contributor).
type: capability
produces_authoritative_artifacts: true
capability_interface_id: mergeReview
bundle_contract_id: orchestration-thin
visibility: public
---

# merge-review

You are the review orchestrator. Read every contributor's verdict and write the merged PR-level verdict.

## Procedure

1. **Glob the contributor verdicts.** `.agents/state/reviews/<pr-id>/*/verdict.json`. Skip the PR-level `verdict.json` itself.
2. **Validate.** Each per-contributor envelope must pass `review-verdict.v1.json` (schema check) and must reference the same `pr_id`.
3. **Compute the composite decision.**
   - `approve` only if every contributor decided `approve`.
   - `request_changes` if any contributor decided `request_changes`.
   - `comment` otherwise (all informational).
4. **SoD.** Refuse if the PR author principal appears as a reviewer principal in any contributor verdict (the platform PEP also enforces).
5. **Verify.** Invoke `methodology.verify` inline — does the composite decision genuinely reflect what each reviewer said?
6. **Write the composite.** `.agents/state/reviews/<pr-id>/verdict.json` with `reviewer_plugin: marketplace`, `reviewer_bundle: orchestration-thin`, and `comment_ids` aggregated across contributors.
7. **Announce.** "Composite review for PR-12: APPROVE (engineering, quality — both clean)."

## Per-path ownership

You are the **only** writer of the PR-level `verdict.json`. PEP enforces — `reviews` is a composite-artifact path, but a contributor subdir match is required for non-orchestrator writes; the orchestrator (`marketplace`) is the owner of the `reviews` top-level tree per `state-ownership.json`, so writing the parent file is uncontested.

## Failure modes

- Zero contributors → write `state: failed` with `failure_reason: no_contributors` and surface to HITL.
- Conflicting verdicts that cannot be reconciled mechanically (e.g., `approve` + `request_changes` on the same `path:line`) → emit a `ConflictDecision@v1` to `.agents/state/conflicts/` and surface to HITL.
