---
name: lang-python.propose-type-annotations
description: |
  **Use when:** a Python PR has bare functions / methods without type
  annotations and the team wants progressive typing applied. Triggers on:
  "/types-py".
  **Do NOT use when:** the project is untyped by policy (use the existing
  `mypy.ini` / `pyproject.toml` `[tool.mypy]` to honor that choice), or the
  user wants tests (`write-pytest-test`).
  **Inputs:** PullRequest@v1 with Python diff.
  **Outputs:** TypeAnnotationProposal@v1 — suggested annotations as a unified
  diff the engineer can accept or reject.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: proposeTypeAnnotations
bundle_contract_id: lang-python
visibility: public
---

# propose-type-annotations

Propose type annotations for functions/methods that lack them; do NOT apply automatically.

## Procedure

1. Verify mypy / pyright configuration. Honor the project's strictness profile.
2. For each function/method in the diff without annotations:
   - Infer from usage (callers' types, return-site types, literal defaults).
   - Use `from __future__ import annotations` if not present (forward refs as strings).
   - Prefer concrete types (`list[int]`) over `Any`. `Any` is a refusal-to-decide.
3. Compose `methodology.risk-assess` inline — narrowing an existing parameter type is a breaking change for callers.
4. Compose `methodology.verify` inline.
5. Emit the proposal as a unified diff (not auto-applied).

## Hard rules

- **No annotations to public APIs without HITL.** Public API surface changes need an ADR.
- **No `Any` as a default.** When inference is genuinely uncertain, surface for HITL.
- **No removing existing annotations** without explicit user request.
