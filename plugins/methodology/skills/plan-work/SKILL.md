---
name: methodology.plan-work
description: |
  **Use when:** the user (or a capability skill composing inline) wants to decompose
  a goal into a small number of verifiable steps before executing. Triggers on:
  "plan this", "how should I approach", "what are the steps to", "/plan".

  **Do NOT use when:** the goal is already clear and small (just do it), the user
  wants ideation (use `methodology.brainstorm`), the user wants a written PRD
  (use `product.draft-prd`), or the goal needs domain risk analysis (use
  `methodology.risk-assess` at P1+).

  **Inputs:** a goal or task description.
  **Outputs:** ephemeral. Optionally write a plan note to
  `.agents/state/methodology/plan-work/<session>.md` for the orchestrator to
  carry forward.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# plan-work

Decompose a goal into **≤ 5 verifiable steps**. Each step states *what changes* and *how the change is verified*.

## Procedure

1. **Restate the goal** in one sentence.
2. **Decompose into ≤ 5 steps.** If the goal genuinely needs more, the right move is to narrow scope first, not to inflate the plan. Tell the user.
3. **Per step, write one line for "what" and one line for "how verified."** Verification examples: a passing test, a green build, a manual smoke check, a metric change.
4. **Flag risks** the plan does not cover (e.g., "this plan assumes the cache is empty at start; verify before step 3").
5. **Soft handoff:** suggest the next action — `/implement step 1`, refine the plan, or pick a different decomposition.

## Hard refusals

- **No more than 5 steps.** If the user demands more, refuse and propose narrowing scope.
- **No authoritative artifact writes.** The plan note under `.agents/state/methodology/plan-work/` is ephemeral; it is swept on SessionEnd unless a capability skill explicitly promotes it.

## Inline composition

Capability skills compose `plan-work` inline (e.g., `engineering.propose-pr` invokes it before authoring code). No subagent dispatch.

## Latency budget

- p95 ≤ 10 s per turn.
