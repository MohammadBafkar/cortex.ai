---
capability_interface_id: auditCsprojModernization
version: 1
bundle_contract_id: lang-dotnet
schema_in: PullRequest@v1
schema_out: ModernizationReport@v1
---

# auditCsprojModernization@v1

Audits `*.csproj` / `*.fsproj` / `Directory.Build.props` for modernization opportunities: outdated TargetFramework, SDK-style migration candidates, PackageReference floating versions, legacy properties (`NoWarn` bloat, `RestoreProjectStyle`), and removed/deprecated MSBuild targets.

## Inputs

- `PullRequest@v1` with changes under `*.csproj` / `*.fsproj` / `*.props` / `*.targets`.

## Outputs

- `ModernizationReport@v1` at `.agents/state/langs/lang-dotnet/<pr-id>/modernization.json`. Each finding includes: severity (info|warning|error), rule id, file/line, current value, recommended value, and a risk note for caller impact.

## Non-functional contract

- **Idempotency:** yes on same source state.
- **Latency budget:** p95 ≤ 30 s.
- **Token budget:** ≤ 15K.
- **HITL:** **TargetFramework bumps require an ADR** (checkpoint 5 — Architectural decision). PackageReference patch/minor bumps are reportable but not auto-applied; major bumps refuse and surface ADR templates.

## Failure modes

- Apply changes directly to csproj → PEP blocks. This skill produces a report, not an apply.
- TargetFramework bump without ADR → refuse with `state: requires_human`.
- Project file unparseable (malformed XML) → refuse and surface the parse error.

## Fixtures

Golden: `csproj-audit-flags-old-target`.
Adversarial: `csproj-auto-apply-without-hitl` (PEP blocks).
