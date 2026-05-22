#!/usr/bin/env python3
"""
compare-perf.py — diff two BenchmarkResult@v1 JSON files and flag regressions.

Invoked by quality.benchmark after a run completes:

    python3 ${CLAUDE_PLUGIN_ROOT}/skills/benchmark/scripts/compare-perf.py \
        --baseline .agents/state/runs/baseline/quality/benchmark.json \
        --candidate .agents/state/runs/PR-123/quality/benchmark.json \
        --warn-pct 10 --block-pct 25

Exit codes:
  0  no regression (or baseline missing — treats candidate as new baseline)
  1  warning regression (>= warn_pct but < block_pct on any metric)
  2  blocking regression (>= block_pct on any metric)
  3  malformed input

Output: a JSON diff summary on stdout the caller can promote into the
BenchmarkResult envelope's `comparison` field.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def load(path: str) -> dict | None:
    p = Path(path)
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text())
    except json.JSONDecodeError as e:
        print(f"compare-perf: malformed JSON at {path}: {e}", file=sys.stderr)
        sys.exit(3)


def pct_change(baseline: float, candidate: float) -> float:
    """% change vs baseline. Positive means candidate is slower (worse for latency)."""
    if baseline == 0:
        return 0.0
    return round((candidate - baseline) / baseline * 100.0, 2)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--baseline", required=True)
    ap.add_argument("--candidate", required=True)
    ap.add_argument(
        "--warn-pct", type=float, default=10.0,
        help="A p95 increase >= this percent on any metric is a warning. Default 10.",
    )
    ap.add_argument(
        "--block-pct", type=float, default=25.0,
        help="A p95 increase >= this percent on any metric blocks the merge. Default 25.",
    )
    args = ap.parse_args()

    baseline = load(args.baseline)
    candidate = load(args.candidate)

    if candidate is None:
        print(f"compare-perf: candidate missing at {args.candidate}", file=sys.stderr)
        return 3

    if baseline is None:
        print(json.dumps({
            "comparison": "no_baseline",
            "note": "Candidate is the new baseline. No comparison.",
        }))
        return 0

    # Both files expose metrics as: {"metrics": {"<name>": {"p50_ms": float, "p95_ms": float, "p99_ms": float, ...}}}
    b_metrics = baseline.get("metrics", {})
    c_metrics = candidate.get("metrics", {})

    flagged: list[dict] = []
    blocking = False
    warning = False

    all_metric_names = sorted(set(b_metrics) | set(c_metrics))
    for name in all_metric_names:
        b = b_metrics.get(name, {})
        c = c_metrics.get(name, {})
        for percentile in ("p50_ms", "p95_ms", "p99_ms"):
            b_val = b.get(percentile)
            c_val = c.get(percentile)
            if b_val is None or c_val is None:
                continue
            delta_pct = pct_change(float(b_val), float(c_val))
            severity = "ok"
            if delta_pct >= args.block_pct:
                severity = "blocking"
                blocking = True
            elif delta_pct >= args.warn_pct:
                severity = "warning"
                warning = True
            if severity != "ok":
                flagged.append({
                    "metric": name,
                    "percentile": percentile,
                    "baseline_ms": b_val,
                    "candidate_ms": c_val,
                    "delta_pct": delta_pct,
                    "severity": severity,
                })

    overall = "ok"
    if blocking:
        overall = "blocking"
    elif warning:
        overall = "warning"

    print(json.dumps({
        "comparison": "ran",
        "baseline_path": args.baseline,
        "candidate_path": args.candidate,
        "warn_pct": args.warn_pct,
        "block_pct": args.block_pct,
        "overall": overall,
        "flagged": flagged,
        "metric_count": len(all_metric_names),
    }, indent=2))

    if blocking:
        return 2
    if warning:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
