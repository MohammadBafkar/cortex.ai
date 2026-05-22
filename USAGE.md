# Usage

This file describes the intended V1 user path. Some commands are roadmap items
until the corresponding phase is implemented.

## Install: Target UX

Claude Code:

```bash
claude /plugin marketplace add /path/to/cortex.ai
claude /plugin install marketplace@cortex
claude /cortex-init
```

`/cortex-init` should:

- resolve `CORTEX_HOME`;
- install the default plugin set;
- install or verify managed hook settings;
- run `/cortex-verify`;
- print the next useful command.

Non-Claude hosts should use a CLI wrapper once implemented:

```bash
bin/cortex init --host codex
bin/cortex init --host copilot
bin/cortex init --host cursor
```

## Default Plugin Set

```text
marketplace
methodology
engineering
quality
platform
connector-github
connector-github-actions
```

## Daily Commands

| Command | Purpose |
| --- | --- |
| `/cortex-verify` | Verify installation, manifests, dependencies, and conformance readiness |
| `/implement <story>` | Route and run the feature-delivery spine |
| `/review <pr>` | Run admitted review contributors |
| `/audit [filter]` | Query audit records |
| `/cortex-trace <run-id>` | Show a workflow trace |
| `/conformance <plugin>` | Run plugin admission checks |

## Prompt-Only Usage

If the user does not call a slash command, the agent should use
`marketplace.route` to produce a `RoutePlan`, then execute that plan from the
top-level context.

Example:

```text
User: Help me add CSV export and make sure tests are covered.
Agent: route -> implement spine -> quality handoff -> review -> summarize trace.
```

## State

Workflow state is written in the target project under `.agents/state/`.

Do not manually create state paths unless a skill or command tells you to. The
permission hook and `/cortex-verify` should catch ownership drift.

## Development Checks

Useful local checks:

```bash
platform/conformance/conformance validate plugins/engineering
platform/conformance/conformance validate plugins/quality
platform/conformance/conformance validate plugins/platform
platform/conformance/conformance validate plugins/marketplace
platform/conformance/conformance validate plugins/methodology
```

These are not enough for production until runtime fixtures are real. A skipped
runtime conformance pass is not admission.

