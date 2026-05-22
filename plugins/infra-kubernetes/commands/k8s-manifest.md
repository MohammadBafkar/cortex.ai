---
name: k8s-manifest
description: |
  **Use when:** `/k8s-manifest [release-id]` to author Kubernetes manifests
  for a ReleasePlan@v1.
  **Inputs:** release-id.
  **Outputs:** DeploymentManifest@v1.
argument-hint: "[release-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /k8s-manifest
Dispatch `k8s-manifest-author`.
