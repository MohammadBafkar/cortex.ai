---
name: k8s-rbac-audit
description: |
  **Use when:** `/k8s-rbac-audit [pr-id]` to audit Kubernetes RBAC YAML for
  least-privilege violations.
  **Inputs:** pr-id.
  **Outputs:** RBACFinding@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /k8s-rbac-audit
Dispatch `k8s-rbac-auditor`.
