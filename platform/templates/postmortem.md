<!--
Template: Blameless Postmortem.
Authored by: release-operate.postmortem.
Required: Timeline, Contributing Factors (not "the cause"), Action Items with owners.
Blameless: systemic factors, never individual names as the cause.
SLA: within 5 BD of incident resolution.
Remove this block before promotion.
-->

# Postmortem: <incident title>

- **Incident:** <INC-id>
- **Severity:** <SEV0 | SEV1 | SEV2 | SEV3>
- **Date of incident:** <YYYY-MM-DD>
- **Date of postmortem:** <YYYY-MM-DD>
- **Incident Commander:** <name>
- **Author:** <name>
- **Reviewers:** <names>

## Summary

<2–4 sentences. What happened, who was affected, how long, how resolved.
This is what an exec reads.>

## Impact

- **Users affected:** <count or %>
- **Duration:** <start UTC — end UTC, total Xh Ym>
- **Services degraded:** <list>
- **Data loss:** <yes / no — if yes, scope>
- **Financial impact:** <if estimable>

## Timeline

<Per-event, UTC times. Cite telemetry / chat / deploy records.>

| Time (UTC) | Event | Source |
| --- | --- | --- |
| <HH:MM> | <event> | <log / chat / deploy id> |
| <HH:MM> | <event> | ... |

## Detection

<How did we find out? Alert? Customer report? Internal QA? How long from
first impact to detection (MTTD)?>

## Response

<Who responded, what they did, what worked, what didn't. No individual blame —
describe roles + actions.>

## Contributing Factors

<Apply 5-whys until reaching systemic / process roots. Multiple factors, not
"the cause".>

1. **Factor 1:** <named systemic factor>
   - Why: <one level deeper>
   - Why: <one level deeper>
   - Root: <organizational / architectural / process root>
2. **Factor 2:** ...

## What Went Well

<Specific things that limited blast radius or sped resolution. Worth keeping.>

## What Could Have Gone Better

<Specific things that made it harder. Not "we should be more careful" — name
the actual gap (missing alert, undocumented runbook, etc.).>

## Action Items

| Action | Owner | Severity | Due | Tracking |
| --- | --- | --- | --- | --- |
| <verb-led action> | <bundle / team / person> | <info \| minor \| major \| blocking> | <YYYY-MM-DD> | <issue / ADR / PR id> |

## References

- Alert(s) that fired: <ids>
- Related ADRs: <ids>
- Prior similar incidents: <ids>
- Status updates published: <links>
