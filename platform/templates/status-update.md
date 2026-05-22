<!--
Template: StatusUpdate — public status-page entry per incident phase.
Authored by: content.write-status-update.
Required: phase, customer-facing language, no speculation about cause, no internal-only details.
HITL: mandatory on every publication (checkpoint 4 — Comms + Legal sign-off).
Pick ONE template block per phase and delete the rest.
Remove this block before publishing.
-->

# Status Update — <subsystem / product area>

- **Phase:** <identified | investigating | mitigating | resolved>
- **Incident:** <INC-id>
- **Severity:** <SEV0 | SEV1 | SEV2 | SEV3>
- **Author:** <comms lead>
- **HITL approver(s):** <names — required before publication>
- **Publication channel:** <status page | email | in-app banner>

---

## Phase: identified

We are aware of an issue affecting <user-visible behavior>. Engineering is
investigating. We will provide an update by <UTC time>.

**What you can do:** <e.g., retry later / use the older endpoint / no action>.

---

## Phase: investigating

We have confirmed <what is affected> since <UTC time>. Initial impact: <scope —
e.g., "checkout failures for a subset of users in the EU region">.

We have not yet identified the root cause. Engineering is working on
mitigation. Next update by <UTC time>.

---

## Phase: mitigating

We have identified the contributing factor and are deploying a mitigation
to <where>. We expect <user-visible behavior> to begin returning to normal
within <ETA>. We will confirm full resolution once metrics are stable.

---

## Phase: resolved

Full service was restored at <UTC time>. Total impact window: <start UTC>
through <end UTC> (<duration>).

**What was affected:** <scope>.
**What we are doing now:** a blameless postmortem will be published within
5 business days. We will share what we learn and what we are changing to
reduce the chance of recurrence.

---

<!--
DO NOT include in any public update:
- Engineer names
- Server / region internal codes
- Speculation about cause before the postmortem
- Customer counts unless already public
-->
