# AGENTS.md

Canonical instructions for AI coding agents working in this repository: Claude
Code, OpenAI Codex, GitHub Copilot, Cursor, and others. Vendor-specific files
point back here.

If you are a human reader, start with [`README.md`](./README.md).

## What This Repo Is

cortex.ai is an internal, single-org coding-agent capability marketplace. It
ships a small, coherent plugin spine for routing, implementation, testing,
pipeline execution, audit, and conformance.

This repo is not trying to be a public plugin registry, a language skill
catalog, or a full enterprise governance platform. Broad language/framework
skills should be integrated from maintained external catalogs unless Cortex has
a specific internal policy reason to own them.

## Active Docs

Read these in order for load-bearing changes:

1. [`SPEC.md`](./SPEC.md) — active product and architecture contract.
2. [`ROADMAP.md`](./ROADMAP.md) — realistic staged delivery plan.
3. [`USAGE.md`](./USAGE.md) — install and daily command surface.
4. [`CONNECTORS.md`](./CONNECTORS.md) — shipped connector policy.
5. [`UX.md`](./UX.md) — current MVP user flows.

Archived pre-1.0 design exploration lives under `docs/archive/`. It is useful
history, not active authority.

## Hard Rules

### Sidecar Naming

Use `.cortex` for Cortex sidecar metadata.

```text
plugins/<name>/
  .claude-plugin/plugin.json
  .cortex/manifest.json
  .cortex/conformance.yaml
```

Use `CORTEX_HOME` for repo-relative platform paths.

### Native And Cortex Metadata Stay Separate

Host-native manifests remain host-native:

- Claude Code: `.claude-plugin/plugin.json`
- Codex: `.codex-plugin/plugin.json`
- Cursor: `.cursor-plugin/plugin.json`
- Copilot: `.github/skills/` and related GitHub-native files

Cortex admission metadata lives in `.cortex/manifest.json`.

### Skills Are The Portable Unit

Every Cortex-authored skill uses `SKILL.md` and must have:

- `name`
- `description` with `Use when`, `Do NOT use when`, `Inputs`, `Outputs`
- `type: capability | methodology`
- `produces_authoritative_artifacts: true | false`
- `capability_interface_id` and `bundle_contract_id` for capability skills

Methodology skills produce no authoritative artifacts. Capability skills write
only to paths allowed by the state ownership map.

### Routing Is Separate From Execution

The router is allowed and important, but it is a planner/discovery surface.

- `marketplace.route` maps a user prompt or command to a `RoutePlan`.
- The parent command or top-level agent session executes the route plan.
- Worker subagents stay leaves.

Do not make a subagent into a hidden workflow engine that dispatches more
subagents. That creates runtime ambiguity across hosts.

### Communication Patterns

Use the smallest sufficient pattern:

- Intent routing: open user prompt -> `RoutePlan`.
- Inline composition: methodology guidance in the current context.
- Serial handoff: one capability writes a workspace artifact, another reads it.
- Parallel fan-out: parent dispatches independent leaf workers to disjoint paths.

### Workspace State Ownership

Workspace state is under `.agents/state/` in the target project. Each top-level
state directory has exactly one owner in
`platform/settings/state-ownership.json`.

Composite artifacts use contributor subpaths:

```text
.agents/state/reviews/<pr-id>/engineering/finding-1.json
.agents/state/reviews/<pr-id>/quality/finding-1.json
```

The orchestrator merges. Contributors do not write to each other's subtrees.

### Hooks Are Host-Specific

Claude Code hooks are useful and should remain small:

- permission enforcement;
- audit capture;
- budget tracking;
- session lifecycle;
- HITL queue handling.

Do not claim portable hook behavior unless the target agent has been smoke
tested. Hooks, HITL, and audit degrade differently in Codex, Copilot, and
Cursor.

### MVP Scope

The default catalog should publish only:

- `marketplace`
- `methodology`
- `engineering`
- `quality`
- `platform`
- `connector-github`
- `connector-github-actions`

Other plugin directories are incubating until they have real fixtures, closed
dependencies, and a workflow that justifies default publication.

## Making Changes

### Adding Or Updating A Skill

Decide whether it is methodology or capability. Keep the trigger surface narrow
and non-overlapping. Prefer improving an existing skill over adding a new one.

### Adding A Plugin

Add a plugin only when a workflow needs a new owner. The minimum bar is:

- native manifest;
- `.cortex/manifest.json`;
- `.cortex/conformance.yaml`;
- real golden/adversarial fixtures;
- connector dependencies closed;
- documented state ownership.

### Adding A Connector

Connectors are plugins. Do not reference a connector from a manifest unless the
connector exists in `plugins/` and is listed in the marketplace catalog or the
plugin is explicitly incubating.

### Adding A Workflow

Prefer a parent command executing a `RoutePlan`. Workflow YAML may exist as data,
but the router should plan; the parent should execute.

## Verification Before Completion

For documentation changes:

- root docs still point to `SPEC.md` and `ROADMAP.md`;
- archived docs are not described as active authority;
- no implementation file uses the retired sidecar or repo-root environment
  names outside `docs/archive/`.

For plugin changes:

- manifests parse;
- declared files exist;
- connector dependencies exist;
- state writes match `platform/settings/state-ownership.json`;
- conformance does not silently skip runtime checks.

When docs and implementation disagree, report the disagreement directly. Do not
silently reconcile it in prose.
