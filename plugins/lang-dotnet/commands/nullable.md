---
name: nullable
description: |
  **Use when:** `/nullable [pr-id]` to propose Nullable Reference Types
  rollout for a C# project. Emits a unified diff; does NOT apply.
  **Inputs:** pr-id.
  **Outputs:** NullabilityProposal@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /nullable
Apply `lang-dotnet.propose-nullable-references`.
