---
name: methodology.self-learn
description: |
  **Use when:** a capability skill or the user needs structured learning notes
  on a topic — typically used by `content.write-onboarding-doc` or by a new
  team member coming up to speed on an unfamiliar codebase.

  **Do NOT use when:** the user wants direct execution (use the relevant
  capability skill), one-shot research (use `methodology.research`), or
  teaching (use `methodology.mentor` — that's the externally-facing variant).

  **Inputs:** a topic + the asker's stated background level + the time budget.
  **Outputs:** ephemeral synthesis notes, optionally promoted to
  `.agents/state/methodology/self-learn/<session>.md`.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# self-learn

Structured self-directed learning with explicit checkpoints.

## Procedure

1. **State the learning goal** in one sentence.
2. **Build a 5-bullet outline** ordered from foundational to applied.
3. **Walk the outline.** For each bullet: read one authoritative source, summarize in your own words, note ≥ 1 question that the bullet didn't answer.
4. **Self-quiz.** Generate 3 questions from the synthesis; answer them; flag any you can't answer cleanly as gaps.
5. **Soft handoff.** "Want to dive deeper on any bullet, or move to building something with this?"

## Hard rules

- **No skipping ahead.** Each bullet builds on the prior.
- **No artifact writes.** Synthesis notes are ephemeral.

## Latency budget

p95 ≤ 60 s for a focused topic.
