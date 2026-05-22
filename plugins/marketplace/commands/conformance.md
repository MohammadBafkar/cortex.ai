---
name: conformance
description: |
  **Use when:** the user types `/conformance <plugin>` to run the full
  conformance pipeline against a Plugin Package.
  **Do NOT use when:** the user wants to install a plugin (`/install-plugin`),
  query the audit log (`/audit`), or dispatch a workflow (`/implement`).
  **Inputs:** plugin name or directory path.
  **Outputs:** ConformanceVerdict@v1 promoted to CAS.
argument-hint: "<plugin>"
allowed-tools: [Task, Read, Bash]
---

# /conformance

Dispatch the `conformance-tester` subagent against the named plugin.
