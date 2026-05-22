---
name: content.localize
description: |
  **Use when:** a DocPage@v1 or UI string set needs localization into another
  language with cultural adaptation, not just translation.
  **Do NOT use when:** the user wants original doc authoring (`write-doc`).
  **Inputs:** DocPage@v1 + target locale.
  **Outputs:** DocPage@v1 (localized variant).
type: capability
produces_authoritative_artifacts: true
capability_interface_id: localize
bundle_contract_id: localization
visibility: public
---

# localize

Translate + culturally adapt.

## Procedure

1. **Load** the source DocPage + the locale's translation memory.
2. **Translate**, then **adapt**: idioms, examples, units, formality register.
3. **Flag untranslatable terms** (proper nouns, brand names) — preserve.
4. **Compose `methodology.verify` inline** with a native-speaker review prompt.
5. **Write** the localized variant at `.agents/state/loc/<doc-id>/<locale>/content/`.

## Hard rules

- **No automated MT without human review** for marketing-grade copy.
- **Cultural adaptation is not optional** — straight translation often misleads.
