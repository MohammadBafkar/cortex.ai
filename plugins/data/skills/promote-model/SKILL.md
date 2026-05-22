---
name: data.promote-model
description: |
  **Use when:** a ModelCandidate@v1 passes evaluation + ethics review and
  needs promotion to prod. **Irreversible** — requires two-person HITL
  (checkpoint 11, AI/ML model promotion to prod).
  **Do NOT use when:** still in development (use `train-model`), or running
  A/B tests against existing prod (use `run-experiment`).
  **Inputs:** ModelCandidate@v1.
  **Outputs:** ModelRecord@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: promoteModel
bundle_contract_id: ml-ai
visibility: public
---

# promote-model

Promote a ModelCandidate to prod with full audit trail.

## Procedure

1. **Verify** the candidate passed: evaluation, EthicsReview (if AI Act
   high-risk), security review, FairnessMetricsReport.
2. **Compose `methodology.risk-assess` inline** on production impact.
3. **HITL** per checkpoint 11 — `rbac/ml-leads ∩ rbac/ai-ethics-reviewers`,
   M-tier (when activated).
4. **Promote** via the registry (mlflow / vertex / sagemaker).
5. **Compose `methodology.verify` inline.**
6. **Write** ModelRecord with serving endpoint + monitoring plan.
7. **Notify** `release-operate.observe` to define SLOs around the model.

## Hard rules

- **No promotion without passing EthicsReview when AI Act high-risk.**
- **Mandatory two-person HITL.**
- **Rollback plan documented** — high-risk models always have a fallback.
