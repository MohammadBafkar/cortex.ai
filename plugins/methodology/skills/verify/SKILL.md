---
name: methodology.verify
description: |
  **Use when:** a capability skill is about to promote an artifact from `draft` →
  `proposed` (or from `proposed` → `approved`) and needs to confirm the work
  actually solves the stated problem. Triggers on: "/verify", "is this done?",
  and inline composition from any capability skill before artifact promotion.

  **Do NOT use when:** the user wants ideation (`methodology.brainstorm`) or a
  plan decomposition (`methodology.plan-work`); also not for security verification
  (use `security.audit` at P1) or accessibility verification (use
  `quality.audit-a11y` at P1).

  **Inputs:** the artifact (or the work in progress) and the original goal /
  user story / ADR.
  **Outputs:** ephemeral. A pass/fail signal with a list of gaps. The surrounding
  capability skill decides what to do with the signal (re-iterate or escalate to
  HITL).
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# verify

Apply "does this actually solve the stated problem?" *before* completion is declared.

## Procedure

1. **Restate the original goal** (from the user story, PRD, ADR, or task description).
2. **Walk the artifact against the goal point by point.** For each requirement, mark: ✓ satisfied / ✗ missing / ⚠ partial.
3. **If any ✗ or ⚠ remains, list the specific gap.** Do not declare done.
4. **If all ✓, declare done** and surface the verification summary to the surrounding capability skill so it can promote the artifact.

## Hard refusals

- **Refuse to declare done with unresolved gaps.** A `verify` that rubber-stamps incomplete work is a methodology violation. Conformance includes an adversarial fixture that asserts this.
- **No authoritative artifact writes.** Verification produces only an ephemeral signal.

## Inline composition

Composed by capability skills before each artifact-state transition that needs human-grade confirmation. `engineering.propose-pr` invokes it before opening the PR; `engineering.review-diff` invokes it before emitting the verdict; `engineering.propose-adr` invokes it before promoting the ADR from `proposed` to `accepted`. No subagent dispatch.

## Latency budget

- p95 ≤ 10 s per turn.
