---
name: product.decompose-epic
description: |
  **Use when:** a PRD has been approved and needs decomposition into an Epic
  + 2–8 UserStories the engineering team can pick up. Triggers on: "/decompose",
  "split this into stories".

  **Do NOT use when:** the user wants a PRD (use `draft-prd`), a code change
  (use `engineering.propose-pr`), or estimation only (compose
  `methodology.estimate` inline).

  **Inputs:** PRD@v1.
  **Outputs:** EpicSpec@v1 + UserStory@v1[] at
  `.agents/state/intakes/<id>/product/` (composite under the epic id).
type: capability
produces_authoritative_artifacts: true
capability_interface_id: decomposeEpic
bundle_contract_id: product-definition
visibility: public
---

# decompose-epic

Decompose an approved PRD into an Epic and 2–8 UserStories. Each story is independently shippable behind a feature flag.

## Procedure

1. **Load the PRD.**
2. **Compose `methodology.decompose` inline.** 2–8 sub-problems, each with explicit boundaries.
3. **Author the Epic** with: name, goal, success metrics (inherited from PRD), out-of-scope (inherited).
4. **Author each UserStory** with: title, Given/When/Then, acceptance criteria, owner-bundle hint (`engineering` for code, `quality` for tests, etc.), 3-point estimate via `methodology.estimate` inline, dependencies on other stories.
5. **Order.** Identify the first 1–2 stories that can ship independently — they are the "thinnest vertical slice" for early validation.
6. **Verify.** `methodology.verify` inline.
7. **Write.** Epic at `.agents/state/intakes/<epic-id>/product/epic.json`; stories at `.agents/state/intakes/<epic-id>/product/stories/<n>.json`.

## Hard rules

- **No more than 8 stories per epic.** More means the PRD is too big — narrow first.
- **No story without acceptance criteria.**
- **No estimates without confidence bands.** Single-number estimates are a defect.
