#!/usr/bin/env bash
# aggregate-feedback.sh — produce PluginFeedback@v1 per plugin per week.
#
# Per GOVERNANCE.md + ROADMAP.md The platform's PostToolUse hook captures
# every TelemetryEvent into the durable audit sink ($HOME/.claude-plugin/audit).
# This script walks the sink, classifies events into symptom categories, and
# emits one PluginFeedback@v1 envelope per (plugin, week).
#
# Usage:
#   aggregate-feedback.sh                     # last 7 days, all plugins
#   aggregate-feedback.sh --days 30
#   aggregate-feedback.sh --plugin engineering
#   aggregate-feedback.sh --out /tmp/feedback
#
# Output: .agents/state/feedback/<plugin>/<YYYY-MM-DD>.ndjson (one JSON object
# per plugin per run) AND promotion of each envelope to CAS with mutable ref
# `feedback_<plugin>_<window-end>`.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi
export CORTEX_HOME

AUDIT_DIR="${AUDIT_DIR:-$HOME/.claude-plugin/audit}"

days=7
plugin_filter=""
out_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)    days="$2"; shift 2;;
    --plugin)  plugin_filter="$2"; shift 2;;
    --out)     out_dir="$2"; shift 2;;
    *)         echo "aggregate-feedback: unknown arg: $1" >&2; exit 2;;
  esac
done

[[ -n "$out_dir" ]] || out_dir="$(pwd)/.agents/state/feedback"
mkdir -p "$out_dir"

now_utc="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Compute window-start (BSD date doesn't support -d "N days ago", so we use
# python as a portable fallback).
window_start="$(python3 -c "
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc) - timedelta(days=$days)).strftime('%Y-%m-%dT%H:%M:%SZ'))
")"

echo "=== Aggregating PluginFeedback for window [$window_start, $now_utc] ==="

if [[ ! -d "$AUDIT_DIR" ]] || [[ -z "$(ls "$AUDIT_DIR" 2>/dev/null || true)" ]]; then
  echo "aggregate-feedback: empty audit dir at $AUDIT_DIR — nothing to aggregate"
  exit 0
fi

# All audit events in the window. Each daily file contains one JSON object per line.
events_json="$(mktemp)"
trap 'rm -f "$events_json"' EXIT

cat "$AUDIT_DIR"/*.jsonl 2>/dev/null \
  | jq -c --arg ws "$window_start" --arg we "$now_utc" \
      'select(.timestamp >= $ws and .timestamp <= $we)' \
  > "$events_json"

if [[ ! -s "$events_json" ]]; then
  echo "aggregate-feedback: no events in window"
  exit 0
fi

# All plugin ids we saw.
plugins="$(jq -r '.plugin_id' "$events_json" | sort -u | grep -v '^$' || true)"

generated=0
for plugin in $plugins; do
  if [[ -n "$plugin_filter" && "$plugin" != "$plugin_filter" ]]; then
    continue
  fi
  if [[ "$plugin" == "unknown" || "$plugin" == "null" || -z "$plugin" ]]; then
    continue
  fi

  plugin_events="$(jq -c --arg p "$plugin" 'select(.plugin_id == $p)' "$events_json")"

  # Classify into symptoms. Each `jq -c | wc -l` returns 0 cleanly on empty matches
  # because we wrap the grep-equivalent in brace groups (// "" filters falsify empty).
  rerouted="$(printf '%s\n' "$plugin_events"      | { grep -c '"event":"rerouted"' || true; })"
  hitl_overrides="$(printf '%s\n' "$plugin_events"| { grep -c '"phase":"hitl_override"' || true; })"
  injection="$(printf '%s\n' "$plugin_events"     | { grep -c '"trust_label":"untrusted_user_content"' || true; })"
  re_engagement="$(printf '%s\n' "$plugin_events" | { grep -c '"event":"re_engagement"' || true; })"
  conf_regression="$(printf '%s\n' "$plugin_events"|{ grep -c '"event":"conformance_regression"' || true; })"
  budget_warn="$(printf '%s\n' "$plugin_events"   | { grep -c 'token budget at' || true; })"
  budget_block="$(printf '%s\n' "$plugin_events"  | { grep -c 'Token budget exhausted' || true; })"
  pep="$(printf '%s\n' "$plugin_events"           | { grep -c 'pep_block' || true; })"
  nested="$(printf '%s\n' "$plugin_events"        | { grep -c 'nested_dispatch_attempt' || true; })"
  hook_timeout="$(printf '%s\n' "$plugin_events"  | { grep -c '"phase":"hook_timeout"' || true; })"
  perf_overrun="$(printf '%s\n' "$plugin_events"  | { grep -c 'perf_budget_overrun' || true; })"

  # Build the actions list — pure rules-driven, no LLM.
  actions="[]"
  if [[ "$pep" -gt 5 ]]; then
    actions="$(echo "$actions" | jq --arg p "$plugin" \
      '. + [{kind:"permission_review", owner:$p, severity:"major", rationale:"PEP blocks > 5 in window — review permissions / declared write paths"}]')"
  fi
  if [[ "$conf_regression" -gt 0 ]]; then
    actions="$(echo "$actions" | jq --arg p "$plugin" \
      '. + [{kind:"fixture_update", owner:$p, severity:"blocking", rationale:"conformance regression observed"}]')"
  fi
  if [[ "$budget_block" -gt 2 ]]; then
    actions="$(echo "$actions" | jq --arg p "$plugin" \
      '. + [{kind:"skill_revision", owner:$p, severity:"major", rationale:"token budget blocks > 2 in window — skill is too costly"}]')"
  fi
  if [[ "$nested" -gt 0 ]]; then
    actions="$(echo "$actions" | jq --arg p "$plugin" \
      '. + [{kind:"skill_revision", owner:$p, severity:"blocking", rationale:"nested-dispatch attempts observed — SPEC.md violation"}]')"
  fi

  envelope="$(jq -nc \
    --arg plugin "$plugin" \
    --arg ws "$window_start" \
    --arg we "$now_utc" \
    --arg gen "$now_utc" \
    --argjson actions "$actions" \
    --argjson rerouted "$rerouted" \
    --argjson hitl "$hitl_overrides" \
    --argjson injection "$injection" \
    --argjson reeng "$re_engagement" \
    --argjson confreg "$conf_regression" \
    --argjson bw "$budget_warn" \
    --argjson bb "$budget_block" \
    --argjson pep "$pep" \
    --argjson nested "$nested" \
    --argjson hto "$hook_timeout" \
    --argjson po "$perf_overrun" \
    '{
      schema: "PluginFeedback",
      schema_version: "1",
      plugin: $plugin,
      window: {start: $ws, end: $we},
      symptoms: {
        rerouted_invocations: $rerouted,
        hitl_overrides: $hitl,
        prompt_injection_downgrades: $injection,
        re_engagement_triggers: $reeng,
        conformance_regressions: $confreg,
        token_budget_warnings: $bw,
        token_budget_blocks: $bb,
        pep_blocks: $pep,
        nested_dispatch_attempts: $nested,
        hook_timeouts: $hto,
        perf_budget_overruns: $po
      },
      actions: $actions,
      generated_at: $gen
    }')"

  # Sign + write. -c keeps the output single-line (NDJSON-friendly).
  sig="$(printf '%s' "$envelope" | (sha256sum 2>/dev/null || shasum -a 256) | awk '{print $1}')"
  signed="$(printf '%s' "$envelope" | jq -c --arg s "sha256:$sig" '. + {signature: $s}')"

  mkdir -p "$out_dir/$plugin"
  date_tag="$(date -u +%Y-%m-%d)"
  out_file="$out_dir/$plugin/$date_tag.ndjson"
  printf '%s\n' "$signed" >> "$out_file"

  # Promote to CAS + mutable ref.
  tmpf="$(mktemp)"
  printf '%s\n' "$signed" > "$tmpf"
  id="$(bash "$CORTEX_HOME/platform/cas/cas.sh" put "$tmpf")"
  bash "$CORTEX_HOME/platform/cas/cas.sh" put-ref "feedback_${plugin}_${date_tag}" "$id" >/dev/null
  rm -f "$tmpf"

  symptom_count=$((rerouted + hitl_overrides + injection + re_engagement + conf_regression + budget_warn + budget_block + pep + nested + hook_timeout + perf_overrun))
  echo "  $plugin: $symptom_count symptom event(s) → $out_file (CAS:$id)"
  generated=$((generated+1))
done

echo ""
echo "aggregate-feedback: $generated PluginFeedback envelopes produced"
