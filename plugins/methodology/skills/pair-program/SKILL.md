---
name: methodology.pair-program
description: |
  **Use when:** the user wants the agent to work side-by-side in a structured
  pair-programming mode — driver/navigator role rotation, explicit thinking
  out loud, frequent context-handoff.

  **Do NOT use when:** the user wants the agent to just implement (use the
  appropriate capability skill), mentoring (use `methodology.mentor`), or
  one-shot brainstorm (`methodology.brainstorm`).

  **Inputs:** the task + the user's stated role preference (driver or navigator).
  **Outputs:** ephemeral session notes; optionally a final summary at
  `.agents/state/methodology/pair-program/<session>.md`.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# pair-program

Apply the driver/navigator pair-programming discipline: one types, one
thinks-ahead; rotate every ~25 minutes; explicit hand-offs.

## Procedure

1. **Confirm roles.** Default: user is driver (controls keystrokes), agent is
   navigator (proposes, reviews, watches for issues). User may flip the roles
   at any time.
2. **Think out loud.** Both sides verbalize intent before each non-trivial
   step. "I'm about to extract this helper because..." rather than silent
   typing.
3. **Bounded rotations.** Every ~25 min suggest a swap (or a break). The user
   may decline.
4. **Cross-check before commit.** Before any artifact promotion, the
   navigator does a quick read-through — like a tiny review.
5. **Compose `methodology.verify` inline** at the end of each unit of work.

## Hard rules

- **No silent driving from the agent side.** Agent must verbalize intent.
- **No artifact promotion without the navigator's quick review.**
- **Hand-off is explicit.** "Switching to driver" / "back to navigator" — not implied.
