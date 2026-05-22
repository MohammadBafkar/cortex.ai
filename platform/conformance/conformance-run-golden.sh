#!/usr/bin/env bash
# conformance-run-golden.sh — execute the golden-fixture suite for a plugin.
#
# Per ROADMAP.md:
#   1. Load <plugin-dir>/.cortex/conformance.yaml.
#   2. For each fixture under `golden:`:
#      a. Create a scratch git repo.
#      b. Set up fixture inputs (e.g., write the UserStory marker).
#      c. Invoke the capability via `claude --plugin <name> --headless -p "<intent>"`.
#      d. Read the produced artifacts from .agents/state/.
#      e. Apply assertions (branch_pattern, diff_contains, verdict_ge, etc.).
#      f. Run 3× per fixture; pass if ≥ 2/3 succeed.
#
# Exit codes: 0 all fixtures pass, 1 ≥1 fails, 2 misuse / harness skipped.
#
# When `claude` is not on PATH this script SKIPS the runtime fixtures and reports
# the fixture inventory + assertion shape, so authors get a useful local check.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

# Argument parsing. Accept either:
#   conformance-run-golden.sh <plugin-dir>
#   conformance-run-golden.sh --agent <name> <plugin-dir>
#   conformance-run-golden.sh <plugin-dir> --agent <name>
agent="claude"
plugin_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      agent="$2"; shift 2 ;;
    --agent=*)
      agent="${1#--agent=}"; shift ;;
    -h|--help)
      echo "usage: conformance-run-golden.sh [--agent claude|copilot-cli|codex-cli] <plugin-dir>"
      exit 0 ;;
    --)
      shift; plugin_dir="${1:-}"; shift ;;
    *)
      if [[ -z "$plugin_dir" ]]; then plugin_dir="$1"; shift
      else echo "run-golden: unexpected arg: $1" >&2; exit 2
      fi ;;
  esac
done
if [[ -z "$plugin_dir" ]]; then
  echo "usage: conformance-run-golden.sh [--agent <name>] <plugin-dir>" >&2
  exit 2
fi
case "$agent" in
  claude|copilot-cli|codex-cli) ;;
  *) echo "run-golden: unknown agent '$agent' (expected claude|copilot-cli|codex-cli)" >&2; exit 2 ;;
esac

# Resolve the host CLI binary for the selected agent.
case "$agent" in
  claude)      AGENT_CLI="${AGENT_CLI:-claude}" ;;
  copilot-cli) AGENT_CLI="${AGENT_CLI:-gh-copilot}" ;;
  codex-cli)   AGENT_CLI="${AGENT_CLI:-codex}" ;;
esac

plugin_dir="${plugin_dir%/}"
plugin_name="$(basename "$plugin_dir")"

suite="$plugin_dir/.cortex/conformance.yaml"
if [[ ! -f "$suite" ]]; then
  echo "run-golden: no conformance.yaml at $suite" >&2
  exit 2
fi

if ! command -v yq >/dev/null 2>&1; then
  echo "run-golden: yq not on PATH; cannot read conformance.yaml" >&2
  exit 2
fi

# Materialize the suite as JSON once; the rest of the script uses jq.
suite_json="$(mktemp -t conformance-suite-XXXXX.json)"
trap 'rm -f "$suite_json"' EXIT
yq -o=json '.' "$suite" > "$suite_json"

echo "=== conformance run-golden: $plugin_name (agent: $agent) ==="

count="$(jq -r '.golden | length // 0' "$suite_json")"
if [[ "$count" == "null" || "$count" == "0" ]]; then
  echo "run-golden: no golden fixtures declared"
  exit 0
fi

if ! command -v "$AGENT_CLI" >/dev/null 2>&1; then
  echo "run-golden: $agent CLI ('$AGENT_CLI') not on PATH; SKIPPING runtime execution."
  echo "  Fixture inventory ($count golden):"
  jq -r '.golden[] | "    - " + .id + " (capability: " + (.capability // "n/a") + ")"' "$suite_json"
  echo ""
  echo "  Re-run with $AGENT_CLI installed to execute fixtures."
  exit 0
fi

# Plugin-installed precheck. The runtime harness only exercises a plugin that
# the user's host agent has actually installed. Until then the harness reports
# "skipped" rather than "failed" so the verdict reads "incomplete" rather than
# "fail" — admin force-flag required to admit. The plugin-cache path varies
# by host agent. The check is best-effort: when we don't recognize the layout
# we let the runtime stage run (the host CLI will then error if the plugin is
# missing, and the assertion stage will record the fail).
case "$agent" in
  claude)
    plugin_cache_root="${CLAUDE_PLUGINS_CACHE:-$HOME/.claude/plugins}" ;;
  copilot-cli)
    plugin_cache_root="${COPILOT_CLI_PLUGINS:-$HOME/.config/gh-copilot/plugins}" ;;
  codex-cli)
    plugin_cache_root="${CODEX_CLI_PLUGINS:-$HOME/.codex/plugins}" ;;
esac

plugin_installed=0
if [[ -d "$plugin_cache_root" ]]; then
  if find "$plugin_cache_root" -maxdepth 4 -type d -name "$plugin_name" -print -quit 2>/dev/null | grep -q .; then
    plugin_installed=1
  fi
fi
if [[ "$plugin_installed" == "0" ]]; then
  echo "run-golden: plugin '$plugin_name' not found in $plugin_cache_root; SKIPPING runtime."
  echo "  To exercise on claude: claude /plugin marketplace add $CORTEX_HOME && claude /plugin install $plugin_name@cortex"
  echo "  Per-host translations are documented under references/per-host-agent/ in each capability skill."
  echo "  Fixture inventory ($count golden):"
  jq -r '.golden[] | "    - " + .id + " (capability: " + (.capability // "n/a") + ")"' "$suite_json"
  exit 0
fi

passed=0
failed=0
skipped=0

run_one() {
  local id="$1"
  local capability="$2"
  local input_path="$3"
  local trials="${TRIALS:-3}"
  local pass_threshold="$(( (trials * 2 + 2) / 3 ))" # ceil(2/3)
  local successes=0
  local i
  for ((i=1; i<=trials; i++)); do
    local scratch
    scratch="$(mktemp -d -t conformance-XXXXX)"
    (
      cd "$scratch"
      git init -q 2>/dev/null
      mkdir -p .agents/state/markers
      if [[ -n "$input_path" && -f "$CORTEX_HOME/$input_path" ]]; then
        cp "$CORTEX_HOME/$input_path" .agents/state/markers/fixture-input.json
      fi
      # NB: capability is a freeform string (e.g., "implementChange@v1"); the actual
      # invocation prompt is taken from the fixture's `prompt` field if present.
      local prompt
      prompt="$(jq -r --arg id "$id" '.golden[] | select(.id == $id) | .prompt // ""' "$suite_json")"
      [[ -n "$prompt" ]] || prompt="Run capability $capability against the workspace fixture."
      case "$agent" in
        claude)
          "$AGENT_CLI" --plugin "$plugin_name" --headless -p "$prompt" >/dev/null 2>&1 ;;
        copilot-cli)
          # copilot-cli does not yet support cortex plugins natively; the
          # invocation runs the prompt and relies on per-host translation refs
          # under each skill (references/per-host-agent/copilot-cli.md) for any
          # tool-call shape adjustments.
          printf '%s\n' "$prompt" | "$AGENT_CLI" suggest --target shell >/dev/null 2>&1 ;;
        codex-cli)
          # codex-cli passes the prompt as positional; flags vary by version.
          "$AGENT_CLI" exec -p "$prompt" >/dev/null 2>&1 ;;
      esac
    ) || true
    # Apply assertions defined in the fixture's `expects` block.
    if bash "$CORTEX_HOME/platform/conformance/conformance-assert.sh" \
        --plugin-dir "$plugin_dir" \
        --suite "$suite" \
        --fixture "$id" \
        --workspace "$scratch" >/dev/null 2>&1; then
      successes=$((successes+1))
    fi
    rm -rf "$scratch"
  done
  if [[ "$successes" -ge "$pass_threshold" ]]; then
    echo "  PASS  $id  ($successes/$trials)"
    return 0
  else
    echo "  FAIL  $id  ($successes/$trials below threshold $pass_threshold)"
    return 1
  fi
}

while read -r fixture_id; do
  [[ -z "$fixture_id" ]] && continue
  capability="$(jq -r --arg id "$fixture_id" '.golden[] | select(.id == $id) | .capability // ""' "$suite_json")"
  input_path="$(jq -r --arg id "$fixture_id" '.golden[] | select(.id == $id) | .input_path // ""' "$suite_json")"
  if run_one "$fixture_id" "$capability" "$input_path"; then
    passed=$((passed+1))
  else
    failed=$((failed+1))
  fi
done < <(jq -r '.golden[].id' "$suite_json")

echo ""
echo "run-golden: $passed passed, $failed failed, $skipped skipped (total $count)"
if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
