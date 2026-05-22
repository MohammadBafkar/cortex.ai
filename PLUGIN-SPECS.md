# Plugin Specs

The active plugin contract is defined in [`SPEC.md`](./SPEC.md).

The earlier full bundle taxonomy has been archived at
[`docs/archive/0.x-future-plugin-specs.md`](./docs/archive/0.x-future-plugin-specs.md).

## V1 Published Plugins

The marketplace catalog should publish only:

- `marketplace`
- `methodology`
- `engineering`
- `quality`
- `platform`
- `connector-github`
- `connector-github-actions`

Other plugin directories are incubating. They should not appear in the default
catalog until they have real conformance fixtures, closed connector
dependencies, and a demonstrated workflow need.

## Sidecar Layout

```text
plugins/<name>/
  .claude-plugin/plugin.json
  .cortex/manifest.json
  .cortex/conformance.yaml
  skills/
  agents/
  commands/
  hooks/
```

The legacy sidecar name is retired.
