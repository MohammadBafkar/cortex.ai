---
name: ts-migrate
description: |
  **Use when:** `/ts-migrate [pr-id]` to propose a TypeScript compiler version
  migration as a unified diff.
  **Inputs:** pr-id with the target version in the PR description or package.json change.
  **Outputs:** VersionMigrationProposal@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---
# /ts-migrate
Apply `lang-typescript.migrate-ts-version`.
