#!/usr/bin/env bash
# trigger-pipeline.sh — platform PostToolUse hook on `gh pr create`.
#
# Drops a workflow marker that the next /build invocation (or the workflow
# router orchestrating /implement) picks up to start the pipeline.
#
# Performance budget: ≤ 80ms p95.

set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"action":"proceed"}'
  exit 0
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"
if [[ -z "$branch" || ! "$branch" =~ ^(feat|fix|refactor)/ ]]; then
  echo '{"action":"proceed"}'
  exit 0
fi

workspace_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
marker_dir="$workspace_root/.agents/state/markers"
mkdir -p "$marker_dir"

pr_id="$(echo "$branch" | tr '/' '-')"
ic_id="$(echo "$input" | jq -r '.invocation_context.invocation_id // "unknown"')"

cat > "$marker_dir/pipeline-pending.json" <<EOF
{
  "pr_id": "$pr_id",
  "branch": "$branch",
  "invocation_context_id": "$ic_id",
  "queued_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "platform.trigger-pipeline"
}
EOF

if [[ "${CLAUDE_CODE_NON_INTERACTIVE:-0}" != "1" ]]; then
  echo "[cortex/platform] PR opened on $branch — pipeline queued (run /build to execute)." >&2
fi

echo '{"action":"proceed","message":"pipeline queued"}'
