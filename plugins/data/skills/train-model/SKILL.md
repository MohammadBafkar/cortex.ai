---
name: data.train-model
description: |
  **Use when:** a labeled DatasetRef is available and the team wants a model
  candidate trained per the named recipe.
  **Do NOT use when:** the user wants promotion to prod (`promote-model`),
  experimentation (`run-experiment`), or pipeline definition
  (`define-pipeline`).
  **Inputs:** DatasetRef@v1 + training recipe.
  **Outputs:** ModelCandidate@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: trainModel
bundle_contract_id: ml-ai
visibility: public
---

# train-model

Train a candidate model + emit a ModelCard for the candidate.

## Procedure

1. **Verify dataset provenance** + applicable PIA. Refuse training on data
   without lawful basis or with an unresolved EthicsReview flag.
2. **Train** per the recipe (framework, hyperparameters, hardware).
3. **Evaluate** on the held-out test set. Required metrics: primary (e.g.,
   accuracy), fairness across declared protected groups, calibration.
4. **Author the ModelCard** — intended use, training data summary, evaluation
   results, ethical considerations.
5. **Compose `methodology.risk-assess` inline** on the fairness metrics.
6. **Compose `methodology.verify` inline.**
7. **Write** the ModelCandidate envelope (state=`proposed`).

## Hard rules

- **No training without lawful basis** on the data.
- **Fairness metrics mandatory** when protected attributes are in scope.
- **ModelCard is non-negotiable.**

## Template

Use the canonical template at `${CORTEX_HOME}/platform/templates/model-card.md`. Remove the template's authoring-comment block before promotion. Conformance fixtures assert on the template's required headings.
