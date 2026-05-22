---
name: test
description: |
  **Use when:** the user types `/test [suite-id]` to execute an existing TestSuite
  (written by `quality`) against the current working tree.
  **Do NOT use when:** the user wants to write a test (use `quality.write-unit-test`)
  or run the full CI pipeline (use `/build`).
  **Inputs:** optional suite-id; defaults to the most recent suite under
  `.agents/state/tests/`.
  **Outputs:** TestRun@v1 at `.agents/state/runs/<run-id>/platform/test-run.json`.
argument-hint: "[suite-id]"
allowed-tools: [Task, Read, Bash]
---

# /test

Apply the procedure in `platform.run-tests`. Load the named suite, execute, capture per-case results, write the TestRun envelope.
