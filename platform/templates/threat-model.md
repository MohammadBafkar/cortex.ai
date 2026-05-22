<!--
Template: ThreatModel — STRIDE applied per trust boundary.
Authored by: security.threat-model.
Required: every trust boundary gets a STRIDE pass; every medium/high threat gets a mitigation.
Remove this block before promotion.
-->

# Threat Model: <subsystem>

- **Status:** proposed
- **Date:** <YYYY-MM-DD>
- **Author:** <name (security lead)>
- **SystemDesignDoc:** <link or id>
- **Reviewers:** <security + architecture leads>

## Scope

<Components covered by this threat model. Out-of-scope components named
explicitly — they have their own threat model or are covered by an existing one.>

## Trust Boundaries

<List from the SystemDesignDoc. Each boundary is a place where untrusted data
crosses into trusted territory.>

1. **Boundary A:** <where + what crosses>
2. **Boundary B:** <where + what crosses>

## STRIDE Analysis

<One subsection per boundary. Per category, name specific threats with attacker
capability + asset at risk. Empty categories explicitly noted as "none identified".>

### Boundary A

| STRIDE | Threat | Likelihood × Impact | Mitigation |
| --- | --- | --- | --- |
| **S**poofing | <attacker with X could impersonate Y; gains access to Z> | <L × M / M × H / ...> | <concrete mitigation> |
| **T**ampering | <...> | <...> | <...> |
| **R**epudiation | <...> | <...> | <...> |
| **I**nfo disclosure | <...> | <...> | <...> |
| **D**enial of service | <...> | <...> | <...> |
| **E**levation of privilege | <...> | <...> | <...> |

### Boundary B

<same structure>

## High-Risk Threats Requiring Design Changes

<Threats whose mitigation requires going back to design. Names the change +
the owning bundle for the rework.>

- ...

## Required Reviews

- [ ] Architecture review (`architecture.review-design`) — if mitigations
      require structural changes.
- [ ] PIA (`security.run-pia`) — if `pii_restricted` data is in scope.
- [ ] Customer comms (`content.write-advisory`) — only if exploited findings
      necessitate disclosure (separate workflow).

## References

- SystemDesignDoc: <link>
- Related SecurityFindings: <ids>
- OWASP / NIST citations: <list>
