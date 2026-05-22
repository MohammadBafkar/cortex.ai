#!/usr/bin/env bash
# permission-pep.sh — platform PreToolUse hook enforcing per-path workspace-state
# ownership (SPEC.md, §10.0) and SoD on review verdicts.
#
# Algorithm:
#   1. Parse the tool_input.file_path (or equivalent target path).
#   2. If the path is under .agents/state/, determine the owning bundle from
#      platform/settings/state-ownership.json.
#   3. Determine the invoking plugin from invocation_context.plugin_id.
#   4. Block if invoker != owner. Special case: contributor subdirs under a parent
#      owned path (e.g., .agents/state/reviews/<pr-id>/<contributor>/) are
#      allowed when the invoker matches the contributor segment.
#   5. SoD check: a ReviewVerdict@v1 write where reviewer principal == author
#      principal is blocked.
#
# Fails CLOSED on cross-path violations. Performance budget ≤ 80ms p95.

set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  # No jq: fail closed for safety on a security-sensitive hook.
  cat <<'EOF'
{"action":"block","message":"platform.permission-pep: jq required; cannot validate path ownership."}
EOF
  exit 1
fi

tool="$(echo "$input" | jq -r '.tool_name // .tool // ""')"
target_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // .file_path // ""')"
plugin_id="$(echo "$input" | jq -r '.invocation_context.plugin_id // .plugin // ""')"

# Only mutating tools are subject to PEP. Read-only tools (Read, Grep, Glob) pass through.
case "$tool" in
  Write|Edit|MultiEdit|NotebookEdit)
    ;;
  Bash)
    # Shell-based file mutations are not interceptable by path; the per-plugin hooks
    # are responsible for their own constraints (e.g., engineering.gate-pr-open).
    echo '{"action":"proceed"}'
    exit 0
    ;;
  *)
    echo '{"action":"proceed"}'
    exit 0
    ;;
esac

# Only care about writes under .agents/state/.
if [[ "$target_path" != *".agents/state/"* ]]; then
  echo '{"action":"proceed"}'
  exit 0
fi

# Locate the workspace root and the ownership map.
workspace_root="$(pwd)"
if [[ -n "${CORTEX_HOME:-}" ]]; then
  ownership_map="$CORTEX_HOME/platform/settings/state-ownership.json"
else
  ownership_map="$(dirname "$0")/../settings/state-ownership.json"
fi

if [[ ! -f "$ownership_map" ]]; then
  cat <<EOF
{"action":"block","message":"platform.permission-pep: state-ownership.json missing at $ownership_map; cannot validate."}
EOF
  exit 1
fi

# Strip the prefix up through .agents/state/ so we can match against the map.
rel="${target_path#*.agents/state/}"

# Multi-user namespacing (SPEC.md). When CORTEX_MULTI_USER=1
# the workspace state tier is partitioned by user-id:
#   .agents/state/<user-id>/<owner>/...
# We strip the <user-id> segment before ownership lookup, AND enforce that the
# user-id segment matches the invoking principal's user-id (read from the IC).
# A user cannot write into another user's namespace.
if [[ "${CORTEX_MULTI_USER:-0}" == "1" ]]; then
  ns_user="${rel%%/*}"
  principal_user="$(echo "$input" | jq -r '.invocation_context.principal.user_id // .invocation_context.user_id // ""')"
  if [[ -z "$principal_user" ]]; then
    cat <<EOF
{"action":"block","message":"platform.permission-pep: CORTEX_MULTI_USER=1 but invocation_context.principal.user_id is empty. Cannot validate namespace ownership."}
EOF
    exit 1
  fi
  if [[ "$ns_user" != "$principal_user" ]]; then
    cat <<EOF
{"action":"block","message":"platform.permission-pep: cross-user write blocked. Path namespace '.agents/state/$ns_user/...' is owned by user '$ns_user' but the invoking principal is '$principal_user'."}
EOF
    exit 1
  fi
  # Re-derive `rel` without the user-id segment so the ownership lookup below
  # operates on .agents/state/<owner>/... as in single-user mode.
  rel="${rel#*/}"
fi

top_dir="${rel%%/*}"
second_dir="${rel#*/}"
second_top="${second_dir%%/*}"

# Determine the owning plugin. Try a two-level key first (e.g., findings/security)
# then fall back to the top-level dir.
combined="$top_dir/$second_top"
owner="$(jq -r --arg k "$combined" '.owners[$k] // ""' "$ownership_map")"
if [[ -n "$owner" && "$owner" != "null" ]]; then
  top_dir="$combined"
else
  owner="$(jq -r --arg k "$top_dir" '.owners[$k] // ""' "$ownership_map")"
fi

# No owner mapped: block — unknown subdirs need an explicit mapping.
if [[ -z "$owner" || "$owner" == "null" ]]; then
  cat <<EOF
{"action":"block","message":"platform.permission-pep: no owner mapped for .agents/state/$top_dir/ in state-ownership.json. Add it or fix the target path."}
EOF
  exit 1
fi

# Rule 1: invoker == owner → allow. This is the common case (writing into your own owned subtree).
if [[ "$owner" == "$plugin_id" ]]; then
  : # fall through to SoD check below
elif [[ "${plugin_id:-platform}" == "platform" && "$owner" == "platform" ]]; then
  : # platform writing to platform-owned subdirs (markers/, telemetry/)
else
  # Rule 2: composite-artifact contributor layout.
  # Path must be .agents/state/<top>/<artifact-id>/<contributor-plugin>/...
  # AND <top> must be in composite_artifact_paths AND <contributor-plugin> == invoker.
  is_composite="$(jq -r --arg k "$top_dir" '.composite_artifact_paths | index($k) // empty | tostring' "$ownership_map")"
  contributor_segment="$(echo "$rel" | awk -F/ '{print $3}')"
  if [[ -n "$is_composite" && "$is_composite" != "" && "$is_composite" != "null" && \
        -n "$contributor_segment" && "$contributor_segment" == "$plugin_id" ]]; then
    : # composite contributor allowed
  else
    cat <<EOF
{"action":"block","message":"platform.permission-pep: cross-path write blocked. .agents/state/$top_dir/ is owned by '$owner' but the invoking plugin is '$plugin_id'. Either dispatch to '$owner', or — if this is a composite-artifact tree — use the contributor-subdir layout (.agents/state/$top_dir/<artifact-id>/$plugin_id/...) and ensure $top_dir is in composite_artifact_paths."}
EOF
    exit 1
  fi
fi

# SoD on review verdict writes: reviewer_principal_id == author_principal_id is blocked.
if [[ "$target_path" == *".agents/state/reviews/"*"/verdict.json" ]]; then
  # Try to read the corresponding PR envelope to compare principals.
  pr_id_from_path="$(echo "$target_path" | sed -E 's|.*\.agents/state/reviews/([^/]+)/.*|\1|')"
  pr_envelope="$workspace_root/.agents/state/prs/$pr_id_from_path/engineering/pr.json"
  if [[ -f "$pr_envelope" ]]; then
    author="$(jq -r '.author_principal_id // ""' "$pr_envelope")"
    reviewer="$(echo "$input" | jq -r '.invocation_context.principal.id // ""')"
    if [[ -n "$author" && -n "$reviewer" && "$author" == "$reviewer" ]]; then
      cat <<EOF
{"action":"block","message":"platform.permission-pep: self-review violation. Reviewer principal '$reviewer' equals PR author principal '$author'. SoD policy: an author cannot approve their own change."}
EOF
      exit 1
    fi
  fi
fi

echo '{"action":"proceed"}'
