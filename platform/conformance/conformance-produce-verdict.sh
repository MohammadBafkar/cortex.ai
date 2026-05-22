#!/usr/bin/env bash
# conformance-produce-verdict.sh — emit a signed ConformanceVerdict@v1.
#
# Runs the full sequence (validate, golden, adversarial, perf) inside this
# script so we know whether each step actually passed; emits a verdict
# matching schemas/conformance-verdict.v1.json. Promotes the verdict to CAS
# and a mutable reference `verdict_<plugin>_<version>` for the marketplace
# catalog to resolve.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

# Argument parsing — mirrors run-golden/run-adversarial.
agent="claude"
plugin_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      agent="$2"; shift 2 ;;
    --agent=*)
      agent="${1#--agent=}"; shift ;;
    -h|--help)
      echo "usage: conformance-produce-verdict.sh [--agent claude|copilot-cli|codex-cli] <plugin-dir>"
      exit 0 ;;
    *)
      if [[ -z "$plugin_dir" ]]; then plugin_dir="$1"; shift
      else echo "produce-verdict: unexpected arg: $1" >&2; exit 2
      fi ;;
  esac
done
if [[ -z "$plugin_dir" ]]; then
  echo "usage: conformance-produce-verdict.sh [--agent <name>] <plugin-dir>" >&2
  exit 2
fi
case "$agent" in
  claude|copilot-cli|codex-cli) ;;
  *) echo "produce-verdict: unknown agent '$agent'" >&2; exit 2 ;;
esac

plugin_dir="${plugin_dir%/}"
plugin_name="$(basename "$plugin_dir")"

contract="$plugin_dir/.cortex/manifest.json"
[[ -f "$contract" ]] || { echo "produce-verdict: missing manifest.json" >&2; exit 2; }
plugin_version="$(jq -r '.version' "$contract")"

run_step() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "pass"
  else
    rc=$?
    if [[ "$rc" == "0" ]]; then echo "pass"; else echo "fail"; fi
  fi
}

# Re-run each step, capturing exit code without aborting our own pipeline.
HERE="$CORTEX_HOME/platform/conformance"

set +e
bash "$HERE/conformance-validate.sh" "$plugin_dir" >/tmp/cv-validate.$$.log 2>&1
validate_rc=$?
bash "$HERE/conformance-run-golden.sh" --agent "$agent" "$plugin_dir" >/tmp/cv-golden.$$.log 2>&1
golden_rc=$?
bash "$HERE/conformance-run-adversarial.sh" --agent "$agent" "$plugin_dir" >/tmp/cv-adv.$$.log 2>&1
adv_rc=$?
bash "$HERE/conformance-check-perf.sh" "$plugin_dir" >/tmp/cv-perf.$$.log 2>&1
perf_rc=$?
set -e

validate="pass"; [[ "$validate_rc" -ne 0 ]] && validate="fail"
perf="pass"; [[ "$perf_rc" -ne 0 ]] && perf="fail"

# golden / adversarial skip when claude isn't on PATH OR the plugin isn't
# installed in the user's Claude Code instance. The skip path exits 0; the
# log contains "SKIPPING".
golden_skipped=$(grep -c "SKIPPING" /tmp/cv-golden.$$.log || true)
adv_skipped=$(grep -c "SKIPPING" /tmp/cv-adv.$$.log || true)

extract_counts() {
  local log="$1"
  local p f s
  p="$(grep -cE '^  PASS  ' "$log" || true)"
  f="$(grep -cE '^  FAIL  ' "$log" || true)"
  if [[ "$(grep -c 'SKIPPING' "$log" || true)" -gt 0 ]]; then
    s="$(grep -cE '^    - ' "$log" || true)"
  else
    s=0
  fi
  printf '{"passed":%s,"failed":%s,"skipped":%s}' "$p" "$f" "$s"
}

golden_obj="$(extract_counts /tmp/cv-golden.$$.log)"
adv_obj="$(extract_counts /tmp/cv-adv.$$.log)"

# Compute a fixtures_hash over the entire conformance.yaml + every SKILL.md content,
# so any drift in fixtures or skill bodies invalidates the verdict.
fixture_files=(
  "$plugin_dir/.cortex/conformance.yaml"
)
while IFS= read -r f; do fixture_files+=("$f"); done < <(find "$plugin_dir/skills" -name SKILL.md -print)

fixtures_hash_input="$(cat "${fixture_files[@]}" 2>/dev/null)"
if command -v sha256sum >/dev/null 2>&1; then
  fixtures_hash="sha256:$(printf '%s' "$fixtures_hash_input" | sha256sum | awk '{print $1}')"
else
  fixtures_hash="sha256:$(printf '%s' "$fixtures_hash_input" | shasum -a 256 | awk '{print $1}')"
fi

# Overall verdict:
#   "fail"       — any step that ran returned non-zero.
#   "incomplete" — runtime fixtures skipped (e.g., plugin not installed yet) but
#                  no actual failures observed. Marketplace admission can still
#                  proceed under an admin force-flag; default install is blocked
#                  until verdict ∈ {pass}.
#   "pass"       — everything ran and everything passed.
overall="pass"
if [[ "$validate" == "fail" ]] || [[ "$perf" == "fail" ]]; then
  overall="fail"
fi
if [[ "$golden_rc" -ne 0 && "$golden_skipped" -eq 0 ]]; then overall="fail"; fi
if [[ "$adv_rc" -ne 0 && "$adv_skipped" -eq 0 ]]; then overall="fail"; fi
if [[ "$overall" == "pass" && ( "$golden_skipped" -gt 0 || "$adv_skipped" -gt 0 ) ]]; then
  overall="incomplete"
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

verdict_json="$(jq -nc \
  --arg name "$plugin_name" \
  --arg version "$plugin_version" \
  --arg verdict "$overall" \
  --arg validate "$validate" \
  --arg perf "$perf" \
  --argjson golden "$golden_obj" \
  --argjson adv "$adv_obj" \
  --arg fixtures_hash "$fixtures_hash" \
  --arg signed_at "$ts" \
  --arg agent "$agent" \
  '{
    schema: "ConformanceVerdict",
    schema_version: "1",
    plugin: {name: $name, version: $version},
    agent: $agent,
    verdict: $verdict,
    scores: {validate: $validate, golden: $golden, adversarial: $adv, perf: $perf},
    fixtures_hash: $fixtures_hash,
    signed_at: $signed_at
  }')"

# MVP1 signature = sha256 of the verdict body. P1 swaps to ed25519 via the trust authority.
sig="$(printf '%s' "$verdict_json" | (sha256sum 2>/dev/null || shasum -a 256) | awk '{print $1}')"
verdict_signed="$(printf '%s' "$verdict_json" | jq --arg s "sha256:$sig" '. + {signature: $s}')"

# Promote to CAS + mutable reference.
tmpfile="$(mktemp)"
printf '%s\n' "$verdict_signed" > "$tmpfile"
id="$(bash "$CORTEX_HOME/platform/cas/cas.sh" put "$tmpfile")"
# Ref name is per-agent so claude / copilot-cli / codex-cli verdicts coexist.
# For backward compat the `claude` agent also takes the unsuffixed name.
ref_name="verdict_${plugin_name}_${plugin_version}_${agent}"
bash "$CORTEX_HOME/platform/cas/cas.sh" put-ref "$ref_name" "$id" >/dev/null
if [[ "$agent" == "claude" ]]; then
  bash "$CORTEX_HOME/platform/cas/cas.sh" put-ref "verdict_${plugin_name}_${plugin_version}" "$id" >/dev/null
fi
rm -f "$tmpfile" /tmp/cv-validate.$$.log /tmp/cv-golden.$$.log /tmp/cv-adv.$$.log /tmp/cv-perf.$$.log

echo "=== ConformanceVerdict: $plugin_name@$plugin_version (agent: $agent) ==="
printf '%s\n' "$verdict_signed" | jq .
echo ""
echo "Promoted to CAS:$id (ref $ref_name)"

case "$overall" in
  pass)       exit 0 ;;
  incomplete) exit 0 ;;
  fail)       exit 1 ;;
esac
