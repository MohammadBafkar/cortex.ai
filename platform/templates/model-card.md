<!--
Template: Model Card (Mitchell et al. 2019 + EU AI Act §13 alignment).
Authored by: data.train-model. Required for every ModelCandidate.
Required: intended use, training data summary, evaluation, ethical considerations,
fairness metrics across declared protected groups.
Remove this block before promotion.
-->

# Model Card: <model-name> v<version>

- **Owner:** <data team>
- **Date:** <YYYY-MM-DD>
- **ModelCandidate id:** <MC-id>
- **EU AI Act risk class:** <minimal | limited | high | prohibited>
- **EthicsReview id:** <ER-id — required for high-risk>

## Intended Use

- **Primary use case:** <one sentence>
- **Intended users:** <who calls this model>
- **In scope:** <bullets>
- **Out of scope:** <bullets — what this model should NOT be used for>

## Model Details

- **Type:** <e.g., gradient-boosted classifier | transformer LM | logistic regression>
- **Inputs:** <feature names + types>
- **Outputs:** <prediction shape>
- **Framework:** <PyTorch / scikit / XGBoost / ...>
- **Training compute:** <e.g., 8 × A100, 6h>
- **License:** <e.g., proprietary / Apache 2.0 if base model is OSS>

## Training Data

- **DatasetRef:** <DS-id>
- **Provenance:** <where the data came from + lawful basis>
- **Size:** <records>
- **Split:** <train / val / test ratios>
- **Class balance:** <distribution>
- **Known biases / gaps:** <named>

## Evaluation

| Metric | Value | Target | Held-out set |
| --- | --- | --- | --- |
| <primary> | <e.g., AUC 0.91> | <≥ 0.88> | <set name> |
| <calibration> | <ECE 0.04> | <≤ 0.05> | <set name> |
| <secondary> | ... | ... | ... |

### Fairness — per protected group

<Mandatory when protected attributes are in scope. Report each metric per
group + the disparity vs the overall.>

| Group | <primary metric> | Disparity | Action |
| --- | --- | --- | --- |
| <group A> | <value> | <vs overall> | <accept / mitigate> |
| <group B> | <value> | <vs overall> | <accept / mitigate> |

## Ethical Considerations

- **Harms surfaced by `methodology.risk-assess`:** <list>
- **Mitigations:**
  - **Human oversight:** <when humans review predictions>
  - **Transparency to end users:** <how affected users are informed>
  - **Opt-out / recourse:** <mechanism>
  - **Monitoring in production:** <drift detection, fairness re-check cadence>

## Deployment

- **Serving endpoint:** <URL or service>
- **Rollback model:** <prior version id>
- **Promotion plan:** staged via `release-operate.release`; HITL per checkpoint 11.
- **Monitoring SLOs:** <linked from `release-operate.observe`>

## References

- ResearchNotes: <link>
- PIA: <id if applicable>
- EthicsReview: <ER-id if high-risk>
- Prior versions: <list>
