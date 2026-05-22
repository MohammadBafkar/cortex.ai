---
name: marketplace.define-workflow
description: |
  **Use when:** a glue command (`/implement`, `/review`, `/refactor`, etc.) needs
  to validate or explain a workflow template before the parent executor runs it.

  **Do NOT use when:** the user wants to author code (`/implement` directly),
  run conformance (`/conformance`), or query the audit log (`/audit`).

  **Inputs:** workflow id (resolves to `${CLAUDE_PLUGIN_ROOT}/workflows/<id>.yaml`)
  and the per-workflow input bindings.
  **Outputs:** WorkflowRun@v1 written to `.agents/state/workflows/<run-id>/run.json`
  plus all per-state artifacts written by the dispatched workers.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: defineWorkflow
bundle_contract_id: orchestration-thin
visibility: public
---

# define-workflow

Load the named template, validate it, and return executable workflow structure
to the parent command.

## Procedure

1. **Resolve the template.** `${CLAUDE_PLUGIN_ROOT}/workflows/<id>.yaml`. Fail if the path resolves outside the plugin tree.
2. **Validate the template.** Required fields; referenced plugins admitted in the marketplace catalog; gate references valid; fanout_budget ≤ 4 unless explicitly overridden with documented justification.
3. **Initialize the run.** Write `.agents/state/workflows/<run-id>/run.json` with `state: running`, the inputs, and the full state sequence as `pending`.
4. **Plan state-by-state.** For each state in order:
   a. Verify the gate (required inputs exist, optionally at a particular envelope state).
   b. Resolve the named plugin skill or worker.
   c. Record the declared `writes` path.
   d. For `parallel_with` states, return a parallel group in the plan.
5. **HITL checkpoints.** When a state declares a checkpoint, write an `ApprovalRequest@v1` and pause until the workflow state is approved/denied/expired.
6. **Compensations.** On per-state failure, apply the compensation (skip / rollback / retry / escalate).
7. **Verify.** Invoke `methodology.verify` inline at the end to confirm the run satisfied the workflow's stated goal.
8. **Finalize.** Write final `WorkflowRun.state` ∈ {complete, failed, expired, cancelled}.

## Runtime constraints

This skill plans; it does not dispatch. The parent command or top-level agent
executes the returned plan. Worker subagents stay leaves.

## Cancellation + resumability

- On user cancel, mark the run `state: cancelled` and write `cancelled` envelopes to all in-flight subagent dispatches.
- `/resume <run-id>` reads the partial state and continues from the next pending state.
