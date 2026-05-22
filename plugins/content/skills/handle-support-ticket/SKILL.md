---
name: content.handle-support-ticket
description: |
  **Use when:** a customer SupportTicket@v1 arrives and the team needs a
  first-response draft + escalation routing.
  **Do NOT use when:** the user wants release notes (`write-release-notes`),
  status updates (`write-status-update`), or to actually fix a bug
  (engineering.propose-pr).
  **Inputs:** SupportTicket@v1.
  **Outputs:** TicketResponse@v1.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: handleSupportTicket
bundle_contract_id: support-onboarding
visibility: public
---

# handle-support-ticket

Draft a first response + route to the right team.

## Procedure

1. **Read** the ticket + the customer's prior tickets for context.
2. **Compose `methodology.research` inline** — search docs + known-issues KB; cite sources in the response.
3. **Classify**: how-to / bug / feature request / abuse. Each routes differently.
4. **Draft response**. Customer-language, not engineer-language.
5. **Escalation routing.** Bug → engineering; abuse → security; feature → product.
6. **Compose `methodology.verify` inline.**
7. **HITL** on send (checkpoint 5 — Customer comms, C-tier MVP1).

## Hard rules

- **No speculation.** If you don't know, escalate.
- **No internal-only language in customer-facing draft.**
