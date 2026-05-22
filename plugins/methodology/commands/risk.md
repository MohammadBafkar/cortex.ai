---
name: risk
description: |
  **Use when:** the user types `/risk <decision>` to structure a risk
  assessment for a pending decision (likelihood × impact, mitigation).
  **Do NOT use when:** the user wants estimation (`/plan`) or brainstorming
  (`/brainstorm`).
  **Inputs:** a decision statement.
  **Outputs:** ephemeral risk list with mitigations.
argument-hint: "<decision>"
allowed-tools: [Read]
---

# /risk

Apply the procedure in `methodology.risk-assess`. ≤ 5 risks; each scored likelihood × impact; medium/high get a mitigation.
