---
name: platform.manage-env
description: |
  **Use when:** the team needs to create, decommission, or audit an
  environment definition (env metadata, network policies, region, scaling).
  Multi-env support (vs MVP1's one-env-only) is the headline of platform v1.1.

  **Do NOT use when:** the user wants to apply IaC to an existing env (use
  `apply-iac`), run a pipeline (`run-pipeline`), or do a DR drill (`run-dr-drill`).

  **Inputs:** EnvDefinition@v1.
  **Outputs:** EnvironmentRecord@v1 at
  `.agents/state/runs/env-<id>/platform/env.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: manageEnvironment
bundle_contract_id: platform
visibility: public
---

# manage-env

Manage env lifecycle. Each env has: name, region, network policy, scaling profile, owner, retention.

## Procedure

1. **Validate** the EnvDefinition against the IaC plan it implies.
2. **Compose `methodology.risk-assess` inline** — env creation has multi-cloud blast radius.
3. **HITL** per checkpoint 7 (Permission scope grant, C-tier) when env exposes new permission scopes.
4. **Apply** via the configured IaC tool.
5. **Write** the EnvironmentRecord.

## Hard rules

- **No env without an owner.**
- **No env without a retention plan.**
- **Cross-region or cross-account creation requires checkpoint 8 (M-tier).**
