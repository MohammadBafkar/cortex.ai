---
name: platform.apply-iac
description: |
  **Use when:** an IaCPlan@v1 has been authored and reviewed and needs to be
  applied to a single environment. MVP1 is one-env only — full multi-env +
  Resilience/DR lands in `platform v1.1` at P1. Triggers on: "/apply",
  "apply this terraform plan", "deploy IaC to dev".

  **Do NOT use when:** the user wants to write the plan (authored at P1 — MVP1
  accepts a hand-authored plan in the workspace), run CI (use `run-pipeline`),
  or do a full release with traffic shifting (use `release-operate.release` at P1).

  **Inputs:** IaCPlan@v1 reference at `.agents/state/runs/<id>/platform/plan.json`,
  target environment.
  **Outputs:** DeploymentRecord@v1 at `.agents/state/runs/<run-id>/platform/deploy.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: applyIaC
bundle_contract_id: platform-lite
visibility: public
---

# apply-iac

You are the infrastructure applier. **This capability is irreversible** — every apply requires HITL approval per GOVERNANCE.md checkpoint 8 (M-tier).

## Procedure

1. **Load the plan.** Read `.agents/state/runs/<id>/platform/plan.json`. Verify the envelope's `state == proposed`.
2. **Display the diff.** Render the plan in a human-readable form — show every resource that will be created, modified, or destroyed.
3. **Verify.** Invoke `methodology.verify` inline to confirm the plan matches the stated intent and that destructive operations (delete) are intentional.
4. **Request HITL.** Write an `ApprovalRequest@v1` to `.agents/state/markers/approvals/apply-<run-id>.json` with `checkpoint_id: 8`, `checkpoint_tier: M`. The parent workflow executor surfaces the prompt; SLA 1 BD; fallback `deny`.
5. **On approval, execute.** Invoke the provider CLI (terraform apply, kubectl apply, etc.). Stream output to telemetry.
6. **Write the DeploymentRecord.** Outcome + resource changes + duration. Promote to CAS on SessionEnd.
7. **On any failure, refuse to auto-rollback.** Mark `state: failed` and surface to HITL — rollback requires a fresh checkpoint 8 approval on the inverse plan.

## Hard guarantees

- **No idempotency.** This capability is explicitly NOT idempotent; re-runs may have side effects.
- **No silent destruction.** Any `destroy` in the plan that wasn't shown in step 2 fails the verify in step 3.
- **No multi-env in MVP1.** Apply targets exactly one env per invocation.
