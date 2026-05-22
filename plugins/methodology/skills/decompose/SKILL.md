---
name: methodology.decompose
description: |
  **Use when:** a problem is genuinely complex and needs to be broken into
  parts before any single part can be approached. Typically composed inline
  by `engineering.propose-adr`, `architecture.design-system` (P1), or
  `product.draft-prd` (P1).

  **Do NOT use when:** the goal is small and clear (just do it), the user
  wants ideation (use `methodology.brainstorm`), or step-by-step planning
  (use `methodology.plan-work`).

  **Inputs:** a problem statement.
  **Outputs:** ephemeral. A decomposition into 2-5 sub-problems with explicit
  boundaries and dependency edges between them.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# decompose

Break a problem into 2-5 sub-problems with explicit *interfaces* between them. A good decomposition has weak coupling: each sub-problem can be solved with limited knowledge of the others.

## Procedure

1. **State the problem** in one sentence.
2. **Propose 2-5 sub-problems.** Each is a noun phrase ("authentication layer", "rate limiter", "audit emitter"), not a verb ("implement auth").
3. **Define the interface between each pair.** What does sub-problem A *give* sub-problem B? What invariants hold across the boundary?
4. **Check coupling.** If a sub-problem can't be designed without knowing the internal shape of another, the decomposition is wrong — collapse them or re-cut.
5. **Order the sub-problems.** What can be done in parallel? What has hard dependencies?

## Hard rules

- **No more than 5 sub-problems.** More means the problem isn't decomposed; it's chopped.
- **No artifact writes.**
- **One round of decomposition.** Don't recurse — sub-problems can be re-decomposed in a separate `methodology.decompose` invocation later.

## Latency budget

p95 ≤ 15 s.
