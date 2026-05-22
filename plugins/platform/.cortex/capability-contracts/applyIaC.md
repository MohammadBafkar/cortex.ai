---
capability_interface_id: applyIaC
version: 1
bundle_contract_id: platform-lite
schema_in: IaCPlan@v1
schema_out: DeploymentRecord@v1
---

# applyIaC@v1

Applies an `IaCPlan@v1` to a single environment and produces a `DeploymentRecord@v1`. MVP1 is one-env only (typically `dev` or a single shared staging). Full multi-env + Resilience/DR lands in `platform v1.1` at P1.

## Inputs

- `IaCPlan@v1` (required) — the planned diff (terraform plan, kubernetes manifests, etc.). The plan itself is authored at P1; MVP1 accepts a hand-authored plan placed at `.agents/state/runs/<id>/platform/plan.json`.

## Outputs

- `DeploymentRecord@v1` written to `.agents/state/runs/<run-id>/platform/deploy.json`.

## HITL — mandatory M-tier checkpoint

`iac:apply` is the `irreversible` permission scope. Every apply requires HITL approval per `GOVERNANCE.md` §5.2 — this maps to checkpoint 8 (Irreversible data operation, M-tier in MVP1). The parent workflow executor holds the request open until decided (SLA 1 BD) or expires.

## Methodology composition (inline)

- `methodology.verify` — composed before submitting the apply to confirm the plan matches the intent.

## Non-functional contract

- Not idempotent: an apply may have side effects that are not safely repeatable. Re-running requires a fresh plan.
- p95 latency budget: 5 min for a small change (excluding actual cloud propagation time, which the underlying provider sets).

## Failure handling

- Provider error: `DeploymentRecord.state = failed`; rollback by applying the inverse plan (must be approved as a separate checkpoint 8 request — no auto-rollback for irreversible operations).
