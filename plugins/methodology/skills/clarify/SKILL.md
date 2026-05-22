---
name: methodology.clarify
description: |
  **Use when:** a capability skill detects ambiguity in the user's intent and
  needs at most three structured questions before proceeding. Composed inline
  from skills like `engineering.propose-pr` and `engineering.propose-adr`.

  **Do NOT use when:** the user has already provided sufficient detail, or the
  user explicitly says "just do it and we'll iterate." Also not for the user
  asking *you* questions — that's normal conversation, not `clarify`.

  **Inputs:** the ambiguous intent + the schema or expected shape of the next
  artifact.
  **Outputs:** at most three structured questions, one per ambiguity, in
  order of decreasing blast radius.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# clarify

Ask at most **three** structured questions, one per ambiguity, ordered by blast radius (largest first). The questions are *closed* where possible (multiple-choice or yes/no), *open* only when the option space is genuinely large.

## Procedure

1. **Inventory the ambiguities.** What could the user mean that would change the artifact materially? Group similar ambiguities together.
2. **Order by blast radius.** "Are we adding a new endpoint or modifying an existing one?" is bigger than "should the error message say 'invalid' or 'malformed'."
3. **Ask up to 3.** If there are more, ask the 3 most consequential and proceed with reasonable defaults on the rest, calling out the defaults to the user.
4. **On reply, do NOT ask follow-ups.** One round, then proceed.

## Hard refusals

- **No more than 3 questions in one round.** If you genuinely need more, the right move is to call the request under-specified and ask the user for a written spec instead.
- **No question that reads as "are you sure?" with no actual ambiguity.** That is friction, not clarification.

## Inline composition

Capability skills invoke `clarify` inline before authoring an artifact. No subagent dispatch.

## Latency budget

- p95 ≤ 5 s per turn.
