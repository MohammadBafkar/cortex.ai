---
name: methodology.retro
description: |
  **Use when:** the team wants a structured retrospective on a unit of work
  (sprint, project, incident, feature ship). Distinct from
  `Delivery.runRetro` artifact authoring — this is the *technique*.

  **Do NOT use when:** the user wants a postmortem on a specific incident (use
  `release-operate.postmortem`), AdoptionReport (use `product.measure-adoption`),
  or one-off brainstorming (`methodology.brainstorm`).

  **Inputs:** the unit of work + timeframe + participants.
  **Outputs:** ephemeral retro notes; capability skill may promote to
  `Retrospective@v1` artifact if applicable.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# retro

Structured retrospective with the start/stop/continue or 4Ls (Liked, Learned, Lacked, Longed-for) frame.

## Procedure

1. **Set the frame.** Default 4Ls. User may swap to start/stop/continue, mad/sad/glad, etc.
2. **Gather observations** per frame category. Anonymize if requested.
3. **Cluster themes.** Three is plenty; more dilutes action.
4. **Action items.** Each must have an owner + by-when + an observable
   completion signal. "We should communicate better" is not an action.
5. **Compose `methodology.verify` inline** — does the action plan address the themes?

## Hard rules

- **Blameless.** Systemic factors, not individuals.
- **Action items with owners + deadlines + observable signals.**
- **No retro without a follow-up review at the next cycle** (otherwise the loop is broken).
