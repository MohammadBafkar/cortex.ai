<!--
Template: Research notes for `methodology.research` invocations.
Ephemeral — written to .agents/state/methodology/research/<session>.md and
swept on SessionEnd unless a capability skill promotes the synthesis.
Required: every claim cited with (source: <url-or-path>).
-->

# Research notes — <question>

- **Question:** <restated in one sentence>
- **Asked by:** <calling skill + invocation id>
- **Window:** <if time-bounded>
- **Source classes consulted:** <docs | code | rfc | paper | community>

## Findings

- **<claim 1>** (source: `<url-or-path>`)
- **<claim 2>** (source: `<url-or-path>`)
- **<claim 3>** (source: `<url-or-path>`)

<!-- ≤ 5 bullets per turn; every bullet cited. Uncited bullets are a methodology violation. -->

## Contradictions

<If two sources disagree, name both + flag for the surrounding capability skill.>

- <claim X> from `<source A>` contradicts <claim Y> from `<source B>` — surface for HITL.

## Unanswered

<What the question is still missing. Surface for the next round of research or for `methodology.clarify`.>

- ...

## Soft handoff

<Suggest the next action. "Want me to draft the ADR / PRD / code based on this?">
