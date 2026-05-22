---
capability_interface_id: localize
version: 1
bundle_contract_id: localization
schema_in: DocPage@v1
schema_out: DocPage@v1
---

# localize@v1

Translates + culturally adapts a `DocPage@v1` to a target locale. Not pure MT — cultural adaptation is mandatory.

## Inputs

- `DocPage@v1` (source).
- Target locale code (BCP 47, e.g., `fr-FR`, `ja-JP`).
- Translation memory + glossary if the connector provides them.

## Outputs

- `DocPage@v1` (localized variant) at `.agents/state/loc/<doc-id>/<locale>/content/page.md`.

## Non-functional contract

- **Idempotency:** yes per (source + locale + glossary version).
- **Latency budget:** p95 ≤ 60 s for a ≤ 500-word page.
- **Token budget:** ≤ 10K.
- **HITL:** native-speaker review before publication for marketing-grade copy. Technical docs may auto-publish if the project's localization config allows.

## Failure modes

- Untranslatable terms (proper nouns, brand names) translated → refuse; preserve untouched.
- Cultural adaptation skipped (straight word-for-word translation) → emit with `quality: rough` flag.
- Target locale not in supported list → refuse.

## Fixtures

Golden: `localize-onboarding-doc-fr`.
Adversarial: `localize-translates-brand-name` (refused).
