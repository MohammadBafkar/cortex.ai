# Connectors

Connectors are plugin wrappers around external systems, usually via MCP or a
small host-native command surface.

V1 publishes only connectors used by the default workflow spine.

## Published In V1

| Connector | Purpose | Status |
| --- | --- | --- |
| `connector-github` | Repository, branch, diff, PR metadata | MVP |
| `connector-github-actions` | CI workflow and run metadata | MVP |

## Incubating

These connector directories exist, but they are not part of the default catalog
until an admitted workflow needs them and their runtime behavior is verified:

- `connector-datadog`
- `connector-jira`
- `connector-kubernetes`
- `connector-launchdarkly`
- `connector-pagerduty`
- `connector-snyk`
- `connector-statuspage`
- `connector-terraform`

## Policy

- Do not declare a connector dependency unless the connector exists on disk.
- Do not publish a plugin if one of its required connectors is missing.
- Do not add placeholder connectors to make a manifest look complete.
- Prefer external official plugins when they are stronger than local wrappers.

## Connector Layout

```text
plugins/connector-<system>/
  .claude-plugin/plugin.json
  .cortex/manifest.json
  .cortex/conformance.yaml
  hooks/
```

MCP configuration should remain host-native. Cortex metadata stays in
`.cortex/`.

