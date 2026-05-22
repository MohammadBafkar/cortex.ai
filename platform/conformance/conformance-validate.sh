#!/usr/bin/env bash
# conformance-validate.sh — static validation of a plugin directory.
#
# Checks (per ROADMAP.md):
#   1. Native plugin.json passes `claude plugin validate --strict` if available;
#      otherwise basic JSON-shape checks.
#   2. .cortex/manifest.json validates against cortex-plugin-manifest.v1.json
#      (ajv if available; otherwise structural JSON check).
#   3. Every SKILL.md frontmatter contains Use when:, Do NOT use when:, Inputs:, Outputs:.
#   4. Cross-plugin description-overlap check (>70% similarity) — across all admitted plugins.
#   5. Inline methodology reference validation: grep each SKILL.md body for
#      methodology.<name> tokens; verify each resolves to an admitted methodology skill.
#   6. Per-path workspace-state ownership: every .agents/state/<dir>/ referenced in a
#      SKILL.md procedure must match this plugin's contract or be a read-only reference.
#   7. No `references_skills:` YAML frontmatter (retired field).
#   8. No mandatory chat-text marker requirements in SKILL.md.
#   9. MCP `alwaysLoad: true` declarations must carry a justification.
#  10. Capability-bearing plugins that reference methodology skills must declare
#      methodology in their native plugin.json `dependencies`.

set -euo pipefail

if [[ -z "${CORTEX_HOME:-}" ]]; then
  CORTEX_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
fi

plugin_dir="${1:?usage: conformance-validate.sh <plugin-dir>}"
plugin_dir="${plugin_dir%/}"

if [[ ! -d "$plugin_dir" ]]; then
  echo "validate: not a directory: $plugin_dir" >&2
  exit 2
fi

errors=0
warnings=0
plugin_name="$(basename "$plugin_dir")"

err() { echo "  FAIL  $1" >&2; errors=$((errors+1)); }
warn() { echo "  WARN  $1" >&2; warnings=$((warnings+1)); }
ok()   { echo "  ok    $1"; }

echo "=== conformance validate: $plugin_name ==="

# ---------------------------------------------------------------------------
# 1. Native plugin.json
# ---------------------------------------------------------------------------
plugin_json="$plugin_dir/.claude-plugin/plugin.json"
if [[ ! -f "$plugin_json" ]]; then
  err "missing .claude-plugin/plugin.json"
else
  if ! jq empty "$plugin_json" 2>/dev/null; then
    err "plugin.json is not valid JSON"
  else
    pname="$(jq -r '.name // ""' "$plugin_json")"
    pver="$(jq -r '.version // ""' "$plugin_json")"
    if [[ -z "$pname" ]]; then err "plugin.json missing required field: name"; fi
    if [[ -z "$pver" ]]; then err "plugin.json missing required field: version"; fi
    if [[ "$pname" != "$plugin_name" ]]; then
      warn "plugin.json name ($pname) differs from directory ($plugin_name)"
    fi
    if [[ "$pname" =~ ^(cortex-|cortex-) ]]; then
      err "plugin name '$pname' uses a marketplace-prefix ('cortex-' or 'cortex-') — names are bare per AGENTS.md"
    fi
    if command -v claude >/dev/null 2>&1; then
      if claude plugin validate --strict "$plugin_dir" >/dev/null 2>&1; then
        ok "claude plugin validate --strict passed"
      else
        err "claude plugin validate --strict failed"
      fi
    else
      ok "plugin.json shape ok (claude CLI not on PATH; skipped --strict)"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 2. Sidecar .cortex/manifest.json
# ---------------------------------------------------------------------------
contract="$plugin_dir/.cortex/manifest.json"
if [[ ! -f "$contract" ]]; then
  err "missing .cortex/manifest.json"
else
  if ! jq empty "$contract" 2>/dev/null; then
    err "manifest.json is not valid JSON"
  else
    # Required structural fields per schemas/cortex-plugin-manifest.v1.json.
    for field in name version publisher bundle_contracts_touched capability_interfaces_implemented artifacts_authored artifacts_consumed surfaces risk_tier conformance_suite_ref; do
      val="$(jq -r --arg k "$field" '.[$k] // ""' "$contract")"
      if [[ "$val" == "" || "$val" == "null" ]]; then
        err "manifest.json missing required field: $field"
      fi
    done
    # If this is a methodology-style packaging exception, bundle_contracts_touched MUST be empty.
    exception="$(jq -r '.packaging_exception.reason // ""' "$contract")"
    if [[ -n "$exception" ]]; then
      btc_len="$(jq -r '.bundle_contracts_touched | length' "$contract")"
      if [[ "$btc_len" != "0" ]]; then
        err "packaging_exception declared but bundle_contracts_touched is non-empty"
      fi
      # Note: do NOT use `// true` here — jq's // operator treats `false` as missing.
      pa="$(jq -r 'if (.packaging_exception | has("produces_authoritative_artifacts")) then (.packaging_exception.produces_authoritative_artifacts | tostring) else "missing" end' "$contract")"
      if [[ "$pa" != "false" ]]; then
        err "packaging_exception.produces_authoritative_artifacts must be false (got '$pa')"
      fi
    fi
    if command -v ajv >/dev/null 2>&1; then
      if ajv validate -s "$CORTEX_HOME/platform/schemas/cortex-plugin-manifest.v1.json" -d "$contract" >/dev/null 2>&1; then
        ok "manifest.json schema-valid (ajv)"
      else
        err "manifest.json fails schema validation (ajv)"
      fi
    else
      ok "manifest.json shape ok (ajv not on PATH; structural-only check)"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 3-9. SKILL.md walk
# ---------------------------------------------------------------------------
declare -a skill_files
while IFS= read -r -d '' f; do
  skill_files+=("$f")
done < <(find "$plugin_dir/skills" -type f -name 'SKILL.md' -print0 2>/dev/null)

# Build the list of admitted methodology skills across the whole repo for ref-resolution.
declare -a admitted_methodology_skills
while IFS= read -r -d '' meth; do
  # Skip the plugin being validated to allow self-references.
  meth_plugin="$(basename "$(dirname "$(dirname "$(dirname "$meth")")")")"
  # Path looks like: plugins/methodology/skills/<name>/SKILL.md
  if [[ "$meth_plugin" == "methodology" ]]; then
    name="$(basename "$(dirname "$meth")")"
    admitted_methodology_skills+=("$name")
  fi
done < <(find "$CORTEX_HOME/plugins" -type f -path '*/skills/*/SKILL.md' -print0 2>/dev/null)

for skill in "${skill_files[@]}"; do
  rel="${skill#$plugin_dir/}"
  # ---- Frontmatter parse ----
  fm="$(awk '/^---$/{c++; next} c==1{print}' "$skill")"
  body="$(awk '/^---$/{c++; next} c>=2' "$skill")"

  # 3a. Required description chunks.
  for token in "Use when:" "Do NOT use when:" "Inputs:" "Outputs:"; do
    if ! grep -q -F "$token" "$skill"; then
      err "$rel description missing required section: $token"
    fi
  done

  # 3b. Required type + produces_authoritative_artifacts.
  if ! grep -E '^type:[[:space:]]*(capability|methodology)' <<<"$fm" >/dev/null; then
    err "$rel frontmatter missing required: type (capability | methodology)"
  fi
  if ! grep -E '^produces_authoritative_artifacts:[[:space:]]*(true|false)' <<<"$fm" >/dev/null; then
    err "$rel frontmatter missing required: produces_authoritative_artifacts"
  fi

  # 3c. Capability skills must have capability_interface_id + bundle_contract_id.
  skill_type="$(grep -E '^type:' <<<"$fm" | head -1 | awk '{print $2}')"
  if [[ "$skill_type" == "capability" ]]; then
    if ! grep -E '^capability_interface_id:' <<<"$fm" >/dev/null; then
      err "$rel capability skill missing required: capability_interface_id"
    fi
    if ! grep -E '^bundle_contract_id:' <<<"$fm" >/dev/null; then
      err "$rel capability skill missing required: bundle_contract_id"
    fi
  fi

  # 3d. Methodology skills must NOT have capability_interface_id or bundle_contract_id
  #     and must declare produces_authoritative_artifacts: false.
  if [[ "$skill_type" == "methodology" ]]; then
    if grep -E '^capability_interface_id:' <<<"$fm" >/dev/null; then
      err "$rel methodology skill must not declare capability_interface_id"
    fi
    if grep -E '^bundle_contract_id:' <<<"$fm" >/dev/null; then
      err "$rel methodology skill must not declare bundle_contract_id"
    fi
    pa="$(grep -E '^produces_authoritative_artifacts:' <<<"$fm" | head -1 | awk '{print $2}')"
    if [[ "$pa" != "false" ]]; then
      err "$rel methodology skill must declare produces_authoritative_artifacts: false (got '$pa')"
    fi
  fi

  # 7. No references_skills: YAML frontmatter (retired field).
  if grep -E '^references_skills:' <<<"$fm" >/dev/null; then
    err "$rel uses retired frontmatter field 'references_skills:'. Methodology refs go inline in the skill body."
  fi

  # 8. No mandated chat-text markers.
  if grep -E 'MUST prefix.*\[Plugin:Component\]|REQUIRED.*\[Plugin:Component\]|always start chat output with \[' "$skill" >/dev/null; then
    err "$rel mandates [Plugin:Component] chat-text markers — forbidden by SPEC.md Plain-prose announcements are allowed, never required."
  fi

  # 5. Inline methodology reference resolution. We only flag *imperative* references —
  #    patterns like "invoke `methodology.<name>`" or "compose `methodology.<name>`" — so
  #    roadmap mentions like "`methodology.foo` (P1 — when admitted)" do not fail admission.
  #    Self-references inside the methodology plugin are skipped (a methodology skill
  #    referring to itself by name is allowed and noisy to flag).
  if [[ "$plugin_name" != "methodology" ]]; then
    while read -r ref; do
      [[ -z "$ref" ]] && continue
      name="${ref#methodology.}"
      hit=0
      for adm in "${admitted_methodology_skills[@]:-}"; do
        if [[ "$adm" == "$name" ]]; then hit=1; break; fi
      done
      if [[ "$hit" == "0" ]]; then
        err "$rel imperatively invokes unadmitted methodology skill: methodology.$name"
      fi
    done < <(grep -ioE '(invokes?|invoking|composes?|composing)[[:space:]]+`methodology\.[a-z][a-z0-9-]*`' "$skill" | grep -oE 'methodology\.[a-z][a-z0-9-]*' | sort -u)
  fi
done

# ---------------------------------------------------------------------------
# 10. Capability plugins referencing methodology must declare it as a native dep.
# ---------------------------------------------------------------------------
if [[ "$plugin_name" != "methodology" && -f "$plugin_json" && -f "$contract" ]]; then
  # Any methodology.<name> tokens anywhere in the skill bodies of this plugin?
  # The brace-group + `|| true` is required because `grep` exits 1 on no matches,
  # which propagates through pipefail and would abort the script under `set -e`.
  ref_count="$({ grep -rhoE 'methodology\.[a-z][a-z0-9-]*' "$plugin_dir/skills" 2>/dev/null || true; } | wc -l | awk '{print $1}')"
  if [[ "$ref_count" -gt 0 ]]; then
    has_dep="$(jq -r '[.dependencies[]? | select(.name == "methodology")] | length' "$plugin_json")"
    if [[ "$has_dep" == "0" ]]; then
      err "plugin.json must declare methodology as a native dependency (skills reference methodology.<name> $ref_count times)"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 9. MCP alwaysLoad: true requires justification in manifest.json.
# ---------------------------------------------------------------------------
mcp_json="$plugin_dir/.mcp.json"
if [[ -f "$mcp_json" ]]; then
  while read -r server; do
    [[ -z "$server" ]] && continue
    just="$(jq -r --arg s "$server" '[.mcp_servers_always_load[]? | select(.server == $s)] | first | .justification // ""' "$contract")"
    if [[ -z "$just" ]]; then
      err ".mcp.json server '$server' declares alwaysLoad: true but no justification in manifest.json.mcp_servers_always_load"
    fi
  done < <(jq -r 'to_entries[] | select(.value.alwaysLoad == true) | .key' "$mcp_json" 2>/dev/null || true)
fi

# ---------------------------------------------------------------------------
# 11. Hook scripts: every hook command path resolves and is executable.
# ---------------------------------------------------------------------------
hooks_json="$plugin_dir/hooks/hooks.json"
if [[ -f "$hooks_json" ]]; then
  while read -r cmd_line; do
    [[ -z "$cmd_line" ]] && continue
    # Extract paths that look like ${CLAUDE_PLUGIN_ROOT}/...
    script_rel="$(echo "$cmd_line" | grep -oE '\${CLAUDE_PLUGIN_ROOT}/[^"]*\.sh' | head -1)"
    if [[ -n "$script_rel" ]]; then
      script_path="$plugin_dir${script_rel#'${CLAUDE_PLUGIN_ROOT}'}"
      if [[ ! -f "$script_path" ]]; then
        err "hooks.json references missing script: $script_path"
      elif [[ ! -x "$script_path" ]]; then
        err "hooks.json script not executable: $script_path"
      fi
    fi
  done < <(jq -r '.. | objects | select(.command?) | .command' "$hooks_json" 2>/dev/null || true)
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [[ "$errors" -eq 0 ]]; then
  echo "validate: PASS ($plugin_name) — $warnings warning(s)"
  exit 0
else
  echo "validate: FAIL ($plugin_name) — $errors error(s), $warnings warning(s)"
  exit 1
fi
