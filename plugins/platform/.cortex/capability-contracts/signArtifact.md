---
capability_interface_id: signArtifact
version: 1
bundle_contract_id: ci-cd
schema_in: BuildArtifact@v1
schema_out: BuildArtifact@v1
---

# signArtifact@v1

Signs a `BuildArtifact@v1` produced by `runPipeline`. The same envelope returns with `signature` populated and `signed_at` timestamp.

## Inputs

- `BuildArtifact@v1` (unsigned, fresh from `runPipeline`).

## Outputs

- Same `BuildArtifact@v1` with `signature` + `signed_at` fields populated; promoted to CAS.

## Non-functional contract

- **Idempotency:** signing the same content+key produces the same signature.
- **Latency budget:** p95 ≤ 5 s (just a sign op).
- **Token budget:** ≤ 1K (no LLM reasoning).
- **HITL:** never for normal builds. Key rotation requires checkpoint 7 (Permission scope).

## Failure modes

- Trust-authority key unavailable → state: `requires_human` (the build doesn't proceed without a signature).
- Signature mismatch on re-verification → quarantine the artifact; surface as a security event.

## Fixtures

Golden: `sign-clean-build-artifact`.
Adversarial: `sign-with-expired-key` (refused).
