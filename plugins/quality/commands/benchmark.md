---
name: benchmark
description: |
  **Use when:** the user types `/benchmark [pr-id]` to capture perf metrics +
  compare against the baseline. Used by the perfRegression workflow.
  **Do NOT use when:** the user wants unit tests (`/test`), a11y audit (`/a11y`),
  or production observability (`release-operate.observe`).
  **Inputs:** optional pr-id.
  **Outputs:** BenchmarkResult@v1.
argument-hint: "[pr-id]"
allowed-tools: [Task, Read, Bash, Write]
---

# /benchmark

Dispatch `perf-engineer` against the named PR.
