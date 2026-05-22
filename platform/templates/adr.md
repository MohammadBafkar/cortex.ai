<!--
Template: ADR (Architecture Decision Record) — Nygard-style.
Authored by: engineering.propose-adr (MVP1, minimal) or architecture.propose-adr (P1, full).
Required sections: Title, Status, Context, Decision, Consequences.
Optional sections: Decomposition, Options, Risks & Mitigations, References.
Remove this comment block + any unused optional sections before promoting to `proposed`.
-->

# ADR-<id>: <title>

- **Status:** proposed <!-- proposed | accepted | superseded by ADR-<id> | deprecated -->
- **Date:** <YYYY-MM-DD>
- **Authors:** <name(s)>
- **Reviewers:** <name(s) — required for `accepted`>
- **Supersedes:** <ADR-id or N/A>

## Context

<What forces this decision? State the constraint(s), the prior state, the trigger
that made this decision necessary now. 2–6 sentences. Cite the PRD, prior ADRs,
or external requirements that apply.>

<!-- optional: Decomposition. Use when the decision has independent sub-parts
that can be made separately. Per methodology.decompose: 2–5 sub-problems with
explicit interfaces. -->

## Options Considered

<List ≥ 2 options. A single-option ADR is a defect — capture the alternatives
even if one is obviously dominant.>

### Option A: <name>

- **Description:**
- **Pros:**
- **Cons:**

### Option B: <name>

- **Description:**
- **Pros:**
- **Cons:**

<!-- additional options as needed -->

## Decision

<State the chosen option in one sentence. Then 1–3 paragraphs of WHY this
option, citing the trade-offs that made it the right call. Do not restate
the option's description — that's above.>

## Consequences

- **Positive:** <what gets better>
- **Negative:** <what gets worse / new constraints>
- **Neutral:** <what changes in ways neither obviously good nor bad>

<!-- optional: Risks & Mitigations. Use when methodology.risk-assess identified
medium/high risks. Format: risk (likelihood × impact) → mitigation. -->

## References

- PRD: <link or id>
- Prior ADRs: <ADR-id, ADR-id>
- External: <RFC / paper / vendor doc>
