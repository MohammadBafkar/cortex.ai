---
capability_interface_id: decomposeEpic
version: 1
bundle_contract_id: product-definition
schema_in: PRD@v1
schema_out: [EpicSpec@v1, UserStory@v1[]]
---

# decomposeEpic@v1

Decomposes an approved `PRD@v1` into one `EpicSpec@v1` + 2–8 `UserStory@v1` artifacts.

## Inputs

- `PRD@v1` (required) in state `approved`.

## Outputs

- `EpicSpec@v1` at `.agents/state/intakes/<epic-id>/product/epic.json`.
- `UserStory@v1[]` at `.agents/state/intakes/<epic-id>/product/stories/<n>.json`.

## Non-functional contract

- **Idempotency:** yes (same PRD + model).
- **Latency budget:** p95 ≤ 45 s for ≤ 6 stories.
- **Token budget:** ≤ 18K.
- **HITL:** none at decomposition; engineering's `/implement` later HITLs on the GA release.

## Failure modes

- > 8 stories per epic → refuse with "PRD too broad — narrow first" message.
- Story without acceptance criteria → refuse.
- Single-number estimate (no confidence band) → refuse — `methodology.estimate` defect.

## Fixtures

Golden: `decompose-prd-into-stories` (2-8 stories, all with AC + 3-point estimates).
Adversarial: `epic-with-15-stories` (scope overrun, refused).
