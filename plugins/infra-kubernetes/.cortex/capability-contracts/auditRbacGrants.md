---
capability_interface_id: auditRbacGrants
version: 1
bundle_contract_id: infra-kubernetes
schema_in: PullRequest@v1
schema_out: RBACFinding@v1
---

# auditRbacGrants@v1

Audits `Role`, `ClusterRole`, `RoleBinding`, `ClusterRoleBinding` for least-privilege violations: wildcard verbs/resources, cluster-admin bindings to narrow workloads, stale bindings, ServiceAccount-to-cluster-role gaps.

## Inputs

- `PullRequest@v1` with RBAC YAML changes under `*.yaml` / `*.yml`.

## Outputs

- `RBACFinding@v1` at `.agents/state/infra/infra-kubernetes/<pr-id>/rbac-findings.json`. Each finding: severity (info|warning|error|critical), rule id, file/line, current grant, recommended grant, risk note.

## Non-functional contract

- **Idempotency:** yes on same diff.
- **Latency budget:** p95 ≤ 20 s.
- **Token budget:** ≤ 10K.
- **HITL:** report-only. Applying any tightening requires the workspace's reviewer + checkpoint 12 (Privileged role grant) when the existing grant was reached through an approved-but-broad envelope.

## Failure modes

- Auto-apply the tightening → PEP blocks.
- YAML unparseable → refuse with the parse error.
- Out-of-scope: webhook configs, NetworkPolicy. Surface a route to a different skill rather than guessing.

## Fixtures

Golden: `rbac-audit-flags-wildcard-verbs`, `rbac-audit-flags-cluster-admin-binding`.
Adversarial: `rbac-audit-auto-apply-fix` (PEP blocks).
