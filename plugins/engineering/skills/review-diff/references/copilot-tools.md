# GitHub Copilot CLI tool-name map for `engineering.review-diff`

Boundary translation reference for Copilot CLI. Same role as `codex-tools.md`.

## Tool-name map

| Claude Code | Copilot CLI (native) | Notes |
| --- | --- | --- |
| `Read` | `readFile` | Identical. |
| `Grep` | `search` with `pattern` | Pattern-only mode of search. |
| `Glob` | `search` with `globs` | Globs mode of the same tool. |
| `Bash` | `runShell` | Identical semantics; output streaming differs but the contract is the same. |
| `Edit` | `editFile` | Search/replace semantics match. |
| `Write` | `writeFile` | Identical. |
| `Task` | (custom-agent dispatch) | Copilot dispatches subagents via the Plugin System; the adapter wraps each subagent as a Copilot Custom Agent in the emitted manifest. |

## Frontmatter equivalents

| Claude Code | Copilot CLI |
| --- | --- |
| `allowed-tools: [...]` | `permissions: [...]` (similar shape) |
| `argument-hint` | `argHint` |
| `disable-model-invocation` | (not directly supported; emit as `auto: false` in plugin manifest) |

## Hook lifecycle

Copilot CLI's hook model uses different event names:

| Claude Code | Copilot CLI |
| --- | --- |
| `PreToolUse` | `tool:pre` |
| `PostToolUse` | `tool:post` |
| `SessionStart` | `session:start` |
| `SessionEnd` | `session:stop` |

The platform-owned hooks would be installed via Copilot's `enterprise-managed plugins` mechanism rather than Claude Code's managed settings — see ROADMAP.md

## Not portable

- The `methodology.X` inline composition pattern is Claude Code's interpretation of "read a SKILL.md in current context". Copilot's equivalent is "use a Skill" which dispatches differently — the adapter inlines the methodology body into the emitted skill rather than referencing it by name, which means Copilot users see a larger, less composable skill.
- `marketplace.merge-review`'s composite review depends on per-path `state-ownership.json` enforcement. Copilot has no equivalent; the adapter emits a single-reviewer skill and notes the gap.
