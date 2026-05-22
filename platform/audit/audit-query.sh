#!/usr/bin/env bash
# audit-query.sh — query the audit log with a jq filter.
#
# Usage:
#   audit-query.sh '<jq-filter>'                # query all days
#   audit-query.sh --day 2026-05-21 '<filter>'  # query one day
#
# Examples:
#   audit-query.sh '.[]'
#   audit-query.sh 'select(.plugin_id == "engineering")'
#   audit-query.sh 'select(.level == "error")'

set -euo pipefail

AUDIT_DIR="${AUDIT_DIR:-$HOME/.claude-plugin/audit}"

if ! command -v jq >/dev/null 2>&1; then
  echo "audit-query: jq required" >&2
  exit 1
fi

day=""
if [[ "${1:-}" == "--day" ]]; then
  day="$2"
  shift 2
fi

filter="${1:-.}"

if [[ -n "$day" ]]; then
  file="$AUDIT_DIR/$day.jsonl"
  [[ -f "$file" ]] || { echo "audit-query: no log for $day" >&2; exit 1; }
  jq -c "$filter" "$file"
else
  # Concatenate all daily files in chronological order.
  if [[ ! -d "$AUDIT_DIR" ]]; then
    echo "audit-query: no audit dir at $AUDIT_DIR" >&2
    exit 1
  fi
  files=$(ls "$AUDIT_DIR"/*.jsonl 2>/dev/null | sort || true)
  if [[ -z "$files" ]]; then
    # No logs yet — succeed with empty output.
    exit 0
  fi
  cat $files | jq -c "$filter"
fi
