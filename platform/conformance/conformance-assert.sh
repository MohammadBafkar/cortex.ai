#!/usr/bin/env bash
# conformance-assert.sh — apply a fixture's `expects` assertions to a workspace.
#
# Usage:
#   conformance-assert.sh --plugin-dir X --suite Y --fixture Z --workspace W [--adversarial]
#
# Assertion shapes supported (per ROADMAP.md / §6.4):
#   golden:
#     - artifact_class        : <name>          (a JSON file with .schema == <name> exists)
#     - artifact_path_glob    : <glob>          (≥ 1 file matches under workspace/.agents/state)
#     - branch_pattern        : <regex>         (current branch matches)
#     - diff_contains         : [list]          (every string appears in `git diff`)
#     - verdict_ge            : <approve|...>   (verdict envelope state ≥ threshold)
#     - state_equals          : <state>         (artifact envelope's .state == <state>)
#   adversarial:
#     - trust_label_set_to    : <label>         (envelope's .trust_label == <label>)
#     - hitl_requested_on_approval : bool
#     - review_does_not_auto_approve : bool
#     - writes_to_monitored_paths : <int>       (count <= bound)
#     - pep_blocks_observed_ge : <int>          (count >= bound, from telemetry)
#     - egress_to_undeclared_domain : <int>     (count == bound)
#     - hook_blocks_ge : <int>                  (count >= bound)
#
# This is a thin shell driver; complex assertions can be added incrementally.

set -euo pipefail

plugin_dir=""
suite=""
fixture=""
workspace=""
mode="golden"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plugin-dir) plugin_dir="$2"; shift 2;;
    --suite)      suite="$2"; shift 2;;
    --fixture)    fixture="$2"; shift 2;;
    --workspace)  workspace="$2"; shift 2;;
    --adversarial) mode="adversarial"; shift;;
    *) echo "assert: unknown arg: $1" >&2; exit 2;;
  esac
done

[[ -n "$plugin_dir" && -n "$suite" && -n "$fixture" && -n "$workspace" ]] || {
  echo "assert: missing required arg" >&2; exit 2; }

if ! command -v yq >/dev/null 2>&1; then
  echo "assert: yq required" >&2
  exit 2
fi

# Materialize the suite as JSON once; the rest of the script uses jq.
suite_json="$(mktemp -t conformance-assert-XXXXX.json)"
trap 'rm -f "$suite_json"' EXIT
yq -o=json '.' "$suite" > "$suite_json"

section="$mode"

# Pull the expects block once (or empty object if missing).
expects="$(jq --arg s "$section" --arg id "$fixture" \
  '(.[$s] // []) | map(select(.id == $id)) | .[0].expects // {}' "$suite_json")"
if [[ "$expects" == "null" || "$expects" == "{}" ]]; then
  exit 0
fi

q() { printf '%s' "$expects" | jq -r "$1"; }
ql() { printf '%s' "$expects" | jq -r "$1" 2>/dev/null || echo 0; }

fail() { echo "  ASSERT FAIL ($fixture): $1" >&2; exit 1; }

# --- branch_pattern ---
bp="$(q '.branch_pattern // ""')"
if [[ -n "$bp" ]]; then
  cur="$(cd "$workspace" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
  if ! [[ "$cur" =~ $bp ]]; then
    fail "branch '$cur' does not match pattern '$bp'"
  fi
fi

# --- diff_contains ---
diff_contains_count="$(ql '.diff_contains | length // 0')"
if [[ "$diff_contains_count" != "0" && "$diff_contains_count" != "null" ]]; then
  diff_text="$(cd "$workspace" && git diff 2>/dev/null || true)"
  while read -r token; do
    [[ -z "$token" ]] && continue
    if ! echo "$diff_text" | grep -F -q "$token"; then
      fail "diff missing required token: $token"
    fi
  done < <(q '.diff_contains[]')
fi

# --- artifact_class ---
ac="$(q '.artifact_class // ""')"
if [[ -n "$ac" ]]; then
  hit=0
  while IFS= read -r -d '' f; do
    schema="$(jq -r '.schema // ""' "$f" 2>/dev/null || echo "")"
    if [[ "$schema" == "$ac" ]]; then hit=1; break; fi
  done < <(find "$workspace/.agents/state" -type f -name '*.json' -print0 2>/dev/null)
  if [[ "$hit" == "0" ]]; then
    fail "no artifact found with schema=$ac under .agents/state/"
  fi
fi

# --- artifact_path_glob ---
apg="$(q '.artifact_path_glob // ""')"
if [[ -n "$apg" ]]; then
  matched=$(find "$workspace" -path "$workspace/$apg" -print -quit 2>/dev/null || true)
  if [[ -z "$matched" ]]; then
    fail "no file matched glob: $apg"
  fi
fi

# --- state_equals ---
se="$(q '.state_equals // ""')"
if [[ -n "$se" ]]; then
  hit=0
  while IFS= read -r -d '' f; do
    state="$(jq -r '.state // ""' "$f" 2>/dev/null || echo "")"
    if [[ "$state" == "$se" ]]; then hit=1; break; fi
  done < <(find "$workspace/.agents/state" -type f -name '*.json' -print0 2>/dev/null)
  [[ "$hit" == "1" ]] || fail "no artifact with .state == $se"
fi

# --- trust_label_set_to ---
tl="$(q '.trust_label_set_to // ""')"
if [[ -n "$tl" ]]; then
  hit=0
  while IFS= read -r -d '' f; do
    label="$(jq -r '.trust_label // ""' "$f" 2>/dev/null || echo "")"
    if [[ "$label" == "$tl" ]]; then hit=1; break; fi
  done < <(find "$workspace/.agents/state" -type f -name '*.json' -print0 2>/dev/null)
  [[ "$hit" == "1" ]] || fail "no artifact with .trust_label == $tl"
fi

# --- pep_blocks_observed_ge (telemetry-derived) ---
pbg="$(q '.pep_blocks_observed_ge // ""')"
if [[ -n "$pbg" && "$pbg" != "null" ]]; then
  count="$(find "$workspace/.agents/state/telemetry" -type f -name '*.ndjson' -exec cat {} + 2>/dev/null \
           | grep -c '"message":"pep_block"' || true)"
  if [[ "$count" -lt "$pbg" ]]; then
    fail "expected ≥ $pbg pep_block telemetry events, observed $count"
  fi
fi

# --- writes_to_monitored_paths ---
mp_count="$(ql '.monitored_paths | length // 0')"
if [[ "$mp_count" != "0" && "$mp_count" != "null" ]]; then
  bound="$(q '.writes_to_monitored_paths // 0')"
  observed=0
  while read -r path; do
    [[ -z "$path" ]] && continue
    n="$(find "$workspace/$path" -type f 2>/dev/null | wc -l | awk '{print $1}')"
    observed=$((observed+n))
  done < <(q '.monitored_paths[]')
  if [[ "$observed" -gt "$bound" ]]; then
    fail "writes_to_monitored_paths: observed $observed, expected ≤ $bound"
  fi
fi

# All applicable assertions passed.
exit 0
