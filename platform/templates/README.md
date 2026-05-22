# Document Templates

Canonical structural templates referenced by capability skills. Authors fill
in `<placeholders>` and remove guidance comments before promoting to
`proposed`.

The templates are deliberately *structural*, not stylistic — they enforce
sections + required fields. The skill's procedure adds the methodology
discipline around how to populate them.

| Template | Owning skill(s) | Schema |
| --- | --- | --- |
| `adr.md` | `engineering.propose-adr`, `architecture.propose-adr` | `ADR@v1` |
| `prd.md` | `product.draft-prd` | `PRD@v1` |
| `rfc.md` | (broad-scope, ad-hoc) | n/a — informal |
| `system-design.md` | `architecture.design-system` | `SystemDesignDoc@v1` |
| `api-contract-openapi.yaml` | `architecture.define-api` | `APIContract@v1` (REST) |
| `postmortem.md` | `release-operate.postmortem` | `Postmortem@v1` |
| `threat-model.md` | `security.threat-model` | `ThreatModel@v1` |
| `pia.md` | `security.run-pia` | `PrivacyImpactAssessment@v1` |
| `model-card.md` | `data.train-model` | inline in `ModelCandidate@v1` |
| `status-update.md` | `content.write-status-update` | `StatusUpdate@v1` |
| `release-notes.md` | `content.write-release-notes` | `ReleaseNotes@v1` |
| `test-plan.md` | `quality.write-integration-test` | inline in `TestSuite@v1` |

## How skills reference these

A capability skill body cites the template by path:

```
Author at `.agents/state/<owned-path>/template-name.md`, following the
shape in `${CORTEX_HOME}/platform/templates/<name>.md`.
```

Conformance fixtures may assert that the produced artifact retains the
template's required headings. Templates evolve via PRs; breaking changes
require a notice-period field in `update_strategy` so downstream skills
have time to migrate.

## Authoring a new template

1. Decide the artifact class and which capability skill(s) emit it.
2. Identify the *non-negotiable* sections (required by governance, schema, or
   downstream consumers). Make these the explicit headings.
3. Mark optional sections with `<!-- optional: ... -->`.
4. Add a brief authoring note at the top: who authors, when, what's required.
5. Reference from the owning skill's body.
