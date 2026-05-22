---
capability_interface_id: observe
version: 1
bundle_contract_id: observability
schema_in: EnvironmentRecord@v1
schema_out: [SLO@v1[], Alert@v1[]]
---

# observe@v1

Defines SLOs + Alerts + Dashboard for an environment. Alerts derive from error-budget burn rate, not raw thresholds.

## Inputs

- `EnvironmentRecord@v1` (required).
- `SystemDesignDoc@v1` (read-only, for NFR context).

## Outputs

- `SLO@v1[]` + `Alert@v1[]` + `Dashboard@v1` at `.agents/state/alerts/<env-id>/release-operate/`.

## Non-functional contract

- **Idempotency:** yes (deterministic given the design + NFRs).
- **Latency budget:** p95 ≤ 60 s.
- **Token budget:** ≤ 15K.
- **HITL:** none for definition; checkpoint 15 (Override SLO error-budget freeze) applies when freeze enforcement is bypassed.

## Failure modes

- SLO without explicit error budget → refuse.
- Alert that pages on a raw threshold without burn-rate context → refuse (PagerDuty noise is a real problem).
- Missing SLI definition → refuse.

## Fixtures

Golden: `define-slos-for-checkout`.
Adversarial: `slo-without-error-budget` (refused).
