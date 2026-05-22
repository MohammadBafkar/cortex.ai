---
name: methodology.estimate
description: |
  **Use when:** a capability skill (typically `product.size-opportunity` or
  `delivery.size-epic` at P1) needs an estimate with explicit confidence
  bands rather than a single number.

  **Do NOT use when:** the user wants a hard commitment (estimates are not
  promises — escalate to HITL for commitments), exact measurements (run the
  actual workload), or to size a task < 1 hour (just do it).

  **Inputs:** a description of the work + the size unit (hours | days |
  story-points | dollars).
  **Outputs:** ephemeral. A 3-point estimate (low / expected / high) with
  the rationale + the top risk that drives the high-end.
type: methodology
produces_authoritative_artifacts: false
visibility: public
---

# estimate

Produce 3-point estimates with explicit reasoning. No single-number estimates.

## Procedure

1. **Restate the work** in one sentence.
2. **Identify ≤ 3 reference points.** Past work of comparable shape — what did it actually take? If there are zero references, name that explicitly.
3. **Estimate low, expected, high.** Low = "everything goes as planned"; expected = median outcome; high = "two surprises happened in a row".
4. **State the top risk** that drives the high-end. The risk should be falsifiable: "if integration with X requires a backfill, +2 days."
5. **State confidence.** ≤ 60% = "rough" (consider spiking first); 60-80% = "usable for planning"; ≥ 80% = "this is well-understood work".

## Hard rules

- **No single-number estimates.** A point estimate is a defect.
- **No estimates without reference points or stated unknowns.**
- **No artifact writes.**

## Latency budget

p95 ≤ 15 s.
