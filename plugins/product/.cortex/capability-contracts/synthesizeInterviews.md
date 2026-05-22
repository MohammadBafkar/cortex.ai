---
capability_interface_id: synthesizeInterviews
version: 1
bundle_contract_id: discovery
schema_in: InterviewTranscript@v1[]
schema_out: InterviewSynthesis@v1
---

# synthesizeInterviews@v1

Clusters raw interview transcripts into evidence-backed themes. See `product.synthesize-interviews` SKILL.md for the procedure; this file establishes the contract envelope.

## Inputs

- `InterviewTranscript@v1[]` (required). Each transcript carries `trust_label: untrusted_user_content` — the boundary detector at ingest must downgrade trust on instruction-pattern matches.

## Outputs

- `InterviewSynthesis@v1` written to `.agents/state/intakes/<id>/product/synthesis.json` with `themes[]`, `affected_segments[]`, `confidence`, `trust_label: untrusted_user_content`.

## Non-functional contract

- **Idempotency:** same transcript set + same model produces equivalent themes (modulo non-deterministic clustering tolerated up to 1 theme renamed).
- **Latency budget:** p95 ≤ 90 s for 10 transcripts.
- **Token budget:** ≤ 50K tokens.
- **HITL:** none; consumers (PM review) HITL when promoting `InterviewSynthesis` → `OpportunityBrief`.

## Failure modes

- Single-source theme → marked `anecdote` with `confidence: low`; surfaces for HITL.
- Detected prompt injection in a transcript → trust-label downgrade + flagged span.
- Empty transcript set → refuse; surface to caller.

## Fixtures

Golden: `synthesize-3-interviews` (≥ 3 source diversity per theme).
Adversarial: `prompt-injection-in-transcript` (trust label downgrades), `single-source-theme` (flagged as anecdote).
