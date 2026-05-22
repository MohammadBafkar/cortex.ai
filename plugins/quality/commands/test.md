---
name: test
description: |
  **Use when:** the user types `/test [suite-id|kind]` — defaults to unit
  tests; pass `integration`, `contract`, or `mutation` to target other kinds.
  **Do NOT use when:** the user wants benchmark (`/benchmark`), a11y
  (`/a11y`), or a full CI pipeline (use `platform.run-pipeline`).
  **Inputs:** optional suite-id or kind.
  **Outputs:** TestRun@v1 or TestSuite@v1 depending on kind.
argument-hint: "[suite-id|integration|contract|mutation]"
allowed-tools: [Task, Read, Bash, Write]
---

# /test

Dispatch `test-author` (for write-X-test) or `test-runner-lite` (for run-unit-tests / run-mutation-tests) depending on the requested kind.
