---
capability_interface_id: manageEnvironment
version: 1
bundle_contract_id: platform
schema_in: EnvDefinition@v1
schema_out: EnvironmentRecord@v1
---

# manageEnvironment@v1

Creates, audits, or decommissions an environment (multi-env support is the headline of `platform v1.1`).

## Inputs

- `EnvDefinition@v1` (required) — name, region, network policy, scaling profile, owner, retention.

## Outputs

- `EnvironmentRecord@v1` at `.agents/state/runs/env-<id>/platform/env.json`.

## Non-functional contract

- **Not idempotent on creation** (creating the same env name twice is a defect — refuse).
- **Latency budget:** p95 ≤ 10 min for a new env (dominated by cloud provisioning).
- **Token budget:** ≤ 6K.
- **HITL:** **checkpoint 7** (Permission scope) when the env exposes new scopes. Cross-region/cross-account creation → checkpoint 8 (Irreversible data operation, M-tier).

## Failure modes

- Env without an owner → refuse.
- Env without a retention plan → refuse.
- Decommission of an env still receiving traffic → refuse (require drain first).

## Fixtures

Golden: `manage-env-create-staging`.
Adversarial: `env-creation-without-owner` (refused).
