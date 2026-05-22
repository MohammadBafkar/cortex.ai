---
name: methodology.research
description: |
  **Use when:** the user (or a capability skill composing inline) needs grounded
  information from authoritative sources before authoring an artifact.
  Triggers on: "research", "what does the spec say", "find prior art", "/research".

  **Do NOT use when:** the user wants ideation (use `methodology.brainstorm`),
  decomposition into steps (use `methodology.plan-work`), or domain debugging
  (use `methodology.debug`).

  **Inputs:** a research question + optional source-class hint
  (docs | code | community | regulation).
  **Outputs:** ephemeral. Optionally write notes to
  `.agents/state/methodology/research/<session>.md` with cited sources,
  using the template at `${CLAUDE_PLUGIN_ROOT}/skills/research/templates/research-notes.md`.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# research

Find grounded information for the surrounding capability skill. Cite every claim.

## Procedure

1. **Restate the question** in one sentence.
2. **Identify ≤ 3 authoritative source classes.** Examples: official docs, RFCs, primary-source code, peer-reviewed papers. *Avoid* community Q&A as the *only* source — use it for orientation, not citation.
3. **Fetch + read.** Use the available MCP connectors (docs servers, code-search) or Bash for local code reads. If a source contradicts the question, surface that as a finding.
4. **Summarize.** ≤ 5 bullet points with explicit citations of the form `(source: <url|path>)`.
5. **Soft handoff.** "Want me to draft the ADR / PRD / code based on this?"

## Hard rules

- **Every claim is cited.** Uncited claims are a methodology violation; the surrounding capability skill MUST refuse to use them.
- **No artifact writes** to authoritative subdirs. PEP blocks.
- **Bounded depth.** At most 3 follow-up fetches per turn.

## Latency budget

p95 ≤ 30 s. The bottleneck is network I/O, not LLM reasoning.
