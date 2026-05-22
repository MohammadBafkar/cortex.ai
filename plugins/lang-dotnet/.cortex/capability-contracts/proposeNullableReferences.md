---
capability_interface_id: proposeNullableReferences
version: 1
bundle_contract_id: lang-dotnet
schema_in: PullRequest@v1
schema_out: NullabilityProposal@v1
---

# proposeNullableReferences@v1

Propose enabling `<Nullable>enable</Nullable>` for a project (or a file-scoped `#nullable enable` rollout) plus the `?`/`!` annotations needed for the surface API to compile clean. Emits a unified diff; does NOT apply.

## Inputs

- `PullRequest@v1` with C# changes, or a project currently on `<Nullable>disable</Nullable>` per the PR's csproj.

## Outputs

- `NullabilityProposal@v1` at `.agents/state/langs/lang-dotnet/<pr-id>/nullability.json` — a unified diff plus a per-symbol risk note flagging public-API parameter narrowings.

## Non-functional contract

- **Idempotency:** yes on same source state.
- **Latency budget:** p95 ≤ 60 s (full project audit).
- **Token budget:** ≤ 20K.
- **HITL:** **narrowing a public-API parameter type requires an ADR** (`string?` → `string` is a breaking change for callers). Adding `?` (widening) is auto-acceptable. File-scoped `#nullable enable` of internal-only types is auto-acceptable.

## Failure modes

- Narrowing public-API parameter without ADR → refuse with `state: requires_human`.
- `null!` or `default!` used as a placeholder → flag and refuse (those are bug-prone forgiveness escapes that should be explicit init or refactored away).
- Removing existing nullability annotations → refuse unless explicitly framed as a rollback.

## Fixtures

Golden: `nullable-propose-enable`.
Adversarial: `nullable-enable-narrows-public-api` (refused).
