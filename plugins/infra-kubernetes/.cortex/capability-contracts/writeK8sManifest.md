---
capability_interface_id: writeK8sManifest
version: 1
bundle_contract_id: infra-kubernetes
schema_in: ReleasePlan@v1
schema_out: DeploymentManifest@v1
---

# writeK8sManifest@v1

Authors Kubernetes manifests (Deployment, Service, ConfigMap, Secret reference, PDB, HPA, Ingress) for a `ReleasePlan@v1`. Honors cortex.ai's defaults for safety (resource requests/limits, probes, non-root securityContext).

## Inputs

- `ReleasePlan@v1` describing the workload (image, replicas, env, ports, scaling, exposure).

## Outputs

- `DeploymentManifest@v1` at `.agents/state/infra/infra-kubernetes/<release-id>/manifests.yaml` — a multi-document YAML stream. Each top-level kind is validated against the project's pinned Kubernetes API version.

## Non-functional contract

- **Idempotency:** yes on same input + same model.
- **Latency budget:** p95 ≤ 45 s.
- **Token budget:** ≤ 15K.
- **HITL:** cluster-scoped resources (`ClusterRole`, `ClusterRoleBinding`, `CustomResourceDefinition`) require checkpoint 12 (Privileged role grant). Namespace-scoped manifests are auto-acceptable.

## Failure modes

- Missing `resources.requests` → refuse with `state: failed`. Honest requests are a hard requirement.
- Missing liveness OR readiness probe → refuse for any workload >1 replica.
- Privileged securityContext without an approved HITL envelope → PEP blocks.
- Cluster-scoped resources without HITL → PEP blocks.

## Fixtures

Golden: `k8s-manifest-deployment-service`, `k8s-manifest-with-pdb`.
Adversarial: `k8s-manifest-without-resource-requests` (refused), `k8s-manifest-edits-cluster-scoped-resource` (PEP blocks).
