# cortex.ai Roadmap

This roadmap is intentionally staged. Each phase has a small number of
deliverables and an exit test. Do not start broadening the catalog until the
current spine is installable, testable, and used on real work.

## Phase 0: Honest Baseline

Target: 1 week.

Deliverables:

- Replace the pre-1.0 design-doc constellation with `SPEC.md` and this roadmap.
- Archive exploratory docs under `docs/archive/`.
- Rename sidecar metadata to `.cortex`.
- Rename repo-root environment references to `CORTEX_HOME`.
- Reduce the published marketplace catalog to the V1 default plugin set.
- Mark non-default plugin directories as incubating.

Exit test:

- legacy sidecar and environment names have no implementation hits outside
  `docs/archive/`.
- `jq '.plugins[].name' .claude-plugin/marketplace.json` lists only V1 defaults.

## Phase 1: Installable MVP

Target: 2 weeks.

Deliverables:

- Add `/cortex-init`.
- Add `bin/cortex init`, `bin/cortex verify`, and `bin/cortex emit` wrappers for
  non-Claude workflows.
- Install the default plugin set from one command path.
- Install or validate managed hook settings without manual copy/paste.
- Generate a local `.agents/state/` skeleton in the target project.
- Fail clearly when prerequisites are missing.

Exit test:

- A fresh test repo can install Cortex and run `/cortex-verify` without editing
  shell profiles by hand.

## Phase 2: Real Conformance

Target: 2 weeks.

Deliverables:

- Add `.cortex/conformance.yaml` fixtures for the five MVP plugins.
- Add golden, adversarial, and boundary fixtures.
- Validate command and agent frontmatter, not just skills.
- Validate connector dependency closure against the published catalog.
- Validate workspace-state ownership against actual declared paths.
- Treat missing `ajv`, `jq`, or runtime fixtures as failures.
- Add signed or content-addressed `ConformanceVerdict@v1`.

Exit test:

- `platform/conformance/conformance all plugins/<mvp-plugin>` runs without
  skipped runtime checks.

## Phase 3: Working Spine

Target: 2 weeks.

Deliverables:

- Implement `marketplace.route` as the prompt-to-capability planner.
- Keep worker subagents leaf-only; parent commands execute route plans.
- Make `/implement <story>` run:
  route -> engineering -> quality -> platform -> review -> optional approval.
- Make `/review`, `/audit`, and `/conformance` useful without reading docs.
- Add `/cortex-trace <run-id>` for audit timelines.
- Suppress verbose announcements by default.

Exit test:

- A developer can run one realistic feature through the spine in a disposable
  repo and inspect the trace afterward.

## Phase 4: Portable Packaging

Target: 3 weeks.

Deliverables:

- Add `.codex-plugin/plugin.json` emitter.
- Add Copilot emitter for `.github/skills/` and instructions.
- Add Cursor emitter for rules and plugin metadata.
- Add `platform/adapters/verify-emit.sh`.
- Smoke-test one high-value skill, likely `engineering.review-diff`, on Claude
  Code, Codex, Copilot, and Cursor.
- Document degraded behavior for hooks, HITL, and audit on each host.

Exit test:

- One portable skill can be installed and invoked successfully on every target
  listed in the portability matrix.

## Phase 5: Production 1.0

Target: 4 weeks after Phase 4.

Deliverables:

- Run a 30-day internal observation window on real work.
- Record adoption friction, routing misses, false conformance passes, and hook
  blocks.
- Fix all SEV1/SEV2 issues found during observation.
- Publish a compatibility matrix for installed agent hosts.
- Freeze V1 docs and tag a release.

Exit test:

- The MVP spine has repeated real usage, conformance is not theatrical, and the
  published docs match behavior.

## After 1.0

Add one domain at a time only when there is a real workflow demanding it.

Candidate order:

1. `security`
2. `architecture`
3. `release-operate`
4. `product`
5. `content`
6. `data`

Language-specific skills remain external by default. Create first-party language
plugins only for internal standards that external catalogs cannot satisfy.
