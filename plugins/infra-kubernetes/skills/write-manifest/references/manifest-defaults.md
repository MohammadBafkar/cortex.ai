# K8s manifest defaults reference

Quick reference for the cortex.ai-default fields that `infra-kubernetes.write-manifest` should always populate.

## Always-set fields

| Field | Default | Why |
| --- | --- | --- |
| `metadata.labels.app.kubernetes.io/name` | workload name | discovery, service-mesh routing |
| `metadata.labels.app.kubernetes.io/version` | image tag (semver if available) | rollout debugging |
| `metadata.labels.app.kubernetes.io/managed-by` | "cortex" | telemetry, ownership |
| `spec.template.spec.containers[].resources.requests` | honest values from observability | cluster scheduling fairness |
| `spec.template.spec.containers[].resources.limits` | requests × 2 (CPU), requests × 1.5 (mem) as a starter | OOM protection |
| `spec.template.spec.containers[].livenessProbe` | HTTP `/livez` or TCP on the primary port | crash recovery |
| `spec.template.spec.containers[].readinessProbe` | HTTP `/readyz` or TCP | rollout safety |
| `spec.template.spec.securityContext.runAsNonRoot` | `true` | least privilege |
| `spec.template.spec.containers[].securityContext.allowPrivilegeEscalation` | `false` | least privilege |
| `spec.template.spec.containers[].securityContext.capabilities.drop` | `["ALL"]` | least privilege |
| `spec.template.spec.containers[].securityContext.readOnlyRootFilesystem` | `true` | tamper resistance |

## Selector ↔ label invariant

`spec.selector.matchLabels` in Deployment MUST match `spec.template.metadata.labels`.
`spec.selector` in Service MUST match Deployment's `spec.template.metadata.labels`.
Drift here causes 0-pod rollouts (silent).

## PDB sizing

| Replicas | minAvailable |
| --- | --- |
| 1 | (no PDB — would block all evictions) |
| 2 | 1 |
| 3 | 2 |
| 4+ | `replicas - 1` or `maxUnavailable: 1` |

## What NOT to do

- `imagePullPolicy: Always` for a stable semver tag — pulls on every restart.
- `replicas: 1` for any prod workload (no PDB possible).
- `resources.limits` without `resources.requests` — limits without requests give the workload `BestEffort` QoS class.
- `hostNetwork: true` outside of explicitly-justified network agents.
- `privileged: true` outside of explicitly-justified node-level operators.
- Wildcard `selector.matchLabels: {}` — matches everything; never intended.
