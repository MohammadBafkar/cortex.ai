---
name: verify
description: |
  **Use when:** the user types `/verify [artifact-id]` to check whether an
  artifact actually solves the stated problem before promoting it. Useful as a
  pre-merge / pre-release check.
  **Do NOT use when:** the user wants a security audit (use `security.audit`
  at P1), accessibility verification (use `quality.audit-a11y` at P1), or
  performance verification (use `quality.benchmark` at P1).
  **Inputs:** optional artifact-id (resolves to the relevant `.agents/state/`
  envelope); otherwise verifies the most recent work in progress.
  **Outputs:** ephemeral pass/fail + gap list.
argument-hint: "[artifact-id]"
allowed-tools: [Read, Grep]
---

# /verify

Apply the procedure in `methodology.verify`. Walk the artifact against the original goal; mark each requirement ✓/✗/⚠; refuse to declare done if any ✗ or ⚠ remains.
