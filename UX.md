# UX

The MVP UX should be quiet, direct, and traceable. The user should not need to
know the internal taxonomy to get useful work done.

## Install Flow

```text
User:
/plugin marketplace add /path/to/cortex.ai
/plugin install marketplace@cortex
/cortex-init

Agent:
Installed default plugins:
- marketplace
- methodology
- engineering
- quality
- platform
- connector-github
- connector-github-actions

Verification passed.
Try: /implement <story-id>
```

## Prompt-Only Routing

```text
User:
Can you add CSV export and make sure it is reviewed?

Agent:
I will route this as a feature implementation with test and review handoffs.

RoutePlan:
- engineering.propose-pr
- quality.write-unit-test
- platform.run-pipeline
- engineering.review-diff
```

The route plan is visible because it is a decision point. Low-level telemetry is
not printed inline.

## Implement Flow

```text
User:
/implement C-42

Agent:
Routing C-42 through the feature spine.
Engineering produced PR artifact PR-C-42.
Quality added the unit-test artifact.
Platform ran the pipeline.
Review completed with verdict: request-changes.

Next action:
Apply the review fixes, then rerun /review PR-C-42.
Trace: /cortex-trace run-...
```

## Audit Flow

```text
User:
/cortex-trace run-123

Agent:
run-123
1. marketplace.route selected feature spine
2. engineering.propose-pr wrote PR artifact
3. quality.write-unit-test wrote test artifact
4. platform.run-pipeline wrote run artifact
5. engineering.review-diff wrote review verdict
```

## UX Rules

- Do not print telemetry noise by default.
- Do not expose internal bundle taxonomy unless it helps resolve ambiguity.
- Show route plans before execution when the user did not explicitly choose a
  command.
- Ask for human approval only at the three mandatory V1 gates.
- Prefer short summaries plus a trace command over long provenance dumps.

