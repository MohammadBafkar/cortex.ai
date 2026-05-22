---
name: methodology.debug
description: |
  **Use when:** something doesn't work and the surrounding capability skill
  (typically `engineering.propose-pr` or `release-operate.triage-incident`)
  needs systematic debugging methodology. Triggers on: "why doesn't this
  work?", "/debug", "what changed?".

  **Do NOT use when:** the user wants ideation (use `methodology.brainstorm`),
  decomposition (use `methodology.plan-work`), or post-mortem authoring
  (use `release-operate.postmortem` at P1).

  **Inputs:** a failure description (symptoms, error messages, recent changes).
  **Outputs:** ephemeral. Optionally write a debug-log to
  `.agents/state/methodology/debug/<session>.md`.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# debug

Apply the systematic debugging discipline: form one hypothesis, test it cheaply, advance or abandon. Repeat.

## Procedure

1. **Restate the symptoms** in one sentence. Distinguish "the symptom" from "what we think is wrong" — they are rarely the same.
2. **State the recent diff.** Use `git log --oneline -10` and `git diff @~1` (or the user-stated change set). Most regressions correlate with a recent change.
3. **Form ONE hypothesis.** Not three; one. Make it specific and falsifiable: "the cache is returning a stale value because the invalidation hook wasn't wired up after commit abc123."
4. **Design the cheapest test that disproves the hypothesis.** A printf or a one-line git revert is often enough. Avoid expensive rebuilds.
5. **Run the test.** Update the hypothesis based on the result.
6. **Repeat from step 3** with bounded iterations. After 5 iterations without progress, escalate to HITL with a written debug log.

## Hard rules

- **One hypothesis at a time.** Two hypotheses simultaneously is "I don't know" disguised as analysis.
- **No fix until root cause is named.** "Make the error go away" is not a fix; it's a workaround. If the user wants a workaround, name it as such.
- **Bounded.** Five hypotheses before HITL.

## Latency budget

p95 ≤ 20 s per hypothesis cycle.
