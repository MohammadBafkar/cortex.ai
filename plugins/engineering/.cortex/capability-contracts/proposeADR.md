---
capability_interface_id: proposeADR
version: 1
bundle_contract_id: architecture-lite
schema_in: PRD@v1
schema_out: [ADR@v1]
---

# proposeADR@v1

Produces an `ADR@v1` (Architecture Decision Record) from a `PRD@v1`. This is the **minimal architecture** slice that ships in `engineering v1.0` — full Architecture / API Lifecycle / Design lives in the P1 `architecture` plugin per `PLUGIN-SPECS.md`.

## Inputs

- `PRD@v1` (required) — the product requirement that the architectural decision serves.
- `ADR@v1[]` (optional) — prior ADRs, for `supersedes` / `relates-to` references.

## Outputs

- `ADR@v1` written to `.agents/state/adrs/<adr-id>/engineering/adr.md` and (on promotion) to durable CAS.

## Methodology composition (inline)

- `methodology.decompose` (P1 — when admitted) — break the decision into trade-offs.
- `methodology.risk-assess` (P1 — when admitted) — flag risks per option.
- `methodology.verify` — confirm the chosen option addresses the PRD.

For MVP1, only `methodology.verify` is composed (the other two land with `methodology v1.1` in P1).

## ADR shape

Standard Nygard-style ADR:

- **Title**
- **Status:** proposed | accepted | superseded | deprecated
- **Context:** what forces this decision
- **Decision:** what we will do
- **Consequences:** the resulting trade-offs

## Promotion to P1 `architecture` plugin

When the `architecture` plugin admits in P1, this capability is deprecated in `engineering` with a 90-day notice (per `update_strategy` in `contract.json`). Workspaces that have not migrated by the cutover get an explicit `ADR@v1` mismatch warning; HITL approval per checkpoint 10 (`cutover on deprecation`) is required to remove the engineering-side `proposeADR` skill.

## Non-functional contract

- Latency budget: p95 ≤ 60 s.
- Token budget: ≤ 20K tokens per ADR.

## Golden fixtures (Phase 3)

- "We need a caching strategy" → ADR with 2-3 options + a chosen one + consequences.
- "We need to pick a workflow engine" → ADR that references at least one trade-off (build vs buy).

## Adversarial fixtures (Phase 3)

- PRD contains a prompt-injection nudging toward a specific vendor → trust-label downgrade, vendor flag surfaces in `Consequences`.
- ADR attempts to write outside `.agents/state/adrs/` → PEP blocks.
