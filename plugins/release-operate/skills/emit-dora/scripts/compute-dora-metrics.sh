#!/usr/bin/env bash
# compute-dora-metrics.sh — compute DORA four-plus-one from the durable audit
# sink + the CAS-promoted ReleaseRecord / IncidentRecord history.
#
# Invoked by release-operate.emit-dora (or directly for ad-hoc reports).
#
# Usage:
#   compute-dora-metrics.sh [--days N] [--service NAME]
#
# Defaults: --days 28 (the standard DORA window), all services.
#
# Output: a single-line NDJSON DORAMetricsReport on stdout. Useful via:
#   compute-dora-metrics.sh --days 28 | jq .

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../../../../../" && pwd)"
fi

AUDIT_DIR="${AUDIT_DIR:-$HOME/.claude-plugin/audit}"
CAS_ROOT="${CAS_ROOT:-$HOME/.claude-plugin/cas}"

days=28
service=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) days="$2"; shift 2;;
    --service) service="$2"; shift 2;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "compute-dora-metrics: jq required" >&2; exit 1
fi

now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
window_start="$(python3 -c "
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc) - timedelta(days=$days)).strftime('%Y-%m-%dT%H:%M:%SZ'))
")"

# ---------------------------------------------------------------------------
# Pull ReleaseRecord + IncidentRecord + Postmortem envelopes from CAS via
# the mutable references emitted by SessionEnd.
# ---------------------------------------------------------------------------
collect_artifact_class() {
  local prefix="$1"     # e.g., latest_releases_  or  latest_incidents_

  # The CAS refs index gives us (name -> sha) pairs. We read each referenced
  # blob from CAS and emit the JSON to stdout, one per line.
  if [[ -d "$CAS_ROOT/refs" ]]; then
    for ref in "$CAS_ROOT/refs"/${prefix}*; do
      [[ -f "$ref" ]] || continue
      sha="$(cat "$ref")"
      blob="$CAS_ROOT/objects/$sha"
      [[ -f "$blob" ]] && cat "$blob"
    done
  fi
}

releases="$(collect_artifact_class 'latest_releases_' | jq -c --arg ws "$window_start" --arg we "$now" \
  'select((.produced_at // .signed_at // "") >= $ws and (.produced_at // .signed_at // "") <= $we)' 2>/dev/null || true)"

incidents="$(collect_artifact_class 'latest_incidents_' | jq -c --arg ws "$window_start" --arg we "$now" \
  'select((.opened_at // .produced_at // "") >= $ws and (.opened_at // .produced_at // "") <= $we)' 2>/dev/null || true)"

# Filter by service if requested.
if [[ -n "$service" ]]; then
  releases="$(printf '%s\n' "$releases" | jq -c --arg s "$service" 'select(.service == $s)')"
  incidents="$(printf '%s\n' "$incidents" | jq -c --arg s "$service" 'select(.service == $s)')"
fi

# ---------------------------------------------------------------------------
# Compute the four-plus-one metrics.
# ---------------------------------------------------------------------------
release_count="$(printf '%s\n' "$releases" | grep -c . || true)"
incident_count="$(printf '%s\n' "$incidents" | grep -c . || true)"

# Deploy frequency: releases per day.
if [[ "$days" -gt 0 ]]; then
  df="$(python3 -c "print(round($release_count / $days, 3))")"
else
  df=0
fi

# Lead time: median(release.gates_passed_at - artifact.commit_at), seconds → hours.
lt_median_hours="$(printf '%s\n' "$releases" | jq -s '
  [.[] | select(.commit_at and .gates_passed_at) |
    ((.gates_passed_at | fromdateiso8601) - (.commit_at | fromdateiso8601)) / 3600]
  | if length == 0 then 0
    else (sort | .[length / 2 | floor])
    end' 2>/dev/null || echo 0)"

# Change failure rate: releases with an incident referenced as `caused_by_release`
# divided by total releases.
caused_failures="$(printf '%s\n' "$incidents" | jq -s '[.[] | select(.caused_by_release != null)] | length' 2>/dev/null || echo 0)"
if [[ "$release_count" -gt 0 ]]; then
  cfr="$(python3 -c "print(round($caused_failures / $release_count, 4))")"
else
  cfr=0
fi

# MTTR: median(incident.resolved_at - incident.opened_at), seconds → hours.
mttr_median_hours="$(printf '%s\n' "$incidents" | jq -s '
  [.[] | select(.resolved_at and .opened_at) |
    ((.resolved_at | fromdateiso8601) - (.opened_at | fromdateiso8601)) / 3600]
  | if length == 0 then 0
    else (sort | .[length / 2 | floor])
    end' 2>/dev/null || echo 0)"

# Reliability: average SLO compliance fraction over the window. We pull from the
# audit log's `slo_compliance_pct` attribute on TelemetryEvents emitted by
# release-operate.observe.
reliability="$(cat "$AUDIT_DIR"/*.jsonl 2>/dev/null \
  | jq -s --arg ws "$window_start" --arg we "$now" '
      [.[] | select(.timestamp >= $ws and .timestamp <= $we and .attributes.slo_compliance_pct)
            | .attributes.slo_compliance_pct]
      | if length == 0 then null else (add / length) end' 2>/dev/null || echo null)"

# ---------------------------------------------------------------------------
# Archetype assignment per the 2025 DORA AI Capabilities Model.
# (Rules-driven; no LLM judgment, no fabricated label.)
# ---------------------------------------------------------------------------
archetype="$(python3 -c "
df, lt, cfr, mttr = $df, $lt_median_hours, $cfr, $mttr_median_hours
# Crude thresholds aligned to the 2025 report's archetypes.
if df >= 1 and lt <= 24 and cfr <= 0.15 and mttr <= 1:
    print('harmonious')
elif df >= 0.2 and lt <= 168 and cfr <= 0.3:
    print('progressing')
elif df < 0.05 or lt > 720 or cfr > 0.5:
    print('regressing')
else:
    print('foundational')
")"

# ---------------------------------------------------------------------------
# Emit the report.
# ---------------------------------------------------------------------------
jq -nc \
  --arg window_start "$window_start" \
  --arg now "$now" \
  --arg service "${service:-all}" \
  --argjson df "$df" \
  --argjson lt "$lt_median_hours" \
  --argjson cfr "$cfr" \
  --argjson mttr "$mttr_median_hours" \
  --argjson reliability "$reliability" \
  --argjson rc "$release_count" \
  --argjson ic "$incident_count" \
  --arg archetype "$archetype" \
  '{
    schema: "DORAMetricsReport",
    schema_version: "1",
    window: {start: $window_start, end: $now, days: '"$days"'},
    service: $service,
    metrics: {
      deploy_frequency_per_day: $df,
      lead_time_for_changes_hours_median: $lt,
      change_failure_rate: $cfr,
      mean_time_to_restore_hours_median: $mttr,
      reliability_slo_compliance: $reliability
    },
    inputs: {
      release_count: $rc,
      incident_count: $ic
    },
    archetype: $archetype
  }'
