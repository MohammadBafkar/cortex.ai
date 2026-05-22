#!/usr/bin/env bash
# session-end.sh — platform SessionEnd hook.
#
# Responsibilities:
#   1. Flush .agents/state/telemetry/*.ndjson to the durable audit sink.
#   2. Promote envelopes whose state is `proposed` or `approved` from the
#      workspace tier into the durable CAS.
#   3. Sweep old telemetry files (older than 24h).
#
# Performance budget: ≤ 2s p95 for a typical interactive session; ≤ 30s for a
# long CI session. SessionEnd is not on the critical path of user latency.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

WORKSPACE_ROOT="$(pwd)"
STATE_DIR="$WORKSPACE_ROOT/.agents/state"
[[ -d "$STATE_DIR" ]] || exit 0

AUDIT_APPEND="$CORTEX_HOME/platform/audit/audit-append.sh"
CAS="$CORTEX_HOME/platform/cas/cas.sh"

# 1. Flush telemetry.
if [[ -d "$STATE_DIR/telemetry" ]]; then
  for f in "$STATE_DIR/telemetry"/*.ndjson; do
    [[ -f "$f" ]] || continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      printf '%s' "$line" | bash "$AUDIT_APPEND" || {
        echo "session-end: failed to append event (continuing)" >&2
      }
    done < "$f"
  done
fi

# 2. Promote envelopes. Walk every authoritative subtree and look for envelopes
#    with state ∈ {proposed, approved}. Push them through cas put + put-ref.
if command -v jq >/dev/null 2>&1; then
  for owned_dir in prs reviews adrs tests runs builds intakes blueprints adrs incidents releases deprecations findings/security findings/privacy findings/a11y; do
    base="$STATE_DIR/$owned_dir"
    [[ -d "$base" ]] || continue
    while IFS= read -r -d '' f; do
      state="$(jq -r '.state // "draft"' "$f" 2>/dev/null || echo draft)"
      if [[ "$state" == "proposed" || "$state" == "approved" ]]; then
        id="$(bash "$CAS" put "$f")"
        # Mutable reference: latest_<owned-dir>_<artifact-id>
        artifact_id="$(jq -r '.artifact_id // .pr_id // .adr_id // .test_run_id // .'"$(basename "$f" .json)"'' "$f" 2>/dev/null || echo "unknown")"
        ref_name="latest_${owned_dir//\//_}_${artifact_id}"
        bash "$CAS" put-ref "$ref_name" "$id" >/dev/null
        if [[ "${CLAUDE_CODE_NON_INTERACTIVE:-0}" != "1" ]]; then
          echo "[cortex] Promoted $f -> CAS:$id (ref $ref_name)" >&2
        fi
      fi
    done < <(find "$base" -type f -name "*.json" -print0 2>/dev/null)
  done
fi

# 3. Sweep telemetry older than 24h. Keep current session's session.ndjson.
find "$STATE_DIR/telemetry" -name "*.ndjson" -type f -mtime +1 -delete 2>/dev/null || true
