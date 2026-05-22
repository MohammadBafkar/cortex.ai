---
name: infra-kubernetes.audit-rbac-grants
description: |
  **Use when:** a PR touches `Role`, `ClusterRole`, `RoleBinding`,
  `ClusterRoleBinding` YAML and the team wants a least-privilege audit.
  Triggers on: "/k8s-rbac-audit", "audit RBAC", "check K8s permissions".
  **Do NOT use when:** auditing NetworkPolicy (out of scope), webhook configs
  (`infra-kubernetes.audit-webhooks` candidate), or applying tightening
  (this is a report-only skill).
  **Inputs:** PullRequest@v1 with RBAC YAML changes.
  **Outputs:** RBACFinding@v1 at
  `.agents/state/infra/infra-kubernetes/<pr-id>/rbac-findings.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: auditRbacGrants
bundle_contract_id: infra-kubernetes
visibility: public
---

# audit-rbac-grants

Audit Kubernetes RBAC YAML for least-privilege violations. Produce findings; do NOT apply.

## Procedure

1. **Parse the YAML.** If parsing fails, refuse with the parse error verbatim.

2. **For each Role / ClusterRole:** check `rules[].verbs` and `rules[].resources`:
   - `verbs: ["*"]` → `severity: error`, "enumerate verbs explicitly (get, list, watch, create, …) rather than wildcard".
   - `resources: ["*"]` → `severity: error`, "enumerate resources rather than wildcard".
   - `verbs: ["create", "delete", "deletecollection"]` granted to a non-controller SA → `severity: warning`, "broad write surface; consider scoping".
   - `nonResourceURLs: ["*"]` → `severity: error`.
   - `apiGroups: [""]` paired with secret access (`secrets`) granted broadly → `severity: critical`, "secrets are credential material; scope by name with `resourceNames`".

3. **For each RoleBinding / ClusterRoleBinding:** check `roleRef` + `subjects[]`:
   - Binding to `cluster-admin` for a ServiceAccount that controls a single namespace → `severity: critical`, "use a namespace-scoped Role instead".
   - Binding to a built-in `system:*` ClusterRole from a user-defined SA → `severity: warning`, "consider authoring a tailored Role".
   - Binding to a Role/ClusterRole that doesn't exist in the diff or in the cluster → `severity: error`, "broken reference".
   - Subjects referencing a user/group that doesn't exist in the IAM directory → `severity: warning`.

4. **Compose `methodology.risk-assess` inline** for each high-severity finding — what's the blast radius if this grant is exploited?

5. **Compose `methodology.verify` inline.**

6. **Emit the RBACFinding** at `.agents/state/infra/infra-kubernetes/<pr-id>/rbac-findings.json`. Each finding:
   - `severity`, `rule_id`, `file`, `line`, `current_grant`, `recommended_grant`, `risk_note`, `requires_hitl` (boolean — true when the underlying grant was approved via HITL).

7. **Announce.** "Audited 4 RBAC docs in PR-12: 2 critical (cluster-admin to narrow SAs), 1 error (wildcard verbs), 1 info."

## Hard rules

- **Never apply the tightening directly.** This skill is report-only. Auto-apply attempts → PEP blocks.
- **Don't recommend further-relaxing grants.** If a finding shows a grant is broad, "leave it" is acceptable; "make it broader" is not.
- **Don't normalize YAML formatting** as part of the report — cosmetic churn dilutes signal.
- **Don't recommend rotating service-account tokens** here — that's `security.rotate-credentials`'s job. Route to it.

## Failure handling

- YAML unparseable → refuse with the parse error.
- The cluster's IAM directory (for subject-existence checks) unreachable → emit findings with `subjects_unverified: true` rather than failing.
