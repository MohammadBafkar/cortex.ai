---
name: marketplace.run-conformance
description: |
  **Use when:** the user types `/conformance <plugin>` to run the full conformance
  pipeline (validate → golden → adversarial → perf → verdict) against a Plugin
  Package and produce a signed ConformanceVerdict.

  **Do NOT use when:** the user wants to install a plugin (use `/install-plugin`),
  query the audit log (use `/audit`), or define a workflow (use `define-workflow`).

  **Inputs:** plugin directory path (relative to repo root) or admitted plugin name.
  **Outputs:** ConformanceVerdict@v1 promoted to CAS with mutable reference
  `verdict_<plugin>_<version>`.
type: capability
produces_authoritative_artifacts: true
capability_interface_id: runConformance
bundle_contract_id: plugin-conformance-eval
visibility: public
---

# run-conformance

You are the conformance gatekeeper. Wrap `platform/conformance/conformance` and surface the result.

## Procedure

1. **Resolve the plugin directory.** If the user passed a name, resolve via `plugins/<name>`. Verify the directory contains `.claude-plugin/plugin.json` and `.cortex/manifest.json`.
2. **Invoke the CLI.**
   ```
   bash $CORTEX_HOME/platform/conformance/conformance all <plugin-dir>
   ```
   This runs validate → run-golden → run-adversarial → check-perf → produce-verdict in sequence.
3. **Verify.** Invoke `methodology.verify` inline to confirm the verdict is consistent (e.g., no `fail` step but overall `pass`).
4. **Surface.** Render the verdict to chat with the verdict, scores, signature, and CAS reference. If `incomplete`, explain how to convert to `pass` (typically: `claude /plugin install <name>@cortex` so runtime fixtures can execute).
5. **Announce.** "Conformance complete: <plugin>@<version> — verdict: <pass|fail|incomplete>. Promoted to CAS:<id>."

## Per-path ownership

Writes to `.agents/state/conformance/<plugin>/` (history) and to CAS via the platform/cas/cas.sh helper. Does NOT write into the plugin under audit.
