#!/usr/bin/env bash
# session-start.sh — platform SessionStart hook.
#
# Responsibilities:
#   1. Create .agents/state/ skeleton if missing (markers/, telemetry/).
#   2. Apply the default .gitignore for .agents/state/ (preserves markers/).
#   3. Initialize the per-session budget file at .agents/state/markers/budget.json.
#   4. Emit a session_start telemetry event.
#
# Performance budget: ≤ 200ms p95 (per SPEC.md).

set -euo pipefail

# $CORTEX_HOME points at the marketplace repo root; the platform sets it
# via managed settings. If unset, derive from this script's location.
if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi
export CORTEX_HOME

WORKSPACE_ROOT="$(pwd)"
STATE_DIR="$WORKSPACE_ROOT/.agents/state"

# Multi-user namespacing (SPEC.md). When CORTEX_MULTI_USER=1
# the workspace state tier is partitioned by user-id; we initialize a per-user
# skeleton under .agents/state/<user-id>/ and surface USER_STATE_DIR to child
# hooks for convenience. The platform-owned markers/ and telemetry/ subdirs
# stay at the workspace root (shared across users for coordination).
if [[ "${CORTEX_MULTI_USER:-0}" == "1" ]]; then
  USER_ID="${CORTEX_USER_ID:-$USER}"
  if [[ -z "$USER_ID" ]]; then
    echo "[cortex] CORTEX_MULTI_USER=1 but neither CORTEX_USER_ID nor \$USER is set." >&2
    exit 1
  fi
  USER_STATE_DIR="$STATE_DIR/$USER_ID"
  mkdir -p "$USER_STATE_DIR" "$STATE_DIR/markers" "$STATE_DIR/telemetry"
  export USER_STATE_DIR
else
  mkdir -p "$STATE_DIR/markers" "$STATE_DIR/telemetry"
fi

# Default .gitignore for state.
if [[ ! -f "$WORKSPACE_ROOT/.agents/.gitignore" ]]; then
  cat > "$WORKSPACE_ROOT/.agents/.gitignore" <<'EOF'
state/**
!state/markers/
!state/markers/**
EOF
fi

# Initialize budget tracker if absent.
budget="$STATE_DIR/markers/budget.json"
if [[ ! -f "$budget" ]]; then
  ceiling="${CORTEX_TOKEN_CEILING:-200000}"
  printf '{"used":0,"ceiling":%s,"warned_60":false}\n' "$ceiling" > "$budget"
fi

# Banner — suppressed in headless mode.
if [[ "${CLAUDE_CODE_NON_INTERACTIVE:-0}" != "1" ]]; then
  echo "[cortex] Session ready. Workspace: $WORKSPACE_ROOT"
fi

# Emit a session_start telemetry event to the buffer; the platform PostToolUse hook
# routes it through audit-append on the next flush (SessionEnd).
ic_id="$(date -u +%Y%m%d-%H%M%S)-$$"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat >> "$STATE_DIR/telemetry/session.ndjson" <<EOF
{"event_id":"$ic_id:session_start","invocation_context_id":"$ic_id","plugin_id":"platform","component_id":"session-start","level":"info","phase":"start","message":"session started","attributes":{"workspace_root":"$WORKSPACE_ROOT"},"timestamp":"$ts"}
EOF

# Stash the IC id so child hooks can correlate.
echo "$ic_id" > "$STATE_DIR/markers/session-ic.txt"
