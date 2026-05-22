#!/usr/bin/env bash
# hitl-router.sh — enqueue, decide, expire ApprovalRequest@v1 records.
#
# Per SPEC.md + GOVERNANCE.md The Router is the platform's
# single surface for HITL approvals: router writes requests; humans
# decide via the /approve slash command (which shells into this script);
# expired requests fall through to the per-checkpoint fallback.
#
# Queue layout:
#   .agents/state/markers/approvals/
#     pending/<id>.json     # awaiting decision
#     approved/<id>.json    # decided yes
#     denied/<id>.json      # decided no
#     held/<id>.json        # decided hold-for-now
#     expired/<id>.json     # SLA breached; fallback applied
#
# Each file matches platform/schemas/approval-request.v1.json with an extra
# `decided_by_principal_id` and `decided_at` once moved out of pending/.
#
# Usage:
#   hitl-router.sh enqueue   <approval-json-on-stdin>      # writes to pending/
#   hitl-router.sh list      [--state pending|approved|denied|held|expired]
#   hitl-router.sh decide    <id> approve|deny|hold [--by <principal>]
#   hitl-router.sh expire-overdue                           # sweep cron
#   hitl-router.sh get       <id>

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

WORKSPACE_ROOT="$(pwd)"
QUEUE_DIR="$WORKSPACE_ROOT/.agents/state/markers/approvals"

ensure_dirs() {
  mkdir -p "$QUEUE_DIR"/{pending,approved,denied,held,expired}
}

audit_event() {
  local event="$1"
  local id="$2"
  local extra="${3:-{\}}"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  # Validate `extra` is parseable JSON; fall back to {} silently otherwise.
  if ! printf '%s' "$extra" | jq empty >/dev/null 2>&1; then
    extra='{}'
  fi
  {
    jq -nc \
      --arg event_id "approval-$id-$event-$ts" \
      --arg ic "$id" \
      --arg event "$event" \
      --arg ts "$ts" \
      --argjson extra "$extra" \
      '{event_id:$event_id, invocation_context_id:$ic, plugin_id:"platform",
        component_id:"hitl-router", level:"info", phase:"result",
        message:("approval." + $event), attributes:$extra, timestamp:$ts}' \
      | bash "$CORTEX_HOME/platform/audit/audit-append.sh"
  } 2>/dev/null || true
}

cmd_enqueue() {
  ensure_dirs
  local input id
  input="$(cat)"
  if ! id="$(echo "$input" | jq -r '.request_id // empty')"; then
    echo "hitl-router: input is not valid JSON" >&2; exit 2
  fi
  if [[ -z "$id" ]]; then
    id="req-$(date -u +%Y%m%d-%H%M%S)-$$"
    input="$(echo "$input" | jq --arg id "$id" '.request_id = $id')"
  fi
  local checkpoint
  checkpoint="$(echo "$input" | jq -r '.checkpoint_id // 0')"
  local tier
  tier="$(echo "$input" | jq -r '.checkpoint_tier // "C"')"
  local now
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  enriched="$(echo "$input" | jq --arg now "$now" '.state = "pending" | .created_at = $now')"
  printf '%s\n' "$enriched" > "$QUEUE_DIR/pending/$id.json"
  audit_event "enqueued" "$id" "$(jq -nc --arg cp "$checkpoint" --arg t "$tier" '{checkpoint_id:$cp,tier:$t}')"
  printf '%s\n' "$id"
}

cmd_list() {
  ensure_dirs
  local state="pending"
  if [[ "${1:-}" == "--state" ]]; then state="$2"; shift 2; fi
  if [[ ! -d "$QUEUE_DIR/$state" ]]; then
    echo "hitl-router: no queue state: $state" >&2; exit 2
  fi
  shopt -s nullglob
  for f in "$QUEUE_DIR/$state"/*.json; do
    jq -c '{
      request_id, checkpoint_id, checkpoint_tier, state, sla_hours,
      decider_rbac_groups, created_at, decided_at, decided_by_principal_id,
      summary
    }' "$f"
  done
}

cmd_decide() {
  local id="$1"; shift
  local decision="$1"; shift
  local principal=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --by) principal="$2"; shift 2 ;;
      *) echo "hitl-router: unknown arg: $1" >&2; exit 2 ;;
    esac
  done
  case "$decision" in
    approve|deny|hold) ;;
    *) echo "hitl-router: invalid decision: $decision (expected approve|deny|hold)" >&2; exit 2 ;;
  esac

  local src="$QUEUE_DIR/pending/$id.json"
  if [[ ! -f "$src" ]]; then
    echo "hitl-router: no pending request: $id" >&2; exit 2
  fi

  # SoD: the principal who originated the request cannot decide it.
  if [[ -n "$principal" ]]; then
    origin="$(jq -r '.originated_by // empty' "$src")"
    if [[ -n "$origin" && "$origin" == "$principal" ]]; then
      echo "hitl-router: SoD violation — principal '$principal' originated this request and cannot decide it" >&2
      audit_event "sod_block" "$id" "$(jq -nc --arg p "$principal" '{principal:$p}')"
      exit 1
    fi
  fi

  local target_state
  case "$decision" in
    approve) target_state="approved" ;;
    deny)    target_state="denied"   ;;
    hold)    target_state="held"     ;;
  esac

  local now
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  jq --arg state "$target_state" --arg ts "$now" --arg p "$principal" \
    '.state = $state | .decided_at = $ts | (.decided_by_principal_id = (if $p == "" then null else $p end))' \
    "$src" > "$QUEUE_DIR/$target_state/$id.json"
  rm "$src"

  audit_event "decided" "$id" "$(jq -nc --arg d "$decision" --arg p "$principal" '{decision:$d,principal:$p}')"
  printf '%s decided: %s (by %s)\n' "$id" "$decision" "${principal:-anonymous}"
}

cmd_expire_overdue() {
  ensure_dirs
  local now_epoch
  now_epoch="$(date -u +%s)"
  shopt -s nullglob
  for f in "$QUEUE_DIR/pending"/*.json; do
    local sla_hours created_epoch
    sla_hours="$(jq -r '.sla_hours // 24' "$f")"
    created_epoch="$(python3 -c "
from datetime import datetime
import json, sys
with open('$f') as h:
    obj = json.load(h)
print(int(datetime.fromisoformat(obj['created_at'].rstrip('Z')).timestamp()))
")"
    deadline=$(python3 -c "print($created_epoch + int($sla_hours * 3600))")
    if [[ "$now_epoch" -gt "$deadline" ]]; then
      id="$(basename "$f" .json)"
      now_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      jq --arg ts "$now_iso" '.state = "expired" | .decided_at = $ts | .decided_by_principal_id = null' \
        "$f" > "$QUEUE_DIR/expired/$id.json"
      rm "$f"
      audit_event "expired" "$id" "{}"
      echo "$id"
    fi
  done
}

cmd_get() {
  local id="$1"
  for state in pending approved denied held expired; do
    if [[ -f "$QUEUE_DIR/$state/$id.json" ]]; then
      jq . "$QUEUE_DIR/$state/$id.json"
      return 0
    fi
  done
  echo "hitl-router: no request: $id" >&2; exit 2
}

case "${1:-}" in
  enqueue)         shift; cmd_enqueue "$@" ;;
  list)            shift; cmd_list "$@" ;;
  decide)          shift; cmd_decide "$@" ;;
  expire-overdue)  shift; cmd_expire_overdue "$@" ;;
  get)             shift; cmd_get "$@" ;;
  *)
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
