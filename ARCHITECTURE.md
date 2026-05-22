# Architecture

The active architecture is defined in [`SPEC.md`](./SPEC.md).

The previous 1,300-line architecture document was useful design exploration, but
it mixed V1 requirements with future platform ideas. It has been archived at
[`docs/archive/0.x-future-architecture.md`](./docs/archive/0.x-future-architecture.md).

## Current Architecture Summary

cortex.ai is a small internal coding-agent marketplace:

- Claude Code-native first;
- portable `SKILL.md` content for Codex, Copilot, Cursor, and similar agents;
- `.cortex/manifest.json` sidecar metadata for Cortex admission;
- host-native manifests kept separate;
- routing separated from execution;
- workspace-state handoff through `.agents/state/`;
- conformance and audit used as production gates, not decorative docs.

Load-bearing details now live in `SPEC.md` so contributors do not need to hold a
large research document in their head to make a safe change.

