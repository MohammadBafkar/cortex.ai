---
name: marketplace.route
description: |
  **Use when:** the user gives an open prompt, names a goal without naming a
  command, or the agent needs help selecting the right Cortex skill, command,
  workflow, connector, or external skill catalog.

  **Do NOT use when:** the user already selected a precise command/skill and the
  next step is obvious; a worker subagent is already executing a bounded leaf
  task; or the task is only to query audit/conformance directly.

  **Inputs:** user prompt, optional repo context, installed plugin list, admitted
  skill/command summaries.
  **Outputs:** RoutePlan@v1 rendered to chat or written by the parent executor.
type: capability
produces_authoritative_artifacts: false
capability_interface_id: routePrompt
bundle_contract_id: marketplace-routing
visibility: public
---

# route

Select the smallest sufficient Cortex path for a user request.

## Procedure

1. Classify the request: implement, review, test, audit, conformance, install,
   clarify, research, or unsupported.
2. Prefer explicit user intent over automatic routing. If the user named a
   command or skill, preserve that choice unless it is unsafe or impossible.
3. Check installed capabilities before selecting a path. If a first-party Cortex
   plugin is missing, either degrade to a smaller route or propose installation.
4. Prefer external language/framework skills over first-party language plugins
   when those catalogs are installed and sufficient.
5. Return a `RoutePlan` with:
   - `intent`
   - `entrypoint`
   - ordered `steps`
   - parallel groups, if any
   - required connectors
   - required human gates
   - degraded behavior, if any
6. Do not dispatch workers. The parent command or top-level agent executes the
   plan.

## Routing Rules

- Feature delivery -> `/implement` or `shipFeature`.
- Pull request review -> `/review` or `reviewPR`.
- Test-only work -> `quality.write-unit-test` or an external language test skill.
- CI/build status -> `platform.run-pipeline` or `connector-github-actions`.
- Plugin admission -> `/conformance`.
- Audit/history -> `/audit` or `/cortex-trace`.
- Ambiguous work -> ask one clarifying question before routing.

