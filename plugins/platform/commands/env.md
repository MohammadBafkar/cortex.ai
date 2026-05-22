---
name: env
description: |
  **Use when:** the user types `/env <action> [env-name]` to create, audit,
  or decommission an environment. Multi-env is the v1.1 headline.
  **Do NOT use when:** the user wants to apply IaC to an existing env (use
  `/apply`).
  **Inputs:** action (create | audit | decommission) + env-name.
  **Outputs:** EnvironmentRecord@v1.
argument-hint: "<create|audit|decommission> <env-name>"
allowed-tools: [Task, Read, Bash, Write]
---

# /env

Dispatch the platform manage-env skill.
