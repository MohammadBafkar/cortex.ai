---
name: lang-typescript.lint-with-biome
description: |
  **Use when:** a TS/JS PR needs a lint pass using biome (the project's
  configured profile). Triggers on: "/biome", "lint this", "lint TypeScript".
  **Do NOT use when:** the user wants to author tests (use `write-vitest-test`),
  format only (biome covers both lint+format; this skill runs both), or non-TS/JS
  lint.
  **Inputs:** PullRequest@v1 with TS/JS diff.
  **Outputs:** LintReport@v1 at `.agents/state/langs/lang-typescript/<pr-id>/lint.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: lintWithBiome
bundle_contract_id: lang-typescript
visibility: public
---

# lint-with-biome

Run `biome check` against the diff. Report violations with rule id + fix suggestion.

## Procedure

1. Confirm the project has biome configured (`biome.json` or `biome.jsonc`). If not, propose a starter config based on the project's existing eslintrc/prettierrc (if any) but do NOT add it without HITL.
2. Run `biome check --reporter json <changed-files>` to capture structured output.
3. For each violation: rule id, line, severity (error / warning / info), category (lint / formatter), auto-fixable flag, and the suggestion text.
4. Group by category: style / suspicious / complexity / security / a11y / nursery.
5. Compose `methodology.verify` inline.
6. Write LintReport at `.agents/state/langs/lang-typescript/<pr-id>/lint.json`.

## Hard rules

- **Don't run `biome check --write`** (the auto-fix path) **without HITL.** Surface suggestions; let the user accept or reject.
- **Honor the project's configured profile.** Don't impose stricter rules than configured. The `nursery` group is opt-in per project.
- **Don't disable rules** to make a violation go away. If a rule is wrong for this codebase, surface that for explicit HITL.

## Failure handling

- biome not installed → `state: requires_human` with `npm i -D --save-exact @biomejs/biome` guidance.
- biome config error (invalid schema) → refuse and surface the schema error verbatim.
