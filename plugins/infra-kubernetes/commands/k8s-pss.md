---
name: k8s-pss
description: |
  **Use when:** `/k8s-pss [artifact-id]` to propose a Pod Security Standard
  profile + the manifest changes to satisfy it.
  **Inputs:** artifact-id of a DeploymentManifest@v1.
  **Outputs:** PodSecurityProposal@v1.
argument-hint: "[artifact-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /k8s-pss
Apply `infra-kubernetes.propose-pod-security-standards`.
