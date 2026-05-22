#!/usr/bin/env bash
# audit-postuse.sh — platform PostToolUse hook capturing every primitive call.
#
# stdin = Claude Code's hook payload JSON.
# stdout = JSON action ({"action":"proceed"}).
#
# Writes a structured TelemetryEvent to the per-session ndjson buffer at
# .agents/state/telemetry/<date>.ndjson; the buffer is flushed to the durable
# audit sink on SessionEnd.
#
# Performance budget: ≤ 80ms p95 (POSIX shell PostToolUse, per SPEC.md).
# Must be non-bypassable from plugin code (installed via platform/settings/managed.json).

set -euo pipefail

# Fail-open: a broken hook must not block the user.
trap 'echo "{\"action\":\"proceed\"}"; exit 0' ERR

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"action":"proceed"}'
  exit 0
fi

WORKSPACE_ROOT="$(pwd)"
STATE_DIR="$WORKSPACE_ROOT/.agents/state"
mkdir -p "$STATE_DIR/telemetry"

ic_id="$(echo "$input" | jq -r '.invocation_context.invocation_id // .invocation_context_id // "unknown"')"
tool="$(echo "$input" | jq -r '.tool_name // .tool // "unknown"')"
plugin_id="$(echo "$input" | jq -r '.invocation_context.plugin_id // .plugin // ""')"
component_id="$(echo "$input" | jq -r '.invocation_context.component_id // .component // ""')"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
day="$(date -u +%Y-%m-%d)"

# Best-effort token cost extraction. Different tool results surface tokens differently;
# the hook tolerates absence.
tokens="$(echo "$input" | jq -r '.tool_result.token_cost // .token_cost // 0')"
latency_ms="$(echo "$input" | jq -r '.tool_result.latency_ms // .latency_ms // 0')"

event="$(jq -n \
  --arg eid "$ic_id:$tool:$ts" \
  --arg ic "$ic_id" \
  --arg p "${plugin_id:-platform}" \
  --arg c "${component_id:-audit-postuse}" \
  --arg t "$tool" \
  --arg ts "$ts" \
  --argjson tok "${tokens:-0}" \
  --argjson lat "${latency_ms:-0}" \
  '{
    event_id: $eid,
    invocation_context_id: $ic,
    plugin_id: $p,
    component_id: $c,
    level: "info",
    phase: "result",
    message: ("tool=" + $t),
    attributes: {tool_name: $t, token_cost: $tok, latency_ms: $lat},
    timestamp: $ts
  }')"

printf '%s\n' "$event" >> "$STATE_DIR/telemetry/$day.ndjson"
echo '{"action":"proceed"}'
