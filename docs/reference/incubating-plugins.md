# Incubating Plugins

These directories are intentionally not published in the default V1 catalog.
They remain useful source material, but they need real conformance fixtures,
closed connector dependencies, and a demonstrated workflow before admission.

Domain candidates:

- `product`
- `architecture`
- `security`
- `release-operate`
- `content`
- `data`
- `infra-kubernetes`

Connector candidates:

- `connector-datadog`
- `connector-jira`
- `connector-kubernetes`
- `connector-launchdarkly`
- `connector-pagerduty`
- `connector-snyk`
- `connector-statuspage`
- `connector-terraform`

Language plugins:

- `lang-python`
- `lang-typescript`
- `lang-dotnet`

Default position: do not ship first-party language plugins. Prefer maintained
external catalogs unless Cortex needs to encode internal policy that those
catalogs cannot represent.

