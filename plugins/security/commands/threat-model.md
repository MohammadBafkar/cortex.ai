---
name: threat-model
description: |
  **Use when:** the user types `/threat-model [design-id]` to produce a STRIDE
  threat model against a SystemDesignDoc.
  **Do NOT use when:** the user wants vuln scanning (`/security-audit`) or PIA
  (`/pia`).
  **Inputs:** design-id.
  **Outputs:** ThreatModel@v1.
argument-hint: "<design-id>"
allowed-tools: [Task, Read, Bash, Write]
---

# /threat-model

Dispatch `threat-modeler` against the named SystemDesignDoc.
