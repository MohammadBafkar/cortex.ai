---
name: infra-kubernetes.propose-pod-security-standards
description: |
  **Use when:** a DeploymentManifest@v1 needs a Pod Security Standard (PSS)
  profile decision (`privileged` / `baseline` / `restricted`) plus the
  manifest changes to compile clean against it. Triggers on: "/k8s-pss",
  "propose PSS", "tighten pod security".
  **Do NOT use when:** the namespace already has a labeled PSS profile and
  the manifest is clean (this skill becomes a no-op); enforcing PSS at admission
  (that's the cluster operator's PolicyAsCode job); applying the diff (this
  skill produces a proposal, not an apply).
  **Inputs:** DeploymentManifest@v1 + current namespace PSS labels (via connector-kubernetes).
  **Outputs:** PodSecurityProposal@v1 at
  `.agents/state/infra/infra-kubernetes/<artifact-id>/pss-proposal.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: proposePodSecurityStandards
bundle_contract_id: infra-kubernetes
visibility: public
---

# propose-pod-security-standards

Propose a Pod Security Standard profile + the manifest changes to satisfy it. Emit a proposal; do NOT apply.

## Procedure

1. **Read the current namespace PSS labels** via connector-kubernetes:
   - `pod-security.kubernetes.io/enforce`
   - `pod-security.kubernetes.io/audit`
   - `pod-security.kubernetes.io/warn`

2. **Read the DeploymentManifest's actual security posture:**
   - `runAsNonRoot`, `runAsUser`, `runAsGroup`
   - `allowPrivilegeEscalation`
   - `capabilities.add` / `capabilities.drop`
   - `readOnlyRootFilesystem`
   - `privileged`
   - `hostNetwork` / `hostPID` / `hostIPC`
   - `volumes[]` for `hostPath` usage
   - `seccompProfile.type`

3. **Classify the workload:**
   - **`restricted`-compatible:** non-root, no caps added, no host* fields, no hostPath, seccompProfile RuntimeDefault, allowPrivilegeEscalation: false, readOnlyRootFilesystem: true.
   - **`baseline`-compatible:** allows runAsRoot, allows allowPrivilegeEscalation, but no privileged / hostNetwork / hostPath.
   - **`privileged` required:** node-level operator, kernel-mode access, hostPath-mounted device, hostNetwork.

4. **Decide the proposed profile:** the strictest profile the manifest can satisfy without changing its function. If the workload truly needs `privileged`, surface the rationale + check that a documented justification exists.

5. **Compose `methodology.risk-assess` inline.** What can break if we tighten the profile? (e.g., setting `readOnlyRootFilesystem: true` breaks apps that write to `/tmp` without an `emptyDir` mount.)

6. **Author the proposal:**
   - `proposed_profile`: privileged | baseline | restricted
   - `namespace_label_diff`: the YAML diff for the namespace's PSS labels
   - `manifest_diff`: the unified diff for the manifest's securityContext + volumes
   - `justification_required` (boolean — true for `privileged`)
   - `risk_notes[]`

7. **Compose `methodology.verify` inline.**

8. **Emit the PodSecurityProposal** at `.agents/state/infra/infra-kubernetes/<artifact-id>/pss-proposal.json`.

## Hard rules

- **Proposing `privileged` requires a documented justification** present in the manifest's annotations (e.g., `cortex.security/privileged-justification: "node-level CSI driver"`) OR in the surrounding ReleasePlan@v1. Otherwise refuse with `state: failed`.
- **Never loosen a namespace already on `restricted`.** Going restricted → baseline → privileged is a downgrade and needs an ADR + checkpoint 12.
- **Never propose changes that don't compile.** Validate the diff against the Kubernetes API schema (via dry-run on the connector).
- **Never auto-apply.** This is a proposal skill.

## Failure handling

- Namespace PSS labels unreadable via connector-kubernetes → refuse with the connector error.
- Manifest references `hostPath` in a `restricted` profile → refuse, recommend an `emptyDir` or PVC-backed volume.
- Manifest writes to root filesystem at runtime (detected via `livenessProbe.exec` pattern of `touch /…`) and `readOnlyRootFilesystem` is being proposed `true` → flag as a risk note (the proposal still compiles; the workload may fail at runtime).
