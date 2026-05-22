---
name: infra-kubernetes.write-manifest
description: |
  **Use when:** a ReleasePlan@v1 needs Kubernetes manifests (Deployment,
  Service, ConfigMap, PDB, HPA, Ingress) authored — typical for a new app
  ship, a workload migration, or a release-plan refresh. Triggers on:
  "/k8s-manifest", "write manifests", "deploy to k8s".
  **Do NOT use when:** the user wants a Helm chart (out of scope for this MVP;
  a separate `infra-helm` skillset can ship later), kustomize overlays
  (`infra-kustomize` candidate), or a non-K8s deployment target
  (`infra-ecs`, `infra-nomad`, etc.).
  **Inputs:** ReleasePlan@v1 with image, replicas, env, ports, scaling, exposure.
  **Outputs:** DeploymentManifest@v1 — multi-document YAML at
  `.agents/state/infra/infra-kubernetes/<release-id>/manifests.yaml`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeK8sManifest
bundle_contract_id: infra-kubernetes
visibility: public
---

# write-manifest

Author Kubernetes manifests for a ReleasePlan. Apply cortex.ai defaults for safety.

## Procedure

1. **Read the ReleasePlan.** Extract image+tag, replicas, env, ports, scaling, exposure, namespace target, resource hints.

2. **Verify cluster context.** Compose `connector-kubernetes`'s typed tools to confirm:
   - the target namespace exists and is on the expected Pod Security Standard profile,
   - the matching ServiceAccount exists (or surface that you need to author it — separate skill),
   - the cluster's API version (so you emit `apiVersion` strings that won't be rejected).

3. **Compose `methodology.read-code` inline** if any existing manifests in `.agents/state/infra/` reference this workload — inherit the project's conventions (labels, annotations, naming).

4. **Author the manifests.** Standard set: Deployment + Service + (optional ConfigMap | Secret reference | PDB | HPA | Ingress). For each:

   - **Deployment:** `replicas` (matches plan), `selector.matchLabels` ↔ `template.metadata.labels` (don't drift), `template.spec`:
     - `containers[]` with `image`, `ports`, `env`, `envFrom`,
     - **`resources.requests` and `resources.limits` ALWAYS set** (honest values, not lazy defaults),
     - **`livenessProbe` + `readinessProbe` ALWAYS set** for any multi-replica workload,
     - **`securityContext: { runAsNonRoot: true, allowPrivilegeEscalation: false, capabilities: { drop: [ALL] }, readOnlyRootFilesystem: true }`** unless the workload genuinely needs otherwise (then surface the rationale per `methodology.risk-assess`).
   - **Service:** `selector` matches Deployment labels, `type: ClusterIP` unless plan says otherwise, `ports` named (`name: http`).
   - **PDB:** `minAvailable` honoring the plan's HA expectations (`replicas - 1` for typical 3-replica apps).
   - **HPA:** only if scaling hints in the plan; CPU+memory-based by default; surface custom-metric advice when relevant.
   - **Ingress:** TLS cert reference (cert-manager or pre-issued); annotations per the cluster's ingress controller convention.

5. **Compose `methodology.risk-assess` inline** for any of:
   - cluster-scoped resources in the set (`ClusterRole`, `ClusterRoleBinding`, `CRD`) — these need checkpoint 12,
   - `securityContext.privileged: true` — needs documented justification,
   - `hostNetwork: true` / `hostPID: true` / `hostPath` volumes — needs checkpoint 12 + justification.

6. **Compose `methodology.verify` inline.** Validate the YAML parses, that labels match across docs, that no required fields are missing.

7. **Emit the DeploymentManifest** at `.agents/state/infra/infra-kubernetes/<release-id>/manifests.yaml` + the typed envelope at `manifests.json`.

8. **Announce.** "Wrote manifests for release-42: Deployment(3), Service(ClusterIP), PDB(minAvailable=2). PSS-restricted compatible."

## Hard rules

- **`resources.requests` ALWAYS set.** Honest values — not the lazy `100m/128Mi`. Reflect actual usage from observability (route via release-operate.observe to get the real numbers if available).
- **No `privileged: true`** without an approved HITL envelope and a documented justification.
- **No cluster-scoped resources** without checkpoint 12.
- **No `hostPath` volumes** in restricted-profile namespaces.
- **No `imagePullPolicy: Always` for stable tags.** Pin a digest or accept `IfNotPresent`.
- **No production-code edits.** This skill writes manifests, not application code.

## Failure handling

- ReleasePlan missing required fields (image, replicas) → refuse with `state: requires_human`.
- Target namespace unreachable via connector-kubernetes → refuse with the connector error.
- Cluster API version doesn't support the requested kind → refuse and surface the version diagnostic.

## Latency budget

p95 ≤ 45 s for a standard Deployment + Service + PDB set.

## References

Manifest idiom guidance lives in `${CLAUDE_PLUGIN_ROOT}/skills/write-manifest/references/`.
