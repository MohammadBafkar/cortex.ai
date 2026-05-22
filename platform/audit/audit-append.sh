#!/usr/bin/env bash
# audit-append.sh — append a TelemetryEvent to the daily audit log.
#
# stdin: a single TelemetryEvent JSON line (matches telemetry-event.v1.json).
# stdout: nothing on success; non-zero exit + stderr on failure.
#
# Storage: $AUDIT_DIR (default $HOME/.claude-plugin/audit), one .jsonl file per UTC day.
# Each appended line carries an additional `signature` field that is a SHA-256 of the
# event body (minus signature). MVP1 signature is content-addressed only; opt-in
# ed25519 signing is layered on top in P1 for the artifact classes flagged in
# SPEC.md (ConformanceVerdict, SecurityFinding, ReleaseRecord).

set -euo pipefail

AUDIT_DIR="${AUDIT_DIR:-$HOME/.claude-plugin/audit}"
mkdir -p "$AUDIT_DIR"

event="$(cat)"

if [[ -z "$event" ]]; then
  echo "audit-append: empty input" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "audit-append: jq required" >&2
  exit 1
fi

# Validate the input parses as JSON.
if ! echo "$event" | jq -e . >/dev/null 2>&1; then
  echo "audit-append: invalid JSON input" >&2
  exit 1
fi

# Content-address-hash the event body (without any existing signature) for tamper detection.
body="$(echo "$event" | jq -c 'del(.signature)')"
if command -v sha256sum >/dev/null 2>&1; then
  hash="$(printf '%s' "$body" | sha256sum | awk '{print $1}')"
else
  hash="$(printf '%s' "$body" | shasum -a 256 | awk '{print $1}')"
fi

signed_event="$(echo "$event" | jq --arg h "sha256:$hash" '. + {signature: $h}')"

day="$(date -u +%Y-%m-%d)"
target="$AUDIT_DIR/$day.jsonl"

# Append atomically (best-effort on POSIX). For higher durability, P1 swaps to fsync wrapper.
printf '%s\n' "$signed_event" >> "$target"
