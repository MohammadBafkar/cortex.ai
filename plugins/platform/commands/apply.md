---
name: apply
description: |
  **Use when:** the user types `/apply [plan-id]` to apply an IaCPlan to a
  single environment. Requires HITL approval (M-tier checkpoint 8).
  **Do NOT use when:** the user wants to plan / preview (use `terraform plan`
  directly outside the agent), do a full release with traffic shifting (use
  `release-operate.release` at P1), or operate on multiple environments
  (multi-env lands in `platform v1.1`).
  **Inputs:** plan-id resolving to `.agents/state/runs/<id>/platform/plan.json`.
  **Outputs:** DeploymentRecord@v1 at `.agents/state/runs/<run-id>/platform/deploy.json`.
argument-hint: "<plan-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /apply

Apply the procedure in `platform.apply-iac`. Read the plan, display the diff, request HITL (checkpoint 8 — M-tier), execute on approval, write the DeploymentRecord. **Irreversible — no auto-rollback.**
