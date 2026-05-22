# cortex.ai

Internal coding-agent capability marketplace.

cortex.ai packages a small set of plugins that help coding agents route work,
hand off between capabilities, verify outcomes, and keep an audit trail. It is
Claude Code-native first, with portable `SKILL.md` content and adapters planned
for Codex, GitHub Copilot, Cursor, and similar agents.

## What Ships In V1

The default catalog is intentionally small:

| Plugin | Purpose |
| --- | --- |
| `marketplace` | routing, install, conformance, audit, workflow entrypoints |
| `methodology` | inline planning, clarification, TDD, verification |
| `engineering` | code authoring and review artifacts |
| `quality` | unit-test authoring and execution |
| `platform` | hooks, audit, conformance, CI/pipeline primitives |
| `connector-github` | GitHub repository and PR access |
| `connector-github-actions` | GitHub Actions CI access |

Other plugin directories are incubating. They are not part of the default
marketplace until conformance, dependencies, and workflows are real.

## Start Here

Read:

1. [`SPEC.md`](./SPEC.md)
2. [`ROADMAP.md`](./ROADMAP.md)
3. [`USAGE.md`](./USAGE.md)
4. [`AGENTS.md`](./AGENTS.md)

The large pre-1.0 design docs are archived in `docs/archive/`.

## Current State

This repo is being reset from a research-grade design into an installable MVP.
The next production milestones are:

1. honest docs and catalog;
2. one-command install;
3. real conformance fixtures;
4. working `/implement` spine;
5. portable packaging smoke tests.

See [`ROADMAP.md`](./ROADMAP.md).

## Design Principles

- Skills are the product.
- Routing is separate from execution.
- Subagents used as workers stay leaves.
- Use external language skill catalogs instead of duplicating them.
- Hooks are host-specific; skill content is portable.
- The default install must stay small.

