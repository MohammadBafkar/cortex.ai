# GitHub Copilot Instructions

**Canonical instructions for any AI agent working in this repository live in [`AGENTS.md`](../AGENTS.md). Read it first.**

`AGENTS.md` covers: what this repo is, the active V1 docs, hard rules
(`.cortex` sidecars, Skill Frontmatter Contract, routing-vs-execution,
workspace-state ownership, host-specific hooks, native + sidecar packaging),
repo layout, how to add a plugin/skill/connector/workflow, and verification
checks.

## Copilot-specific addenda

These supplement (do not replace) `AGENTS.md`.

- **Skill format is cross-agent.** `SKILL.md` with `name` + `description` frontmatter is the open standard supported by Copilot CLI, Copilot in VS Code, and Copilot cloud agent. The richer Skill Frontmatter Contract this repo enforces (Use when / Do NOT use when / Inputs / Outputs / `type` / `produces_authoritative_artifacts`) is a strict superset — Copilot will accept it without complaint and ignore unknown fields.
- **MCP servers are portable.** Any connector plugin in this repo exposes itself as an MCP server. Copilot CLI and Copilot IDE both consume MCP natively.
- **Hooks are NOT portable.** Claude Code's hook event names and registration mechanism differ from Copilot's lifecycle. `ROADMAP.md` covers the emit-don't-translate adapter strategy.
- **Plugin manifest format differs.** This repo's `.claude-plugin/plugin.json` is Claude-native. A Copilot port should emit GitHub-native skills and instructions from the shared source.

When you find a conflict between this file and `AGENTS.md`, `AGENTS.md` wins. Report the conflict.
