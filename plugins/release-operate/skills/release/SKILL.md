---
name: release-operate.release
description: |
  **Use when:** a signed BuildArtifact@v1 is ready to roll out (staged, canary,
  or full). Triggers on: "/release", "ship this".

  **Do NOT use when:** the user wants only the build (`platform.run-pipeline`),
  to rollback (`/rollback`), or to apply IaC (`platform.apply-iac`).

  **Inputs:** BuildArtifact@v1 (signed).
  **Outputs:** ReleaseRecord@v1 + RolloutPlan@v1 at
  `.agents/state/releases/<id>/release-operate/`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: release
bundle_contract_id: release
visibility: public
---

# release

Orchestrate a staged rollout with explicit HITL gates per stage.

## Procedure

1. **Validate the artifact.** `signed: true`; signature verified.
2. **Build the RolloutPlan.** Stages: canary (1%) → expanded (25%) → full (100%). Each stage names: target population, monitoring window, automatic rollback triggers.
3. **Compose `methodology.risk-assess` inline.** What changes for users? What metrics drop?
4. **HITL: production GA release approval.** Checkpoint 1 (M-tier), `rbac/release-managers ∩ service owner`. The parent workflow executor holds the request open until decided.
5. **Execute stage by stage.** After each stage, observe the configured SLOs for the monitoring window. If any tripped, auto-rollback (or escalate to HITL if auto-rollback is disabled).
6. **Compose `methodology.verify` inline** before promoting the ReleaseRecord to `approved`.
7. **Write** ReleaseRecord with stage outcomes + DORA inputs (lead time, deploy time).

## Hard rules

- **No release without a signed artifact.**
- **No skipping HITL on prod GA.** Always M-tier checkpoint 1.
- **No release without a rollback plan.**
