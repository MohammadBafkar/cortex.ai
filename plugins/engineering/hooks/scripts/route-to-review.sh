#!/usr/bin/env bash
# route-to-review.sh — engineering plugin PostToolUse hook for `git push`.
#
# Contract: stdin = JSON hook payload, stdout = JSON action.
# Triggered after a `git push` succeeds; if the push was on a PR-prefixed branch,
# write a marker so /review can find it.
#
# Performance budget: ≤ 80ms p95 (per SPEC.md POSIX-shell PreToolUse target).
# Auto-suppresses chat output when CLAUDE_CODE_NON_INTERACTIVE=1.

set -euo pipefail

input="$(cat)"

# Defensive parsing: if jq is unavailable or the payload is malformed, fail open (proceed).
if ! command -v jq >/dev/null 2>&1; then
  echo '{"action":"proceed"}'
  exit 0
fi

# The invocation context id correlates this hook with the calling subagent's events.
ic_id="$(echo "$input" | jq -r '.invocation_context.invocation_id // .invocation_context_id // "unknown"')"

# Determine current branch (the hook fires after the push, so HEAD is the pushed branch).
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

if [[ -z "$branch" ]]; then
  echo '{"action":"proceed"}'
  exit 0
fi

# Only route PR-prefixed branches: feat/*, fix/*, refactor/*.
if [[ "$branch" =~ ^(feat|fix|refactor)/ ]]; then
  workspace_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  marker_dir="$workspace_root/.agents/state/markers"
  mkdir -p "$marker_dir"

  marker="$marker_dir/last-push.json"
  cat > "$marker" <<EOF
{
  "pr_branch": "$branch",
  "invocation_context_id": "$ic_id",
  "pushed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "engineering.route-to-review"
}
EOF

  # Emit a structured telemetry event for the platform sink to capture.
  # The platform PostToolUse hook (Phase 2) will pick this up.
  echo "{\"event\":\"engineering.pr.pushed\",\"branch\":\"$branch\",\"ic_id\":\"$ic_id\"}" >&2

  # User-facing announcement (suppressed in headless mode).
  if [[ "${CLAUDE_CODE_NON_INTERACTIVE:-0}" != "1" ]]; then
    echo "[cortex/engineering] Push on $branch routed; /review will find it." >&2
  fi

  echo '{"action":"proceed","message":"Push routed; /review will find it."}'
else
  echo '{"action":"proceed"}'
fi
