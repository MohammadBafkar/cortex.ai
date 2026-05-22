---
name: product.measure-adoption
description: |
  **Use when:** a feature has shipped (ReleaseRecord@v1 exists) and the product
  team needs to read the adoption metrics named in the PRD against actuals.
  Triggers on: "/measure", "what's the adoption of feature X?".

  **Do NOT use when:** the user wants a PRD (use `draft-prd`), incident
  retrospective (use `release-operate.postmortem` at P1), or perf review
  (use `quality.benchmark` at P1).

  **Inputs:** ReleaseRecord@v1 + the PRD@v1 it ships.
  **Outputs:** AdoptionReport@v1 at
  `.agents/state/roadmaps/<feature-id>/product/adoption.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: measureAdoption
bundle_contract_id: delivery
visibility: public
---

# measure-adoption

Compare the PRD's named success metrics against actual production usage.

## Procedure

1. **Load** the ReleaseRecord and the PRD it ships.
2. **Resolve metric definitions.** Each PRD success metric names: metric name, threshold, measurement window. Query observability for the actuals (P1+ via `release-operate` connector; MVP slice accepts hand-fed numbers).
3. **Compute** met / unmet / partial per metric.
4. **Author the report.** Sections: feature name, release version, metric-by-metric outcome, notable behavior changes, recommendation (continue / pivot / kill).
5. **Compose `methodology.verify` inline** to confirm conclusions are grounded in the actual numbers, not vibes.
6. **Write.** `.agents/state/roadmaps/<feature-id>/product/adoption.json`.

## Hard rules

- **No metric without an actual.** "Engagement looked good" is not a measurement.
- **No recommendation without supporting evidence.** Continue/pivot/kill cites which metrics drove the call.
