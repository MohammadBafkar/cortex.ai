---
name: methodology.risk-assess
description: |
  **Use when:** a decision needs a structured risk assessment before being
  committed — typically composed inline by `engineering.propose-adr`,
  `architecture.design-system` (P1), or `release-operate.release` (P1).

  **Do NOT use when:** the work is routine, the user wants ideation
  (`methodology.brainstorm`), or estimation (`methodology.estimate`).

  **Inputs:** a proposed decision + the operational context.
  **Outputs:** ephemeral. A list of risks with likelihood × impact + mitigation.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# risk-assess

Identify risks, score likelihood × impact, propose mitigations.

## Procedure

1. **State the decision** in one sentence.
2. **List ≤ 5 risks.** A risk is a *named future event* that, if it happens, harms the outcome. ("Latency increases" is vague; "the new caching layer increases p99 latency on cache-miss" is a risk.)
3. **Score each risk.** Likelihood: low | medium | high. Impact: low | medium | high. The 9 combinations rank as low (LL, LM, ML) / medium (LH, HL, MM) / high (MH, HM, HH).
4. **For each medium/high risk, propose ≥ 1 mitigation.** A mitigation is either a *prevention* (reduce likelihood) or a *containment* (reduce impact). Both are valid; name which.
5. **Surface unresolved high-risk items to HITL.** If any high risk has no satisfactory mitigation, the decision is not ready to commit — flag for review.

## Hard rules

- **No risk without a name.** Vague hand-wavy "things could go wrong" is a methodology violation.
- **No mitigation that's just "be careful".** Mitigations are concrete actions or design changes.
- **No artifact writes.**

## Latency budget

p95 ≤ 20 s.
