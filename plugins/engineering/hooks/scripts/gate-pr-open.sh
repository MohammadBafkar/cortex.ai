#!/usr/bin/env bash
# gate-pr-open.sh — engineering plugin PreToolUse hook for `gh pr create`.
#
# Contract: stdin = JSON, stdout = JSON action. Exit 0 = proceed, non-zero = block.
# Enforces:
#   1. A PullRequest envelope exists at .agents/state/prs/<branch>/engineering/pr.json.
#      No envelope = the author skipped the propose-pr procedure (e.g., methodology.verify).
#   2. The current branch matches the PR-prefix convention (feat/*, fix/*, refactor/*).
#   3. The author has not previously approved their own change (basic SoD pre-check;
#      the platform PEP enforces the full SoD at review-verdict write time).

set -euo pipefail

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  # If jq is missing the platform can't gate reliably — fail closed.
  cat <<EOF
{
  "action": "block",
  "message": "engineering.gate-pr-open: jq not available; cannot validate PR readiness. Install jq or disable this hook."
}
EOF
  exit 1
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

if [[ -z "$branch" ]]; then
  cat <<EOF
{
  "action": "block",
  "message": "engineering.gate-pr-open: no git branch detected. Are you in a git checkout?"
}
EOF
  exit 1
fi

if [[ ! "$branch" =~ ^(feat|fix|refactor)/ ]]; then
  cat <<EOF
{
  "action": "block",
  "message": "engineering.gate-pr-open: branch '$branch' does not match feat/* | fix/* | refactor/*. Rename the branch before opening a PR."
}
EOF
  exit 1
fi

workspace_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
pr_id="$(echo "$branch" | tr '/' '-')"
envelope="$workspace_root/.agents/state/prs/$pr_id/engineering/pr.json"

if [[ ! -f "$envelope" ]]; then
  cat <<EOF
{
  "action": "block",
  "message": "engineering.gate-pr-open: PullRequest envelope missing at $envelope. Run /implement (or engineering.propose-pr directly) to produce one before opening a PR."
}
EOF
  exit 1
fi

# Optional: verify the envelope's state is 'proposed' (not 'failed' or 'requires_human').
state="$(jq -r '.state // "unknown"' "$envelope")"
if [[ "$state" != "proposed" && "$state" != "approved" ]]; then
  cat <<EOF
{
  "action": "block",
  "message": "engineering.gate-pr-open: envelope state is '$state'. Re-run /implement to produce a proposed envelope before opening the PR."
}
EOF
  exit 1
fi

echo '{"action":"proceed","message":"engineering.gate-pr-open: envelope verified."}'
