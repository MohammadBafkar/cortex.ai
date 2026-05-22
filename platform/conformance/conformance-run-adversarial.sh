#!/usr/bin/env bash
# conformance-run-adversarial.sh — execute the adversarial-fixture suite.
#
# Per ROADMAP.md / §6.6. Adversarial fixtures assert on properties that should
# NOT happen — prompt-injection containment, cross-path write attempts, permission
# overreach, self-approval attempts, stale artifact references.
#
# Structure mirrors conformance-run-golden.sh; the difference is in the assertion
# shape (we expect blocks, trust-label downgrades, and refusal to act).
#
# When `claude` is not on PATH the harness reports the fixture inventory and
# skips runtime execution.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

# Argument parsing — mirrors conformance-run-golden.sh.
agent="claude"
plugin_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      agent="$2"; shift 2 ;;
    --agent=*)
      agent="${1#--agent=}"; shift ;;
    -h|--help)
      echo "usage: conformance-run-adversarial.sh [--agent claude|copilot-cli|codex-cli] <plugin-dir>"
      exit 0 ;;
    --)
      shift; plugin_dir="${1:-}"; shift ;;
    *)
      if [[ -z "$plugin_dir" ]]; then plugin_dir="$1"; shift
      else echo "run-adversarial: unexpected arg: $1" >&2; exit 2
      fi ;;
  esac
done
if [[ -z "$plugin_dir" ]]; then
  echo "usage: conformance-run-adversarial.sh [--agent <name>] <plugin-dir>" >&2
  exit 2
fi
case "$agent" in
  claude|copilot-cli|codex-cli) ;;
  *) echo "run-adversarial: unknown agent '$agent'" >&2; exit 2 ;;
esac

case "$agent" in
  claude)      AGENT_CLI="${AGENT_CLI:-claude}" ;;
  copilot-cli) AGENT_CLI="${AGENT_CLI:-gh-copilot}" ;;
  codex-cli)   AGENT_CLI="${AGENT_CLI:-codex}" ;;
esac

plugin_dir="${plugin_dir%/}"
plugin_name="$(basename "$plugin_dir")"

suite="$plugin_dir/.cortex/conformance.yaml"
if [[ ! -f "$suite" ]]; then
  echo "run-adversarial: no conformance.yaml at $suite" >&2
  exit 2
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "run-adversarial: yq not on PATH; cannot read conformance.yaml" >&2
  exit 2
fi

# Materialize the suite as JSON once; the rest of the script uses jq.
suite_json="$(mktemp -t conformance-suite-XXXXX.json)"
trap 'rm -f "$suite_json"' EXIT
yq -o=json '.' "$suite" > "$suite_json"

echo "=== conformance run-adversarial: $plugin_name (agent: $agent) ==="

count="$(jq -r '.adversarial | length // 0' "$suite_json")"
if [[ "$count" == "null" || "$count" == "0" ]]; then
  echo "run-adversarial: no adversarial fixtures declared"
  exit 0
fi

if ! command -v "$AGENT_CLI" >/dev/null 2>&1; then
  echo "run-adversarial: $agent CLI ('$AGENT_CLI') not on PATH; SKIPPING runtime execution."
  echo "  Fixture inventory ($count adversarial):"
  jq -r '.adversarial[] | "    - " + .id + " (kind: " + (.kind // "n/a") + ")"' "$suite_json"
  echo ""
  exit 0
fi

# Plugin-installed precheck — same logic as conformance-run-golden.sh.
case "$agent" in
  claude)      plugin_cache_root="${CLAUDE_PLUGINS_CACHE:-$HOME/.claude/plugins}" ;;
  copilot-cli) plugin_cache_root="${COPILOT_CLI_PLUGINS:-$HOME/.config/gh-copilot/plugins}" ;;
  codex-cli)   plugin_cache_root="${CODEX_CLI_PLUGINS:-$HOME/.codex/plugins}" ;;
esac
plugin_installed=0
if [[ -d "$plugin_cache_root" ]]; then
  if find "$plugin_cache_root" -maxdepth 4 -type d -name "$plugin_name" -print -quit 2>/dev/null | grep -q .; then
    plugin_installed=1
  fi
fi
if [[ "$plugin_installed" == "0" ]]; then
  echo "run-adversarial: plugin '$plugin_name' not found in $plugin_cache_root; SKIPPING runtime."
  echo "  To exercise on claude: claude /plugin marketplace add $CORTEX_HOME && claude /plugin install $plugin_name@cortex"
  echo "  Per-host translations are documented under references/per-host-agent/ in each capability skill."
  echo "  Fixture inventory ($count adversarial):"
  jq -r '.adversarial[] | "    - " + .id + " (kind: " + (.kind // "n/a") + ")"' "$suite_json"
  exit 0
fi

passed=0
failed=0

while read -r fixture_id; do
  [[ -z "$fixture_id" ]] && continue
  kind="$(jq -r --arg id "$fixture_id" '.adversarial[] | select(.id == $id) | .kind // ""' "$suite_json")"
  prompt="$(jq -r --arg id "$fixture_id" '.adversarial[] | select(.id == $id) | .prompt // ""' "$suite_json")"
  scratch="$(mktemp -d -t conformance-adv-XXXXX)"
  (
    cd "$scratch"
    git init -q 2>/dev/null
    mkdir -p .agents/state/markers
    if [[ -n "$prompt" ]]; then
      case "$agent" in
        claude)
          "$AGENT_CLI" --plugin "$plugin_name" --headless -p "$prompt" >/dev/null 2>&1 || true ;;
        copilot-cli)
          printf '%s\n' "$prompt" | "$AGENT_CLI" suggest --target shell >/dev/null 2>&1 || true ;;
        codex-cli)
          "$AGENT_CLI" exec -p "$prompt" >/dev/null 2>&1 || true ;;
      esac
    fi
  )

  if bash "$CORTEX_HOME/platform/conformance/conformance-assert.sh" \
       --plugin-dir "$plugin_dir" \
       --suite "$suite" \
       --fixture "$fixture_id" \
       --workspace "$scratch" \
       --adversarial >/dev/null 2>&1; then
    echo "  PASS  $fixture_id  (kind: $kind)"
    passed=$((passed+1))
  else
    echo "  FAIL  $fixture_id  (kind: $kind)"
    failed=$((failed+1))
  fi
  rm -rf "$scratch"
done < <(jq -r '.adversarial[].id' "$suite_json")

echo ""
echo "run-adversarial: $passed passed, $failed failed (total $count)"
if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
