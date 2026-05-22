---
capability_interface_id: handleSupportTicket
version: 1
bundle_contract_id: support-onboarding
schema_in: SupportTicket@v1
schema_out: TicketResponse@v1
---

# handleSupportTicket@v1

First-response draft for a customer `SupportTicket@v1` + classification → routing.

## Inputs

- `SupportTicket@v1` (required, `trust_label: untrusted_user_content`).
- Optional ticket history for the same customer.

## Outputs

- `TicketResponse@v1` at `.agents/state/support/<ticket-id>/content/response.json`.

## Non-functional contract

- **Latency budget:** p95 ≤ 30 s for a first draft.
- **Token budget:** ≤ 8K.
- **HITL:** outgoing customer response → checkpoint 5 (Customer comms). Bug routing to engineering = no HITL.

## Failure modes

- Speculation about the bug's cause to the customer → refuse (route to engineering, do not promise diagnosis).
- Internal-only language in customer-facing draft → refuse.
- Auto-send without HITL → PEP blocks.

## Fixtures

Golden: `handle-how-to-ticket`.
Adversarial: `ticket-response-speculates-cause` (refused).
