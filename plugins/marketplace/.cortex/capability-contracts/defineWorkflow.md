---
capability_interface_id: defineWorkflow
version: 1
bundle_contract_id: orchestration-thin
schema_in: WorkflowSpec@v1
schema_out: WorkflowTemplate@v1
---

# defineWorkflow@v1

Loads and validates a `WorkflowTemplate@v1` from
`${CLAUDE_PLUGIN_ROOT}/workflows/<id>.yaml`. The marketplace plugin owns the
workflow catalog because workflows must live inside the plugin directory to
survive `claude /plugin install`.

## Inputs

- `WorkflowSpec@v1` — either an id (resolving to `workflows/<id>.yaml`) or an inline spec.

## Outputs

- `WorkflowTemplate@v1` (the validated, parsed template). The parent executor
  may later write a `WorkflowRun@v1` record at
  `.agents/state/workflows/<run-id>/run.json`.

## Workflow YAML shape

See `plugins/marketplace/workflows/shipFeature.yaml` for the canonical example. Each workflow declares:

- `id`, `version`
- `inputs[]` — typed inputs with required/optional + defaults
- `states[]` — sequence of orchestration states. Each state names a `plugin`, `skill`, optional `gate` (required inputs / artifact states), and a `writes` path template.
- `hitl_checkpoints[]` — checkpoint id (from GOVERNANCE.md) and SLA.
- `compensations[]` — what to do on a per-state failure.
- `fanout_budget` — max parallel subagents dispatched by this workflow.
- `parallel_writes` — boolean; true requires git worktree isolation per writer (see SPEC.md).

## Procedure

1. **Load.** Resolve `workflows/<id>.yaml` relative to `${CLAUDE_PLUGIN_ROOT}`. Fail if the file isn't inside the plugin tree (workflows shipped outside the plugin would be unreachable after install).
2. **Validate.** Required fields present; every plugin/skill referenced is admitted; gate references valid; fanout_budget honored.
3. **Plan state-by-state.** For each state, resolve the named plugin skill or
   worker and record its gate inputs and declared `writes` path.
4. **Represent parallelism.** For parallel states, return a parallel group. The
   parent executor decides how to dispatch leaf workers.
5. **HITL surface.** When a state declares a checkpoint, include the approval
   requirement in the plan. The parent executor writes the `ApprovalRequest@v1`.
6. **Compensations on failure.** Return the per-state compensation policy
   (rollback, skip, retry, escalate).
7. **Final.** Return the validated execution structure to the parent.

## Cancellation + resumability

- The parent executor writes `WorkflowRun.state` at every transition
  (`running`, `awaiting_hitl`, `cancelled`, `expired`, `complete`).
- `/resume <run-id>` reads the partial state and runs the next pending state.
- HITL approvals that expire become `state: expired`; the workflow does NOT auto-approve.

## Runtime constraints

This capability plans; it does not dispatch. Worker subagents remain leaves.
