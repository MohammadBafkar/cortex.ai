---
name: content.improve-dx
description: |
  **Use when:** a DXSignal@v1 arrives — onboarding-friction observation, API
  ergonomics complaint, error-message clarity issue. Produces a DXImprovement
  artifact routable to the appropriate plugin.
  **Do NOT use when:** the user wants release notes (`write-release-notes`)
  or implementation (engineering.propose-pr).
  **Inputs:** DXSignal@v1.
  **Outputs:** DXImprovement@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: improveDX
bundle_contract_id: developer-experience
visibility: public
---

# improve-dx

Triage developer-experience friction into actionable, owner-routed improvements.

## Procedure

1. **Read** the signal + source (telemetry, survey, ticket).
2. **Compose `methodology.debug` inline** — what's the root cause, not the symptom?
3. **Classify**: docs gap / API ergonomics / error message / onboarding flow / DX tool.
4. **Propose improvement.** With expected impact + owner-bundle hint.
5. **Compose `methodology.verify` inline.**
6. **Write** DXImprovement; route to the owner-bundle via parent workflow executor.

## Hard rules

- **No fix without an owner.**
- **Bias to small, shippable improvements.** "Rewrite the SDK" is not a DXImprovement; it's a PRD.
