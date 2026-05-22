---
capability_interface_id: mergeReview
version: 1
bundle_contract_id: orchestration-thin
schema_in: ReviewVerdict@v1[]
schema_out: ReviewVerdict@v1
---

# mergeReview@v1

Merges per-contributor `ReviewVerdict@v1` records on a composite review and writes the merged verdict at `.agents/state/reviews/<pr-id>/verdict.json` (the PR-level verdict — owned by the orchestrator, **not** by any contributor).

## Inputs

- A composite review subtree at `.agents/state/reviews/<pr-id>/` populated by ≥ 1 contributor bundle (engineering at MVP1; quality at MVP1; security + a11y at P1). Each contributor writes its own subdir per per-path disjointness (SPEC.md).

## Outputs

- `ReviewVerdict@v1` at `.agents/state/reviews/<pr-id>/verdict.json`. The composite is derived:
  - `decision: approve` only if every contributor approved.
  - `decision: request_changes` if any contributor requested changes.
  - `decision: comment` otherwise (informational reviews only).

## Why it lives here

The merged composite verdict is owned by **no individual contributor** — it's an orchestration artifact. The marketplace plugin is the orchestrator. PEP enforces this by mapping `.agents/state/reviews/` as a composite-artifact tree in `platform/settings/state-ownership.json`, with `reviews` listed in `composite_artifact_paths`.

## Procedure

1. **Glob the subdir.** `.agents/state/reviews/<pr-id>/*/verdict.json`.
2. **Validate** each per-contributor verdict against `review-verdict.v1.json`.
3. **Compute the composite decision** per the rule above.
4. **Apply SoD.** No PR author may sign the composite. The platform PEP enforces.
5. **Write** the composite envelope. Promote to CAS on SessionEnd.

## Failure modes

- Zero contributors present → composite verdict is not produced; parent workflow executor escalates.
- Contributor verdicts contradict in unexpected ways (e.g., one says `comment` and another says `approve` on the same file) → emit a `ConflictDecision@v1` for HITL.
