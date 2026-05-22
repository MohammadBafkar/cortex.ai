#!/usr/bin/env bash
# check-admission.sh — pre-flight gate for `/plugin install <plugin>@cortex`.
#
# Loads the latest ConformanceVerdict@v1 for the plugin from CAS via the
# mutable reference `verdict_<plugin>_<version>`. Emits OK / WARN / BLOCK
# based on the verdict state + the flags passed in.
#
# Usage:
#   check-admission.sh <plugin-name>
#   check-admission.sh <plugin-name> --force-incomplete-admission
#
# Exit codes:
#   0  pass — verdict is `pass`, or `incomplete` with the force flag.
#   1  block — verdict is `fail` (no force flag bypasses this).
#   2  incomplete — verdict is `incomplete`, no force flag; admission paused.
#   3  no verdict — no signed verdict found at all. Run conformance first.
#   4  misuse — missing args or env.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

plugin_name="${1:-}"
force=0
shift || true
for arg in "$@"; do
  case "$arg" in
    --force-incomplete-admission) force=1 ;;
    *) echo "check-admission: unknown arg: $arg" >&2; exit 4 ;;
  esac
done

if [[ -z "$plugin_name" ]]; then
  echo "usage: check-admission.sh <plugin-name> [--force-incomplete-admission]" >&2
  exit 4
fi

plugin_dir="$CORTEX_HOME/plugins/$plugin_name"
if [[ ! -d "$plugin_dir" ]]; then
  echo "check-admission: plugin '$plugin_name' not found at $plugin_dir" >&2
  exit 4
fi

version="$(jq -r '.version' "$plugin_dir/.cortex/manifest.json")"
ref_name="verdict_${plugin_name}_${version}"

# Resolve the verdict via the CAS reference.
cas="$CORTEX_HOME/platform/cas/cas.sh"
if ! sha="$(bash "$cas" resolve "$ref_name" 2>/dev/null)"; then
  jq -nc --arg name "$plugin_name" --arg version "$version" --arg ref "$ref_name" \
    '{verdict:"none", plugin:$name, version:$version, ref:$ref,
      message:"No signed verdict found. Run `conformance produce-verdict` first."}'
  exit 3
fi

verdict_body="$(bash "$cas" get "$sha")"
verdict="$(echo "$verdict_body" | jq -r '.verdict')"
signed_at="$(echo "$verdict_body" | jq -r '.signed_at')"

case "$verdict" in
  pass)
    jq -nc --arg name "$plugin_name" --arg version "$version" \
          --arg sha "$sha" --arg signed_at "$signed_at" \
      '{verdict:"pass", plugin:$name, version:$version, cas_id:$sha, signed_at:$signed_at,
        message:"Verdict is `pass`. Admission allowed."}'
    exit 0
    ;;
  incomplete)
    if [[ "$force" == "1" ]]; then
      jq -nc --arg name "$plugin_name" --arg version "$version" \
            --arg sha "$sha" --arg signed_at "$signed_at" \
        '{verdict:"incomplete", plugin:$name, version:$version, cas_id:$sha, signed_at:$signed_at,
          force_flag:true,
          message:"Verdict is `incomplete` (runtime fixtures skipped). Force-flag set — admission allowed under admin override. Audit trail captured."}'
      exit 0
    fi
    jq -nc --arg name "$plugin_name" --arg version "$version" \
          --arg sha "$sha" --arg signed_at "$signed_at" \
      '{verdict:"incomplete", plugin:$name, version:$version, cas_id:$sha, signed_at:$signed_at,
        message:"Verdict is `incomplete`. Runtime fixtures have not run (likely because the plugin was not yet installed when the verdict was produced). Install the plugin first, re-run `conformance produce-verdict`, then re-attempt admission. To bypass, pass --force-incomplete-admission (admin only)."}'
    exit 2
    ;;
  fail)
    failures="$(echo "$verdict_body" | jq -c '.scores')"
    jq -nc --arg name "$plugin_name" --arg version "$version" \
          --arg sha "$sha" --arg signed_at "$signed_at" \
          --argjson scores "$failures" \
      '{verdict:"fail", plugin:$name, version:$version, cas_id:$sha, signed_at:$signed_at,
        scores:$scores,
        message:"Verdict is `fail`. Admission BLOCKED. No force flag bypasses a failed verdict; fix the failing fixtures and re-run conformance."}'
    exit 1
    ;;
  *)
    jq -nc --arg name "$plugin_name" --arg version "$version" --arg v "$verdict" \
      '{verdict:$v, plugin:$name, version:$version,
        message:"Verdict has an unknown state. Treat as BLOCKED and investigate."}'
    exit 1
    ;;
esac
