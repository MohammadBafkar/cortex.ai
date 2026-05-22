---
name: install-plugin
description: |
  **Use when:** the user types `/install-plugin <name>` to install a plugin from
  the cortex marketplace into their workspace. Wraps `claude /plugin install
  <name>@cortex` with the marketplace's admission gate.

  **Do NOT use when:** the user wants to uninstall (use `/uninstall-plugin`),
  query the catalog (use `claude /plugin marketplace list` directly), or run
  conformance on a plugin in-place (use `/conformance`).

  **Inputs:** plugin name; optional `--force-incomplete-admission` (admin only).
  **Outputs:** install record; permission grant (HITL via checkpoint 21 — M-tier).
argument-hint: "<plugin> [--force-incomplete-admission]"
allowed-tools: [Task, Read, Bash]
---

# /install-plugin

Pre-flight admission gate, then HITL on the permission grant, then `claude /plugin install`.

## Procedure

1. **Pre-flight admission check.** Invoke:

   ```bash
   bash ${CORTEX_HOME}/platform/conformance/check-admission.sh <plugin> [--force-incomplete-admission]
   ```

   Interpret the exit code:

   | Exit | Verdict | Action |
   | --- | --- | --- |
   | 0 | `pass` (or `incomplete` + admin force) | proceed to step 2 |
   | 1 | `fail` | **abort** — surface the failed scores; user must fix conformance and re-run |
   | 2 | `incomplete` (no force) | **abort with guidance** — surface the install + `produce-verdict` recipe to convert `incomplete → pass` |
   | 3 | no verdict found | **abort** — surface the `/conformance <plugin>` recipe |
   | 4 | misuse | **abort** — surface the usage error |

2. **HITL — permission grant.** Per `GOVERNANCE.md` §5.2 checkpoint 21 (Plugin Package admission), surface an `ApprovalRequest@v1` with the plugin's declared permission scopes + risk tier from `manifest.json`. Decider: `rbac/marketplace-admins ∩ rbac/security-leads ∩ rbac/privacy-leads`. SLA 5 BD. Fallback: deny.

3. **Execute install.** On approval, shell out:

   ```bash
   claude /plugin install <name>@cortex
   ```

4. **Record the install.** Write an audit event with `kind: plugin_installed`, `plugin`, `version`, `verdict_cas_id`, `force_used`. The platform `audit-postuse.sh` hook captures it; on SessionEnd it flushes to the durable sink.

## Hard rules

- **Fail verdicts are never forceable.** No admin flag bypasses a `fail`.
- **`incomplete` requires an explicit admin gesture.** The `--force-incomplete-admission` flag exists for trusted dev environments only; CI must always demand `pass`.
- **The gate is non-bypassable.** If a user invokes `claude /plugin install` directly (bypassing `/install-plugin`), the platform PostToolUse hook detects the install event and writes a `bypass_admission` telemetry warning. The install still happens (Claude Code is the ultimate authority), but the breach is logged for the next `PluginFeedback` cycle.
