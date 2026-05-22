# CLAUDE.md

Claude Code instructions for this repository.

**The canonical instructions live in [`AGENTS.md`](./AGENTS.md). Read it first.**

`AGENTS.md` covers: what this repo is, the active V1 docs, hard rules
(`.cortex` sidecars, Skill Frontmatter Contract, routing-vs-execution,
workspace-state ownership, host-specific hooks, native + sidecar packaging),
repo layout, how to add a plugin/skill/connector/workflow, and verification
checks.

## Claude Code-specific addenda

These supplement (do not replace) `AGENTS.md`.

- **Native validation:** every `.claude-plugin/plugin.json` must pass `claude plugin validate --strict`. Use it before opening a PR that touches a plugin manifest.
- **Marketplace operations:** `claude /plugin marketplace add ./` adds this repo as a local marketplace. `claude /plugin install <plugin>@cortex` installs from it. `cortex` is the marketplace catalog name; plugin names are bare (`engineering`, `platform`, `marketplace`, `methodology`, …).
- **Hooks:** plugin hooks live in `<plugin>/hooks/hooks.json` with scripts under `<plugin>/hooks/scripts/`. Platform-owned hooks (audit, PEP, session lifecycle) live in `platform/hooks/` and are installed via managed settings — they are non-bypassable.
- **Routing:** use `marketplace.route` when the user gives an open prompt and the correct command/skill is ambiguous. The router plans; the parent session executes.
- **Subagent dispatch:** use subagents as leaf workers. Do not turn a worker subagent into a workflow engine that dispatches further workers.
- **Skill auto-routing:** Claude Code matches user intent against each skill's frontmatter `description`. The Skill Frontmatter Contract in `AGENTS.md` is therefore load-bearing — bad descriptions cause routing failures.

When you find a conflict between `CLAUDE.md` and `AGENTS.md`, `AGENTS.md` wins. Report the conflict.
