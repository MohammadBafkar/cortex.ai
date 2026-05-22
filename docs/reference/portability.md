# Portability Notes

The Cortex portability strategy is based on current public agent/plugin repo
patterns:

- `obra/superpowers`: shared `skills/` with thin `.claude-plugin`,
  `.codex-plugin`, `.cursor-plugin`, `.opencode`, and other host wrappers.
- `microsoft/skills`: selective install of only relevant skills; avoid loading a
  massive catalog into every project.
- `openai/skills`: skills as portable task folders.
- `openai/plugins`: Codex plugins as `.codex-plugin/plugin.json` plus optional
  skills, agents, commands, hooks, MCP/app config, and assets.
- `github/awesome-copilot`: searchable catalog of agents, instructions, skills,
  hooks, workflows, plugins, and MCP tooling.
- Anthropic official/community plugin repos: Claude-native plugin layout and
  marketplace catalog conventions.

## Cortex Rule

Author once in the Cortex source layout. Emit host-native wrappers.

Portable:

- `SKILL.md`
- skill references and assets
- MCP server references where the host supports MCP

Host-specific:

- hooks
- HITL prompts
- audit sinks
- marketplace admission policy
- slash-command manifest format
- subagent runtime semantics

## Target Shapes

```text
dist/claude/plugins/<plugin>/.claude-plugin/plugin.json
dist/codex/plugins/<plugin>/.codex-plugin/plugin.json
dist/copilot/.github/skills/<skill>/
dist/cursor/plugins/<plugin>/.cursor-plugin/plugin.json
```

Do not claim a target is supported until `platform/adapters/verify-emit.sh`
smoke-tests an emitted package on that target.

