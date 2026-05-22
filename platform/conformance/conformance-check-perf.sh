#!/usr/bin/env bash
# conformance-check-perf.sh — perf regression guard.
#
# Per ROADMAP.md: load Phase-2 baseline at platform/conformance/perf-baseline.json,
# measure the plugin's hook latencies + (when runtime is available) session start,
# slash-command dispatch, fan-out — fail if any p95 exceeds 1.5× target.
#
# At MVP1 we measure only the hook scripts directly (they're deterministic and
# don't need Claude Code to time). Workflow-level perf is measured in Phase 5
# once the workflows ship.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

plugin_dir="${1:?usage: conformance-check-perf.sh <plugin-dir>}"
plugin_dir="${plugin_dir%/}"
plugin_name="$(basename "$plugin_dir")"

baseline="$CORTEX_HOME/platform/conformance/perf-baseline.json"
if [[ ! -f "$baseline" ]]; then
  echo "check-perf: no baseline at $baseline; skipping"
  exit 0
fi

echo "=== conformance check-perf: $plugin_name ==="

# Find shell hooks declared by this plugin. Declared with empty-array initializer
# so the [[ ${#arr[@]} -eq 0 ]] check works under set -u even when no hooks exist.
hook_scripts=()
while IFS= read -r -d '' s; do
  hook_scripts+=("$s")
done < <(find "$plugin_dir/hooks/scripts" -type f -name '*.sh' -print0 2>/dev/null)

if [[ "${#hook_scripts[@]}" -eq 0 ]]; then
  echo "check-perf: no shell hooks to measure (plugin ships no hooks)"
  echo ""
  echo "check-perf: PASS"
  exit 0
fi

# Time each script with an empty JSON payload, 5 runs each, take max.
target_p95_ms="$(jq -r '.pretooluse_shell_p95_ms // 80' "$baseline")"

over_budget=0
for script in "${hook_scripts[@]}"; do
  rel="${script#$plugin_dir/}"
  max_ms=0
  for ((i=1; i<=5; i++)); do
    if command -v gdate >/dev/null 2>&1; then
      start_ns="$(gdate +%s%N)"
      echo '{}' | bash "$script" >/dev/null 2>&1 || true
      end_ns="$(gdate +%s%N)"
      ms=$(( (end_ns - start_ns) / 1000000 ))
    elif date +%N 2>/dev/null | grep -q '^[0-9]\+$'; then
      start_ns="$(date +%s%N)"
      echo '{}' | bash "$script" >/dev/null 2>&1 || true
      end_ns="$(date +%s%N)"
      ms=$(( (end_ns - start_ns) / 1000000 ))
    else
      # macOS BSD date has only second precision. Use python as a fallback.
      ms="$(python3 -c "
import subprocess, time
t0 = time.perf_counter()
subprocess.run(['bash','$script'], input='{}', text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
print(int((time.perf_counter() - t0) * 1000))
")"
    fi
    if [[ "$ms" -gt "$max_ms" ]]; then max_ms="$ms"; fi
  done
  budget_ms=$(( target_p95_ms * 3 / 2 ))
  if [[ "$max_ms" -gt "$budget_ms" ]]; then
    echo "  FAIL  $rel  max=${max_ms}ms exceeds ${budget_ms}ms (target_p95=${target_p95_ms}ms × 1.5)"
    over_budget=$((over_budget+1))
  else
    echo "  ok    $rel  max=${max_ms}ms (target_p95=${target_p95_ms}ms × 1.5 = ${budget_ms}ms)"
  fi
done

echo ""
if [[ "$over_budget" -gt 0 ]]; then
  echo "check-perf: FAIL — $over_budget hook script(s) over budget"
  exit 1
fi
echo "check-perf: PASS"
