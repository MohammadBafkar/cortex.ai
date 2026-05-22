---
name: lang-dotnet.propose-nullable-references
description: |
  **Use when:** a C# project is rolling out Nullable Reference Types (NRT) —
  either flipping `<Nullable>enable</Nullable>` at project level or doing
  file-scoped `#nullable enable` migration. Triggers on: "/nullable",
  "enable NRT", "propose nullable annotations".
  **Do NOT use when:** the user wants to disable NRT (a downgrade — refuse),
  apply `!` everywhere to silence the compiler (anti-pattern — refuse), or
  the project is not C# 8.0+ / `net5.0+` (NRT requires those).
  **Inputs:** PullRequest@v1 on a project currently on `<Nullable>disable</Nullable>`.
  **Outputs:** NullabilityProposal@v1 — unified diff + risk notes for public-API
  parameter narrowing.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: proposeNullableReferences
bundle_contract_id: lang-dotnet
visibility: public
---

# propose-nullable-references

Propose enabling Nullable Reference Types (NRT) plus the `?`/`!` annotations needed to compile clean. Emit a unified diff; do NOT apply.

## Procedure

1. **Verify NRT is supported.** C# 8.0+ (`<LangVersion>8.0</LangVersion>` or higher) on `net5.0+`. Otherwise refuse with a "requires C# 8.0+" diagnostic.

2. **Inspect current state.** Read csproj for `<Nullable>` and the per-file `#nullable` pragmas. Decide rollout strategy:
   - **Project-wide flip** (`<Nullable>enable</Nullable>` in csproj): preferred for greenfield code; risky for large legacy projects.
   - **File-scoped rollout** (`#nullable enable` at top of file): incremental; safer for legacy.

3. **Compile the project with NRT enabled** (in a scratch workspace) to enumerate the warnings:
   - `CS8600` — converting null literal to non-nullable.
   - `CS8602` — dereference of possibly-null reference.
   - `CS8603` — possible null reference return.
   - `CS8604` — possible null reference argument.
   - `CS8618` — non-nullable property uninitialized.
   - `CS8625` — null literal to non-nullable parameter.

4. **For each warning, propose the minimal annotation:**
   - Property/field is set in the constructor → mark non-nullable.
   - Property/field is sometimes null (e.g., a result that wasn't found) → mark `?`.
   - Parameter is always non-null per contract → leave; the caller must satisfy it.
   - Parameter has a documented null contract → mark `?`.
   - Return value may be null → mark `?`.
   - Property/field is set via DI / framework but the compiler can't prove it → use `[MemberNotNullWhen]` or `[NotNullWhen]` attribute, NOT `null!`.

5. **Classify each annotation:**
   - **Widening** (`string` → `string?`): safe for callers. Auto-acceptable.
   - **Narrowing** (`string?` → `string`): **breaking change.** Requires ADR. Flag per-symbol.
   - **Init-only declarations** (private/internal): low risk.
   - **Public API surface** (public types, methods, properties on public classes): always requires ADR if narrowing.

6. **Compose `methodology.risk-assess` inline.** Document caller impact for each public-API narrowing.

7. **Compose `methodology.verify` inline.**

8. **Emit the NullabilityProposal** at `.agents/state/langs/lang-dotnet/<pr-id>/nullability.json`:
   - `current_state`: project-wide / per-file pragma map.
   - `strategy`: project-wide-flip | file-scoped.
   - `annotations[]`: file, line, symbol, current type, proposed type, classification (widening|narrowing|init), `requires_adr`.
   - `risk_notes[]`.

## Hard rules

- **Never use `null!` or `default!`** as a placeholder. Those are bug-prone null-forgiveness escapes. If a property must be init-late, use `[MemberNotNullWhen]` / `[MemberNotNull]` or refactor to constructor injection.
- **Never narrow a public-API parameter without an ADR.** That's a breaking change.
- **Never remove existing nullability annotations** unless explicitly framed as a rollback.
- **Don't auto-apply.** This is a proposal skill.

## Failure handling

- Project not C# 8.0+ / `net5.0+` → refuse with the language-version diagnostic.
- Project already has `<Nullable>enable</Nullable>` and clean → emit `state: noop` with a "nothing to do" note.
- Compile errors that aren't NRT-related → refuse and surface them; this skill won't proceed against a broken build.
