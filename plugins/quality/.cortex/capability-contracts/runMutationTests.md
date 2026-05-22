---
capability_interface_id: runMutationTests
version: 1
bundle_contract_id: test-authoring
schema_in: TestSuite@v1
schema_out: MutationReport@v1
---

# runMutationTests@v1

Generates mutated source variants; verifies each mutation is caught by ≥ 1 test. Reveals low-quality test cases (assertions that don't actually assert).

## Inputs

- `TestSuite@v1` (required).
- The source files under test (auto-detected from suite metadata).

## Outputs

- `MutationReport@v1` at `.agents/state/runs/<id>/quality/mutation.json` with mutation score + survived mutations + suggested test additions.

## Non-functional contract

- **Idempotency:** yes per (suite + source SHA).
- **Latency budget:** p95 ≤ 10 min per ≤ 200 LOC of source (mutation testing is genuinely slow).
- **Token budget:** ≤ 5K (mostly orchestration).
- **HITL:** none; report is advisory unless the project's quality gate enforces a mutation-score floor.

## Failure modes

- Source > 200 LOC scope → refuse; require decomposition.
- Production-code accidental edit during mutation → PEP blocks (mutation runs in a sandbox copy).
- Runner unavailable → state: `requires_human` with install guidance.

## Fixtures

Golden: `mutation-score-on-tested-module`.
Adversarial: `mutation-edits-real-source` (PEP blocks).
