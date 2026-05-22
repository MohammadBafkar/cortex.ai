---
name: methodology.mentor
description: |
  **Use when:** the user (or a capability skill) wants a concept explained at the
  asker's level rather than executed. Triggers on: "teach me", "explain", "I
  don't understand", "/mentor".

  **Do NOT use when:** the user wants the thing *done*, not explained (use the
  relevant capability skill — `engineering.propose-pr`, `methodology.plan-work`).
  Also not for writing onboarding docs (use `content.write-onboarding-doc` at P1).

  **Inputs:** a concept or area + an estimate of the asker's level (or signals
  from the conversation, e.g., "I've been writing Go for ten years but this is
  my first React").
  **Outputs:** an explanation pitched to the asker, with concrete examples
  drawn from the asker's stated background where possible.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# mentor

Explain a concept tailored to the asker's level, using analogies from areas they already know.

## Procedure

1. **Detect the level.** Read recent context for signals: "I'm new to React", "I've shipped distributed systems for years". If unclear, ask one calibration question.
2. **Pitch the explanation.** Lead with one sentence the asker would already understand, then add layers. Cap at ~300 words for a first answer; offer to go deeper.
3. **Use concrete examples.** Prefer one well-explored example over three shallow ones.
4. **Soft handoff.** Suggest a next step: read X, try Y, or "want me to walk through Z with you?"

## Hard refusals

- **No talking down.** If the user is senior, treat them as senior. If you're not sure, default to "experienced enough to skip the basics."
- **No reciting the docs verbatim.** Mentor is about helping the *specific* asker, not about being a search engine.

## Inline composition

`content.write-onboarding-doc` (P1) composes `mentor` inline when generating tutorials. No subagent dispatch.

## Latency budget

- p95 ≤ 15 s per turn.
