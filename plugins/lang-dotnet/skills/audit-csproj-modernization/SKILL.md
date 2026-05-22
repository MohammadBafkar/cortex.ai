---
name: lang-dotnet.audit-csproj-modernization
description: |
  **Use when:** a .NET PR touches `*.csproj` / `*.fsproj` / `Directory.Build.props`
  and the team wants a modernization audit — outdated TargetFramework,
  SDK-style migration candidates, PackageReference floating versions, legacy
  properties, removed/deprecated MSBuild targets. Triggers on: "/csproj-audit",
  "audit project file", "modernize csproj".
  **Do NOT use when:** the user wants to bump a NuGet package version (use
  `engineering.propose-dep-bump`), migrate an entire solution
  (use `engineering.propose-modernization`), or apply changes — this skill
  produces a report, not an apply.
  **Inputs:** PullRequest@v1 with project-file changes.
  **Outputs:** ModernizationReport@v1 at
  `.agents/state/langs/lang-dotnet/<pr-id>/modernization.json`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: auditCsprojModernization
bundle_contract_id: lang-dotnet
visibility: public
---

# audit-csproj-modernization

Audit `*.csproj` / `*.fsproj` / `Directory.Build.props` for modernization opportunities. Produce a report; do NOT apply.

## Procedure

1. **Parse the project files** as XML. If parsing fails, refuse with the parse error.

2. **Check TargetFramework / TargetFrameworks:**
   - Out-of-support framework (e.g., `netcoreapp3.1`, `net5.0`, `net6.0` after Nov 2024) → `severity: error`, recommend the current LTS.
   - In-support but not latest LTS → `severity: warning`, recommend the bump.
   - Multi-targeting (`<TargetFrameworks>net8.0;netstandard2.0</TargetFrameworks>`) → leave alone; flag only if the matrix has redundant entries.

3. **Check SDK style:** legacy `.csproj` (no `Sdk="Microsoft.NET.Sdk"` attribute, explicit `<Compile Include>` lists) → `severity: warning`, recommend SDK-style migration with a starter diff. This is a large refactor; surface explicitly that it's an ADR-grade change.

4. **Check PackageReference versions:**
   - Floating versions (`Version="*"` or `Version="6.*"`) → `severity: warning` (reproducibility risk). Recommend pinned version.
   - Outdated pinned versions (per the team's NuGet feed) → `severity: info`; route to `engineering.propose-dep-bump` for the actual bump.
   - Pre-release packages on a release branch → `severity: warning`.

5. **Check legacy properties:**
   - `<RestoreProjectStyle>PackageReference</RestoreProjectStyle>` — obsolete since SDK-style is default → remove.
   - `<NoWarn>` with > 5 entries → flag as warning-suppression bloat; recommend reviewing each rule.
   - `<DebugType>Full</DebugType>` on a modern target → recommend `portable` or `embedded`.
   - `<AssemblyName>` redundant with the default → recommend removing.

6. **Check removed / deprecated MSBuild targets:**
   - `<Import Project="…">` referencing files that no longer exist → `severity: error`.
   - Custom `<Target>` with `BeforeTargets="Build"` that duplicates an SDK-provided target → recommend removal.

7. **Compose `methodology.risk-assess` inline.** Document caller impact for each recommendation.

8. **Compose `methodology.verify` inline.**

9. **Emit the ModernizationReport** at `.agents/state/langs/lang-dotnet/<pr-id>/modernization.json`. Group findings by severity. Each finding: rule id, file/line, current value, recommended value, risk note, and `requires_adr` boolean.

## Hard rules

- **Never apply csproj changes directly.** This skill produces a report. PEP blocks any csproj edit attempts from this skill.
- **TargetFramework bumps require an ADR.** Surface the ADR template; do not skip.
- **Major NuGet bumps require an ADR.** Patch/minor are reportable; the actual apply is `engineering.propose-dep-bump`'s job.
- **Don't normalize whitespace or property ordering** as part of the report. Cosmetic churn dilutes the signal.

## Failure handling

- Project file unparseable → refuse with the parse error verbatim.
- TargetFramework not yet GA (preview SDK) → refuse with a "wait for stable" diagnostic.
