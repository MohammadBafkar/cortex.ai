---
capability_interface_id: proposeTypeAnnotations
version: 1
bundle_contract_id: lang-python
schema_in: PullRequest@v1
schema_out: TypeAnnotationProposal@v1
---

# proposeTypeAnnotations@v1

Proposes type annotations for unannotated Python functions/methods. **Does not auto-apply** — emits a unified diff the engineer accepts or rejects.

## Inputs

- `PullRequest@v1` with Python diff.
- Project's mypy / pyright configuration (auto-detected).

## Outputs

- `TypeAnnotationProposal@v1` at `.agents/state/langs/lang-python/<pr-id>/types.json` with the proposal as a unified diff.

## Non-functional contract

- **Idempotency:** yes given the same diff + inference engine.
- **Latency budget:** p95 ≤ 30 s for ≤ 10 changed functions.
- **Token budget:** ≤ 10K.
- **HITL:** public-API annotation changes → mandatory ADR (per the hard rule). Internal-only annotations may auto-merge per project config.

## Failure modes

- Project policy is "untyped" (no mypy config or `strict = false`) → refuse with "honoring project policy" message.
- `Any` proposed as default → refuse; either narrow or escalate to HITL.
- Removing existing annotations without explicit user request → refuse.

## Fixtures

Golden: `type-annotations-propose`.
Adversarial: `types-py-narrows-public-api` (refused without ADR).
