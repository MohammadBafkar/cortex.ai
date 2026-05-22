---
capability_interface_id: triageIncident
version: 1
bundle_contract_id: incident
schema_in: Alert@v1
schema_out: IncidentRecord@v1
---

# triageIncident@v1

Turns a fired `Alert@v1` into a triaged `IncidentRecord@v1` with severity + IC assignment + initial status page entry.

## Inputs

- `Alert@v1` (required) — recently fired; correlated with recent deploys.

## Outputs

- `IncidentRecord@v1` at `.agents/state/incidents/<id>/release-operate/`.

## Non-functional contract

- **Latency budget:** p95 ≤ 5 min from alert to triaged IncidentRecord — the budget is dominated by hypothesis formation via `methodology.debug`.
- **Token budget:** ≤ 15K (Opus default for under-stress reasoning).
- **HITL:** Sev0/1 declaration → M-tier checkpoint 2 ack within 10 min; status-page comms → checkpoint 4 (Legal + Comms) before publication.

## Failure modes

- No IC available + rota exhausted → break-glass; surface to executive on-call.
- Auto-rollback already executed by burn-rate trigger → triage starts post-rollback; `caused_by_release` referenced for the DORA emitter.
- Conflicting severity signals (Sev0 alert + low user impact) → IC decides; default to higher severity until proven otherwise.

## Fixtures

Golden: `triage-page-from-burn-rate-alert`.
Adversarial: `incident-without-ic` (refused).
