#!/usr/bin/env bash
# budget-track.sh — platform PostToolUse hook tracking per-session token usage.
#
# Reads token cost from the tool result payload, decrements a per-session counter
# at .agents/state/markers/budget.json (initialized by session-start.sh), and:
#   - emits a warning to stderr at the 60% threshold (once per session);
#   - fails closed at the 100% threshold ({"action":"block"} on the next call).
#
# Performance budget: ≤ 80ms p95.

set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"action":"proceed"}'
  exit 0
fi

WORKSPACE_ROOT="$(pwd)"
budget="$WORKSPACE_ROOT/.agents/state/markers/budget.json"

# If session-start never ran (e.g., CI invocation), initialize lazily.
if [[ ! -f "$budget" ]]; then
  mkdir -p "$(dirname "$budget")"
  ceiling="${CORTEX_TOKEN_CEILING:-200000}"
  printf '{"used":0,"ceiling":%s,"warned_60":false}\n' "$ceiling" > "$budget"
fi

# Total tokens for this tool call: input + output (Claude Code surfaces both).
tokens="$(echo "$input" | jq -r '
  (.tool_result.token_cost // 0) +
  (.tool_result.input_tokens // 0) +
  (.tool_result.output_tokens // 0)
')"

if [[ -z "$tokens" || "$tokens" == "null" ]]; then
  tokens=0
fi

# Update the counter.
tmp="$(mktemp)"
jq --argjson t "$tokens" '
  .used = (.used + $t)
' "$budget" > "$tmp" && mv "$tmp" "$budget"

used="$(jq -r '.used' "$budget")"
ceiling="$(jq -r '.ceiling' "$budget")"
warned_60="$(jq -r '.warned_60' "$budget")"

# Avoid division by zero on a corrupted budget file.
if [[ "$ceiling" -le 0 ]]; then
  echo '{"action":"proceed"}'
  exit 0
fi

pct=$(( used * 100 / ceiling ))

if [[ "$pct" -ge 100 ]]; then
  msg="Token budget exhausted ($used / $ceiling). Run /reset-budget to clear, or raise CORTEX_TOKEN_CEILING for this workspace."
  jq -nc --arg m "$msg" '{action:"block", message:$m}'
  exit 1
fi

if [[ "$pct" -ge 60 && "$warned_60" != "true" ]]; then
  if [[ "${CLAUDE_CODE_NON_INTERACTIVE:-0}" != "1" ]]; then
    echo "[cortex] WARN: token budget at ${pct}% (${used} / ${ceiling}). Will fail closed at 100%." >&2
  fi
  tmp="$(mktemp)"
  jq '.warned_60 = true' "$budget" > "$tmp" && mv "$tmp" "$budget"
fi

echo '{"action":"proceed"}'
