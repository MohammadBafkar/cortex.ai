---
name: methodology.hypothesis-test
description: |
  **Use when:** the team wants to investigate a question by forming a
  falsifiable hypothesis, designing the cheapest test that could disprove
  it, and acting on the result. Composed inline by `data.run-experiment`
  and `release-operate.triage-incident` (debug variant).

  **Do NOT use when:** the user wants brainstorm (`methodology.brainstorm`),
  pure debugging (`methodology.debug` — debug is the loop, this is the
  framing), or estimation (`methodology.estimate`).

  **Inputs:** a question or claim.
  **Outputs:** ephemeral test design + the result.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# hypothesis-test

Frame a question as a falsifiable hypothesis; design the cheapest test that could disprove it; commit to acting on the result.

## Procedure

1. **State the question** in one sentence.
2. **Form the hypothesis.** A *single* falsifiable claim. "X improves Y by ≥ Z%" not "X is better".
3. **Identify the cheapest disproving test.** What observation, if seen, would force you to abandon the hypothesis?
4. **Pre-register what success / failure means.** Write it down BEFORE running. No moving the goalposts after.
5. **Run the test.** Then check against the pre-registered criteria.
6. **Act on the result.** Even (especially) when the result is negative.

## Hard rules

- **One hypothesis at a time.** Multi-hypothesis is "I don't know" disguised as analysis.
- **No goalpost moving.** Pre-registered metrics only.
- **Negative results are valid.** Refusing to act on a disconfirmed hypothesis is anti-science.
