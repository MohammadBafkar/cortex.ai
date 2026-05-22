---
name: content.write-doc
description: |
  **Use when:** a user-facing doc page is needed — tutorial, how-to, reference,
  conceptual explainer. Often dispatched after `architecture.define-api`
  produces an APIContract.

  **Do NOT use when:** the user wants release notes (use `write-release-notes`),
  status update (use `write-status-update`), security advisory (use
  `write-advisory`), or PRD authoring (use `product.draft-prd`).

  **Inputs:** APIContract@v1, PRD@v1, or in-context topic.
  **Outputs:** DocPage@v1 at `.agents/state/docs/<id>/content/page.md`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: writeDoc
bundle_contract_id: documentation
visibility: public
---

# write-doc

Author a single doc page tailored to the asker's stated audience.

## Procedure

1. **Identify the doc type** (Diátaxis): tutorial / how-to / reference / explanation.
2. **Identify the audience.** Compose `methodology.mentor` inline to pitch at the right level.
3. **Compose `methodology.research` inline** to cite primary sources (the APIContract, the PRD, the actual code).
4. **Draft.** Lead sentence answers "what is this, who is it for, what will I learn".
5. **Compose `methodology.verify` inline** before promotion.
6. **Write** at `.agents/state/docs/<id>/content/page.md` + JSON envelope alongside.

## Hard rules

- **Every code example runs.** Test the snippet (or label it as illustrative).
- **No marketing prose.** Doc pages explain; they don't pitch.
- **Diátaxis labels** — every doc declares its type explicitly.
