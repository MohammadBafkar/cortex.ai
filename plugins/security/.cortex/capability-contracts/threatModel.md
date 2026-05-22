---
capability_interface_id: threatModel
version: 1
bundle_contract_id: security
schema_in: SystemDesignDoc@v1
schema_out: ThreatModel@v1
---

# threatModel@v1

Applies STRIDE per trust boundary named in a `SystemDesignDoc@v1`.

## Inputs

- `SystemDesignDoc@v1` (required) — must have trust boundaries enumerated (architecture refuses to ship a design without them).

## Outputs

- `ThreatModel@v1` at `.agents/state/findings/security/<id>/security/threat-model.json` using `platform/templates/threat-model.md`.

## Non-functional contract

- **Idempotency:** yes (deterministic given the design + threat catalog).
- **Latency budget:** p95 ≤ 90 s.
- **Token budget:** ≤ 25K (Opus default for adversarial reasoning).
- **HITL:** unresolved high-risk threats → mandatory design rework escalation (not auto-resolved).

## Failure modes

- Trust boundary missed in STRIDE pass → refuse with "incomplete coverage" message.
- Threat without named asset → refuse (vague hand-waving is a defect).
- Mitigation = "be careful" → refuse — must be concrete.

## Fixtures

Golden: `threat-model-checkout` (one threat + mitigation per boundary).
Adversarial: `threat-model-skips-boundary` (refused).
