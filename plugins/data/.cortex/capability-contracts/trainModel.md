---
capability_interface_id: trainModel
version: 1
bundle_contract_id: ml-ai
schema_in: DatasetRef@v1
schema_out: ModelCandidate@v1
---

# trainModel@v1

Trains a candidate model + emits a `ModelCard@v1`-equivalent embedded in the `ModelCandidate@v1`.

## Inputs

- `DatasetRef@v1` (required) — provenance + lawful basis verified at ingest.
- Training recipe (framework, hyperparameters, hardware).

## Outputs

- `ModelCandidate@v1` at `.agents/state/ml/<candidate-id>/data/candidate.json` with embedded model card using `platform/templates/model-card.md` shape.

## Non-functional contract

- **Idempotency:** stochastic (training has randomness); seeded runs are deterministic.
- **Latency budget:** training time is unbounded; the orchestration overhead p95 ≤ 60 s.
- **Token budget:** ≤ 8K (orchestration; not the training tokens themselves).
- **HITL:** dataset lacking lawful basis → refuse. AI Act high-risk classification → triggers `methodology.risk-assess` + escalation to ML lead.

## Failure modes

- Training on data without lawful basis → refuse.
- Model card missing fairness metrics for protected groups → refuse.
- No held-out test set → refuse.

## Fixtures

Golden: `train-model-fairness-required`.
Adversarial: `train-on-data-without-lawful-basis` (refused).
