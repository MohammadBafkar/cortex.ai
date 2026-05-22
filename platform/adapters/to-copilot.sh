#!/usr/bin/env bash
# to-copilot.sh — emit a Copilot CLI package from a canonical Claude Code plugin.
#
# Per ROADMAP.md: emit, don't translate. Manifest is rewritten; skill payloads
# are symlinked. The per-skill `references/copilot-tools.md` files inside each
# skill directory carry the tool-name map; the adapter does NOT rewrite the
# skill body.
#
# Usage:
#   to-copilot.sh <plugin-dir> <out-dir>
#
# Output: <out-dir>/<plugin>/.copilot-plugin/plugin.yml + symlinked skills/.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

src="${1:?usage: to-copilot.sh <plugin-dir> <out-dir>}"
out="${2:?usage: to-copilot.sh <plugin-dir> <out-dir>}"

src="$(cd "$src" && pwd)"
mkdir -p "$out"
out="$(cd "$out" && pwd)"

plugin_name="$(basename "$src")"
plugin_json="$src/.claude-plugin/plugin.json"
contract="$src/.cortex/manifest.json"
[[ -f "$plugin_json" ]] || { echo "to-copilot: missing plugin.json at $plugin_json" >&2; exit 2; }
[[ -f "$contract"    ]] || { echo "to-copilot: missing manifest.json at $contract" >&2; exit 2; }

dest="$out/$plugin_name"
rm -rf "$dest"
mkdir -p "$dest/.copilot-plugin"

# 1. Emit the Copilot manifest from plugin.json + manifest.json.
name="$(jq -r '.name' "$plugin_json")"
version="$(jq -r '.version' "$plugin_json")"
description="$(jq -r '.description' "$plugin_json")"

cat > "$dest/.copilot-plugin/plugin.yml" <<EOF
# Copilot CLI plugin manifest, emitted by platform/adapters/to-copilot.sh.
# Source: $src/.claude-plugin/plugin.json + .cortex/manifest.json.
# Do NOT hand-edit this file — re-run the adapter.

name: $name
version: $version
description: |
  $description

skills_dir: ./skills
EOF

if [[ -d "$src/commands" ]]; then
  echo "commands_dir: ./commands" >> "$dest/.copilot-plugin/plugin.yml"
fi
if [[ -d "$src/agents" ]]; then
  echo "agents_dir: ./agents" >> "$dest/.copilot-plugin/plugin.yml"
fi

# 2. Symlink (or copy if symlinks aren't desired) the payload directories.
for d in skills commands agents hooks; do
  if [[ -d "$src/$d" ]]; then
    ln -s "$src/$d" "$dest/$d"
  fi
done

# 3. Emit a short adapter-notes file.
cat > "$dest/.copilot-plugin/ADAPTER_NOTES.md" <<EOF
# Adapter notes — Copilot port of $name

Emitted by \`platform/adapters/to-copilot.sh\` on $(date -u +%Y-%m-%dT%H:%M:%SZ).
Source plugin: $src
Canonical SKILL.md files are shared via symlink — every change in the
canonical plugin shows up here after the next adapter run.

## Tool-name map

See each skill's \`references/copilot-tools.md\` for the boundary translation.

## What does not port (per ROADMAP.md)

- Platform-owned hooks (PEP, audit-postuse, budget-track) — Copilot uses its
  own permission model; install equivalents via enterprise-managed plugins.
- Composite-artifact review tree under \`.agents/state/reviews/<pr-id>/\` — no
  Copilot equivalent today; degrades to single-reviewer skill.
- Methodology inline composition by name — Copilot dispatches Skills; the
  adapter does NOT inline methodology bodies (the skills are symlinked,
  so the same methodology reference appears in both packages).

## Verification

Run the conformance harness against this port:

    conformance run-golden --agent=copilot-cli $name
EOF

echo "to-copilot: emitted $dest"
echo "  plugin.yml: $dest/.copilot-plugin/plugin.yml"
echo "  skills:     $dest/skills -> $src/skills"
echo "  adapter:    $dest/.copilot-plugin/ADAPTER_NOTES.md"
