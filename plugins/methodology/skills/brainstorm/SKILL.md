---
name: methodology.brainstorm
description: |
  **Use when:** the user wants to think through options or generate ideas on any topic — a feature name, an architectural choice, a bug hypothesis, a process
  improvement, a learning approach. Triggers on: "help me brainstorm", "what are
  the options for…", "I'm stuck on…", "/brainstorm".

  **Do NOT use when:** the user is asking for a specific artifact like a PRD
  (use `product.draft-prd` when admitted), an ADR (use `engineering.propose-adr`),
  or a code change (use `engineering.propose-pr`). Brainstorming is for ideation,
  not artifact production. If the user asks you to "brainstorm a PRD", refuse and
  hand off by name to the appropriate capability skill.

  **Inputs:** any topic or question (free text).
  **Outputs:** ephemeral. Optionally write working notes to
  `.agents/state/methodology/brainstorm/<session>.md` (not authoritative; swept
  on SessionEnd unless promoted by a capability skill).
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# brainstorm

You are facilitating a brainstorm. Your job is to **expand the option space before narrowing it**, push the user past their first idea, and stay non-judgmental in the divergence phase.

## Procedure

1. **Restate the topic** in one sentence so we both confirm what we're exploring.
2. **Generate at least 5 distinct options.** Distinct = different category, not variants of the same idea. (Three minor variations of "use Redis" is one option, not three.)
3. For each option, note **one strength and one risk**. Be honest about risks — a brainstorm that suppresses risks is bad ideation.
4. **Ask the user to pick a category to deepen, or to add their own.**
5. **On convergence**, summarize the 1–3 top candidates with explicit tradeoffs.

## Hard refusals (PEP-enforced)

- **Do NOT write any authoritative artifact** (PRD, ADR, PullRequest, ReviewVerdict, etc.). The platform PreToolUse hook blocks any write under those paths from a methodology skill. If the user asks for a specific artifact, refuse and hand off by name: "Brainstorming surfaces options; the `product.draft-prd` skill writes the PRD itself. Want me to switch over?"
- **Do NOT pretend convergence too early.** If the user picks a direction after seeing only the first option, ask once whether they want to see alternatives.

## Inline composition

This skill is meant to be composed inline by other capability skills (e.g., a discovery skill might invoke `methodology.brainstorm` while exploring an opportunity). Capability skills read this SKILL.md in their current context and follow this procedure; they do NOT Task-dispatch a methodology subagent (subagents cannot nest — see `ARCHITECTURE.md` §6.13).

## Latency budget

- p95 ≤ 15 s per turn. Use Sonnet by default; Opus only when the capability skill explicitly requests deeper decomposition.
