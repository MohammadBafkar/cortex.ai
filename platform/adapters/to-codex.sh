#!/usr/bin/env bash
# to-codex.sh — emit a Codex package from a canonical Claude Code plugin OR a
# single skill.
#
# Per ROADMAP.md, the first port targets ONE skill (engineering.review-diff)
# rather than the full plugin. This adapter supports both modes:
#
#   to-codex.sh --plugin <plugin-dir> <out-dir>
#   to-codex.sh --skill  <skill-dir>  <out-dir>
#
# Output: <out-dir>/<plugin-or-skill>/.codex-plugin/agents.yaml + symlinked
# payload.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

mode=""
src=""
out=""

case "${1:-}" in
  --plugin) mode="plugin"; src="$2"; out="$3";;
  --skill)  mode="skill";  src="$2"; out="$3";;
  *) echo "usage: to-codex.sh --plugin <plugin-dir> <out-dir>  OR  --skill <skill-dir> <out-dir>" >&2; exit 2;;
esac

[[ -d "$src" ]] || { echo "to-codex: not a directory: $src" >&2; exit 2; }
src="$(cd "$src" && pwd)"
mkdir -p "$out"
out="$(cd "$out" && pwd)"

if [[ "$mode" == "skill" ]]; then
  skill_name="$(basename "$src")"
  # The plugin name is the parent-parent dir name (skills/<name>/SKILL.md → plugin/skills/<name>).
  plugin_name="$(basename "$(dirname "$(dirname "$src")")")"
  dest="$out/$plugin_name-$skill_name"
  rm -rf "$dest"
  mkdir -p "$dest/.codex-plugin" "$dest/skills/$skill_name"

  # Symlink the skill content.
  ln -s "$src/SKILL.md" "$dest/skills/$skill_name/SKILL.md"
  if [[ -d "$src/references" ]]; then
    ln -s "$src/references" "$dest/skills/$skill_name/references"
  fi

  cat > "$dest/.codex-plugin/agents.yaml" <<EOF
# Codex agent definition emitted by platform/adapters/to-codex.sh (--skill mode).
# Source: $src/SKILL.md
# Do NOT hand-edit — re-run the adapter.

agents:
  - name: $plugin_name-$skill_name
    skill_path: skills/$skill_name/SKILL.md
    tool_map_ref: skills/$skill_name/references/codex-tools.md
EOF

  cat > "$dest/.codex-plugin/ADAPTER_NOTES.md" <<EOF
# Adapter notes — Codex port of single skill $plugin_name.$skill_name

Emitted on $(date -u +%Y-%m-%dT%H:%M:%SZ).
Source: $src

## Tool-name map

See \`skills/$skill_name/references/codex-tools.md\`.

## Caveats

- This is a single-skill port (per ROADMAP.md). Cross-bundle composition
  (e.g., dispatching to platform.run-pipeline after review) is NOT included.
  Users who need the full workflow should install the Claude Code port instead.
- Subagent dispatch (\`Task\`) is not portable to Codex. Any imperative
  references to subagents in the SKILL.md body should be rewritten by the
  user as inline procedure.
EOF

  echo "to-codex: emitted skill $plugin_name.$skill_name → $dest"
  exit 0
fi

# Plugin mode.
plugin_name="$(basename "$src")"
plugin_json="$src/.claude-plugin/plugin.json"
[[ -f "$plugin_json" ]] || { echo "to-codex: missing plugin.json" >&2; exit 2; }

dest="$out/$plugin_name"
rm -rf "$dest"
mkdir -p "$dest/.codex-plugin"

name="$(jq -r '.name' "$plugin_json")"
version="$(jq -r '.version' "$plugin_json")"
description="$(jq -r '.description' "$plugin_json")"

cat > "$dest/.codex-plugin/agents.yaml" <<EOF
# Codex package emitted by platform/adapters/to-codex.sh (--plugin mode).
# Source: $src
# Do NOT hand-edit — re-run the adapter.

name: $name
version: $version
description: |
  $description

skills:
EOF

for skill_dir in "$src/skills/"*/; do
  [[ -d "$skill_dir" ]] || continue
  sn="$(basename "$skill_dir")"
  echo "  - name: $name-$sn" >> "$dest/.codex-plugin/agents.yaml"
  echo "    skill_path: skills/$sn/SKILL.md" >> "$dest/.codex-plugin/agents.yaml"
  if [[ -d "$skill_dir/references" ]]; then
    echo "    tool_map_ref: skills/$sn/references/codex-tools.md" >> "$dest/.codex-plugin/agents.yaml"
  fi
done

for d in skills commands; do
  if [[ -d "$src/$d" ]]; then
    ln -s "$src/$d" "$dest/$d"
  fi
done

cat > "$dest/.codex-plugin/ADAPTER_NOTES.md" <<EOF
# Adapter notes — Codex port of plugin $plugin_name

Emitted on $(date -u +%Y-%m-%dT%H:%M:%SZ).
Source: $src

## Tool-name map

Each skill has its own \`references/codex-tools.md\` co-located. Skills
without the references file may not have been validated for Codex
portability; the adapter emits a warning but does not fail.

## Caveats

- Subagent dispatch (\`Task\`) is not portable to Codex. Codex subagents
  launch via the host runtime, not from within a skill body.
- Composite-artifact patterns (e.g., \`.agents/state/reviews/<pr-id>/<contributor>/\`)
  depend on the platform PEP hook; the adapter does NOT install an equivalent.
  Codex packages run with single-bundle write authority.
- The marketplace-internal workflow YAML catalog is Claude Code-specific.
  Codex packages run skills directly; cross-bundle orchestration requires
  custom Codex-side glue.
EOF

echo "to-codex: emitted plugin $plugin_name → $dest"
