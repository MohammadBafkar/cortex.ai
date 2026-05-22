---
name: approve
description: |
  **Use when:** the user types `/approve` to list pending HITL approvals, or
  `/approve <id> approve|deny|hold` to act on a specific request.
  **Do NOT use when:** the user wants to enqueue (that's a workflow's job, not
  a human's), or to bypass approvals (use `--force-incomplete-admission` on
  `/install-plugin` for the narrow admission case only).
  **Inputs:** no args (list pending), or `<id> <decision> [--by <principal>]`.
  **Outputs:** decided ApprovalRequest@v1 envelope moved from `pending/` to
  the matching decision-state subdir.
argument-hint: "[<id> <approve|deny|hold> [--by <principal>]]"
allowed-tools: [Task, Read, Bash, Write]
---

# /approve

List + decide HITL approvals.

## Procedure

1. **No args** — list pending requests:
   ```bash
   bash ${CORTEX_HOME}/platform/hooks/hitl-router.sh list --state pending
   ```
   Render each request as: id, checkpoint, tier (M | C), SLA hours remaining, summary.

2. **`<id> <decision>`** — act on a specific request:
   ```bash
   bash ${CORTEX_HOME}/platform/hooks/hitl-router.sh decide <id> <approve|deny|hold> [--by <principal>]
   ```
   The router:
   - rejects self-decide via SoD check (originator can't approve their own request);
   - moves the JSON file from `pending/` to `approved/`, `denied/`, or `held/`;
   - emits a signed audit event `approval.decided`;
   - returns exit 0 on success, 1 on SoD violation or invalid request id.

3. **Surface the result** to the user with the new state path + audit-log id.

## Hard rules

- **SoD enforced.** The principal who originated a request cannot decide it. Even if you're the only admin online, you can't approve a request you triggered. Surface an SoD violation to your secondary.
- **Held is not approved.** A `hold` decision pauses the workflow without advancing it. Use when more information is needed.
- **Expired is not denied.** When a request crosses its SLA, the router moves it to `expired/` with a fallback per the checkpoint's policy (default `hold`). The workflow that originated the request reads this state and routes through the fallback path.
- **Break-glass is logged separately.** Per `GOVERNANCE.md` §5.2, break-glass invocations have their own envelope (`BreakGlassRecord@v1`) and require post-hoc review within 24h.

## Related

- `platform/hooks/hitl-router.sh expire-overdue` runs on a cron (or via SessionEnd in dev) to sweep stale pending requests.
- The parent workflow executor writes to `pending/` when a workflow state
  declares a `hitl_checkpoints[]` entry; it polls the queue at each state
  transition.
