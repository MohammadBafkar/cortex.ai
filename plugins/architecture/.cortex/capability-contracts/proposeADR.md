---
capability_interface_id: proposeADR
version: 1
bundle_contract_id: architecture
schema_in: PRD@v1
schema_out: ADR@v1
---

# proposeADR@v1 (architecture, full scope)

Full-scope ADR with explicit decomposition, ≥ 2 options, risk assessment. Supersedes the MVP1 `engineering.propose-adr` (deprecation grace period: 90 days post-architecture-admission).

## Inputs

- `PRD@v1` or in-context decision request.
- Optional `ADR@v1[]` — prior ADRs for `supersedes` references.

## Outputs

- `ADR@v1` at `.agents/state/adrs/<id>/architecture/adr.md` using `platform/templates/adr.md`.

## Non-functional contract

- **Idempotency:** yes (same decision context).
- **Latency budget:** p95 ≤ 90 s.
- **Token budget:** ≤ 25K (Opus default for decomposition work).
- **HITL:** tech lead + 2 reviewers for promotion `proposed` → `accepted` (checkpoint 19 — Architectural exception).

## Failure modes

- Single-option ADR → refuse (per the `adr-anti-patterns.md` reference in the engineering plugin).
- Risk without mitigation on medium/high → refuse.
- Edit of a prior ADR in place → refuse (supersession is a new ADR).

## Fixtures

Golden: `adr-caching-strategy-full-scope` (≥ 2 options + risk-assess), `adr-supersedes-prior`.
Adversarial: `adr-with-single-option` (refused).
