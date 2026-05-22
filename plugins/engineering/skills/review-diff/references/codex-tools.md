# Codex tool-name map for `engineering.review-diff`

This is the boundary translation reference for OpenAI Codex. The canonical
SKILL.md is authored in Claude Code tool vocabulary; when this skill is
emitted into a Codex package via `platform/adapters/to-codex.sh`, Codex reads
this file to map our tool names to native ones.

## Tool-name map

| Claude Code | Codex (native) | Notes |
| --- | --- | --- |
| `Read` | `read_file` | Identical semantics. |
| `Grep` | `search` with `--regex` | Codex's search takes a regex flag. |
| `Glob` | `search` with `--paths` | Same tool, different mode. |
| `Bash` | `shell` | Identical semantics; PR-create / push patterns map 1:1. |
| `Edit` | `apply_patch` | Codex's patch tool takes a unified-diff input rather than search/replace. The adapter rewrites Edit calls as apply_patch in the emitted skill. |
| `Write` | `apply_patch` (new-file mode) | Same as Edit but with `--new-file`. |
| `Task` | (not supported as nested) | Codex subagents launch via the host runtime, not from within a skill. The orchestration shift is documented in §Portability of `ARCHITECTURE.md` §13. |

## Frontmatter equivalents

| Claude Code | Codex |
| --- | --- |
| `allowed-tools: [Read, Grep, ...]` | `tools: [read_file, search, ...]` |
| `disable-model-invocation` | `auto_route: false` |
| `type: capability \| methodology` | (Codex doesn't honor this — preserved for cross-host coherence) |

## Hook lifecycle

| Claude Code | Codex |
| --- | --- |
| `PreToolUse` | `before_tool` |
| `PostToolUse` | `after_tool` |
| `SessionStart` | `on_session_start` |
| `SessionEnd` | `on_session_end` |

## Not portable

- The platform-owned PEP hook (`platform/hooks/permission-pep.sh`) is Claude Code-specific. Codex has its own permission model — the equivalent (which the adapter must wire) is `policies/file_write_paths`.
- The composite-artifact `/review` workflow assumes `marketplace.route` is admitted. Codex has no equivalent today; the adapter emits a degraded single-reviewer skill.
