# cortex.ai V1 Specification

Status: active specification.

This file supersedes the pre-1.0 design exploration archived under
`docs/archive/`. It describes the product this repo is trying to ship now, not
every future platform idea that might become useful later.

## Purpose

cortex.ai is an internal, single-org capability marketplace for coding agents.
It packages a small set of high-quality plugins that help agents discover the
right skill, hand work between capability owners, verify outcomes, and keep an
auditable trail.

The product is not a general SDLC governance platform, not a language-skill
catalog, and not a public plugin registry. It should integrate with existing
skill/plugin catalogs where they are stronger than first-party Cortex content.

## Product Boundaries

V1 is Claude Code-native, with portable skill content and adapters for Codex,
GitHub Copilot, Cursor, and similar agents.

The V1 marketplace owns:

- capability routing and workflow planning;
- a small internal SDLC plugin spine;
- plugin admission checks;
- workspace-state ownership policy;
- audit and trace records;
- per-agent packaging emitters.

The V1 marketplace does not own:

- broad language-specific skills already maintained elsewhere;
- public marketplace submission/review workflows;
- enterprise-wide RACI governance;
- federated multi-tenant identity;
- a custom workflow runtime independent of the host coding agent.

## Active Plugin Set

The default V1 install is intentionally small.

| Plugin | Role |
| --- | --- |
| `marketplace` | routing, install, conformance, audit, workflow entrypoints |
| `methodology` | cross-cutting thinking skills used inline |
| `engineering` | code authoring and code review artifacts |
| `quality` | unit-test authoring and unit-test execution |
| `platform` | hooks, audit, conformance, CI/pipeline primitives |
| `connector-github` | GitHub pull request and repository access |
| `connector-github-actions` | GitHub Actions CI access |

Other plugin directories may exist as prototypes, but they are incubating until
they meet V1 admission criteria and are published in the marketplace catalog.

## Sidecar Metadata

Each Cortex plugin has two metadata layers:

```text
plugins/<name>/
  .claude-plugin/plugin.json   # host-native Claude Code manifest
  .cortex/manifest.json        # Cortex marketplace contract
  .cortex/conformance.yaml     # Cortex admission fixtures
```

Host-native manifests stay host-native. Cortex metadata never gets stuffed into
`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, or other agent-owned
manifest formats.

`CORTEX_HOME` points to the marketplace repo root. New scripts should use that
name for repo-relative platform paths.

## Skills

`SKILL.md` is the portable unit. A skill may include supporting references,
scripts, or assets, but the activation contract must remain readable from the
frontmatter and opening section.

Required frontmatter for Cortex-authored skills:

- `name`
- `description` with `Use when`, `Do NOT use when`, `Inputs`, `Outputs`
- `type: capability | methodology`
- `produces_authoritative_artifacts: true | false`
- `capability_interface_id` and `bundle_contract_id` for capability skills

Methodology skills produce no authoritative workspace artifacts. Capability
skills may write only to paths allowed by the workspace-state ownership map.

## Routing And Communication

Routing is a first-class capability. The earlier recommendation to remove the
router entirely was too blunt. The correct split is:

- **Router/planner:** maps a user prompt or command to a `RoutePlan`. It may be a
  skill or read-only subagent. It does not mutate state and does not dispatch
  worker subagents.
- **Executor/orchestrator:** the parent command or top-level agent session
  executes the `RoutePlan`, dispatches leaf workers, and records workflow state.

This supports both explicit command usage and prompt-only usage.

| Pattern | Use For | Mechanism |
| --- | --- | --- |
| Intent routing | User gives an open prompt and the agent needs help selecting a capability | `marketplace.route` returns a `RoutePlan` |
| Inline composition | Planning, clarification, TDD, verification | Current context reads and applies methodology skill |
| Serial handoff | Engineering output becomes quality/platform input | Workspace artifact path handoff |
| Parallel fan-out | Independent reviews or analyses over the same input | Parent dispatches leaf workers to disjoint subpaths |

Worker subagents remain leaves. A worker can inspect files, write its owned
artifacts, and return a final message. It should not become a workflow engine.

## State And Authority

Workspace state lives under `.agents/state/` in the target project. Each
top-level state directory has exactly one owner in
`platform/settings/state-ownership.json`.

Composite artifacts use disjoint contributor subpaths:

```text
.agents/state/reviews/<pr-id>/engineering/finding-1.json
.agents/state/reviews/<pr-id>/quality/finding-1.json
.agents/state/reviews/<pr-id>/security/finding-1.json
```

The orchestrator merges composite outputs. Contributors do not write to each
other's subtrees.

The V1 state lifecycle is:

- `draft`
- `approved`
- `archived`

More states can be added later only when an active workflow needs them.

## Hooks

Hooks are Claude Code-native in V1. They enforce policy and capture audit data;
they are not portable as-is to every agent.

V1 hook responsibilities:

- session start/end bookkeeping;
- permission enforcement for workspace-state writes;
- audit capture after tool use;
- budget tracking;
- HITL queue management for the small mandatory gate set.

The permission hook must not claim non-bypassability for write paths it cannot
inspect. Bash-mediated file writes are a known gap until command parsing or
host-level sandboxing is added.

## HITL

V1 has three mandatory human gates:

1. production deploy or irreversible infrastructure apply;
2. plugin admission to the marketplace;
3. break-glass identity or permission escalation.

Other gates are configurable future policy, not default V1 behavior.

## Conformance

Conformance must be a real admission gate, not a structural lint that silently
skips runtime checks.

V1 conformance validates:

- native plugin manifest exists and parses;
- `.cortex/manifest.json` exists and matches schema;
- every declared skill/command/agent file exists;
- skill frontmatter includes required routing sections;
- connector dependencies exist in the catalog;
- workspace-state paths have exactly one owner;
- golden and adversarial fixtures execute or fail explicitly;
- runtime prerequisites such as `jq`, `ajv`, and shellcheck are present in CI.

An incomplete or skipped conformance run is not an admission pass.

## Portability

The portable core is:

```text
SKILL.md + references/<agent>-tools.md + MCP where applicable
```

The per-agent wrappers are emitted artifacts:

- Claude Code: `.claude-plugin/plugin.json`, commands, agents, hooks
- Codex: `.codex-plugin/plugin.json`, skills, MCP/app config where supported
- GitHub Copilot: `.github/skills/`, `.github/instructions/`, MCP config
- Cursor: `.cursor-plugin/plugin.json`, `.cursor/rules/`, skills where supported

Hooks, HITL, and the Cortex policy layer are host-specific. Adapters should not
pretend these are equivalent across agents. They should emit the closest native
configuration and document degraded behavior.

## External Skill Catalogs

Cortex should not duplicate maintained language catalogs unless it has a
specific internal policy or workflow requirement. Prefer installing or
referencing external catalogs such as Microsoft skills or OpenAI skills for
language/framework-specific guidance, then route to them when available.

## Documentation Authority

Active docs:

- `README.md`: overview and quickstart
- `SPEC.md`: product and architecture contract
- `ROADMAP.md`: staged delivery plan
- `USAGE.md`: install and daily commands
- `CONNECTORS.md`: connector catalog and policy
- `UX.md`: current MVP user flows
- `AGENTS.md`: coding-agent instructions

Archived docs are historical input. They are not implementation authority.

## V1 Done Criteria

V1 is done when:

- one-command install works for a fresh Claude Code user;
- the default catalog contains only admitted MVP plugins/connectors;
- `/implement` works end-to-end on a real test repo;
- `/cortex-verify` catches stale manifests, missing dependencies, and ownership
  conflicts;
- conformance has real golden and adversarial fixtures for MVP plugins;
- at least one skill is emitted and smoke-tested on Claude Code, Codex, Copilot,
  and Cursor;
- docs describe what is implemented, not what is hoped for.
