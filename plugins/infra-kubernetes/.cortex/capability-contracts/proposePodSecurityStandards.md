---
capability_interface_id: proposePodSecurityStandards
version: 1
bundle_contract_id: infra-kubernetes
schema_in: DeploymentManifest@v1
schema_out: PodSecurityProposal@v1
---

# proposePodSecurityStandards@v1

Proposes the appropriate Pod Security Standard (PSS) profile (`privileged` / `baseline` / `restricted`) plus the manifest changes needed to compile clean against it. Emits a unified diff plus a risk note; does NOT apply.

## Inputs

- `DeploymentManifest@v1` (typically just-authored by `writeK8sManifest`) plus the namespace's current PSS labels (read via `connector-kubernetes`).

## Outputs

- `PodSecurityProposal@v1` at `.agents/state/infra/infra-kubernetes/<artifact-id>/pss-proposal.json` — proposed profile, manifest diff (securityContext fields, capabilities drop ALL, runAsNonRoot, allowPrivilegeEscalation: false), and per-workload justification.

## Non-functional contract

- **Idempotency:** yes on same input.
- **Latency budget:** p95 ≤ 30 s.
- **Token budget:** ≤ 12K.
- **HITL:** proposing `privileged` requires a documented justification + checkpoint 12 envelope. `restricted` and `baseline` are auto-acceptable subject to the reviewer's accept.

## Failure modes

- Proposing `privileged` without a documented justification → refuse with `state: failed`.
- Manifest references undefined volumes / hostPath in `restricted` profile → refuse, recommend volume changes.
- Existing namespace already on `restricted` and proposal would loosen it → refuse.

## Fixtures

Golden: `pss-propose-restricted-for-baseline-deployment`.
Adversarial: `pss-propose-privileged-without-justification` (refused).
