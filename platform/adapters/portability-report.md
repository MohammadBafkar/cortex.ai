# Portability Report v0

**Status:** Phase 9 deliverable. Single-plugin / single-skill validation per ROADMAP.md
**Generated:** 2026-05-21.

## Adapters built

| Adapter | Mode | Status |
| --- | --- | --- |
| `platform/adapters/to-copilot.sh` | full-plugin | ✅ emits Copilot CLI package; symlinks the canonical skill payloads |
| `platform/adapters/to-codex.sh --plugin` | full-plugin | ✅ emits Codex package with per-skill `agents.yaml` entries |
| `platform/adapters/to-codex.sh --skill` | single-skill | ✅ emits a minimal Codex agent from one SKILL.md |

## What's portable as-is

| Surface | Notes |
| --- | --- |
| SKILL.md frontmatter (open AgentSkills core) | Codex and Copilot both consume `name`, `description`, `argument-hint`, `allowed-tools`. Our extended fields (`type`, `produces_authoritative_artifacts`, `capability_interface_id`, `bundle_contract_id`) are silently ignored — they preserve coherence in the canonical source without breaking the ports. |
| SKILL.md body | Authored once in Claude Code tool vocabulary. The per-platform translation references co-located at `skills/<name>/references/{codex,copilot}-tools.md` map our tool names to native ones at the host boundary. |
| MCP server definitions | Universal across hosts. |
| Capability-contract markdown files | Documentation; passes through. |

## What needs the adapter to rewrite

| Surface | Adapter behavior |
| --- | --- |
| Manifest (`plugin.json` → `.copilot-plugin/plugin.yml` / `.codex-plugin/agents.yaml`) | Field-by-field translation. The native fields differ; the adapters carry the translation table. |
| Subagent declarations | Copilot wraps each as a Custom Agent in its plugin manifest. Codex doesn't support in-skill subagent dispatch — the adapter notes the gap rather than emit broken plumbing. |
| Slash commands | Mostly portable; frontmatter fields differ in optional positions. |

## What does NOT port (and where it's noted)

| Surface | Reason | Where noted |
| --- | --- | --- |
| Platform-owned hooks (PEP, audit-postuse, budget-track, session lifecycle) | Each host has its own permission/hook model. Replacements live in host-specific managed settings. | `dist/<plugin>/.copilot-plugin/ADAPTER_NOTES.md`; `dist/<plugin>/.codex-plugin/ADAPTER_NOTES.md` |
| Composite-artifact contributor subdirs | Depend on per-path PEP enforcement using `state-ownership.json`. Neither Codex nor Copilot has an equivalent today. | Adapter notes; the emitted skill explicitly degrades to single-contributor mode. |
| Workflow YAML catalog (`plugins/marketplace/workflows/`) | Claude Code-specific. Cross-bundle orchestration on Codex / Copilot requires host-side glue. | Adapter notes. |
| LSP servers, monitors | Claude Code-only primitives. | Not emitted by the adapters at all. |
| `.cortex/manifest.json` admission metadata | Marketplace-internal; other hosts ignore it. | Carried over verbatim — harmless on other hosts. |

## Per-skill translation references

The pattern from `obra/superpowers`: each skill ships its own translation reference under `skills/<name>/references/`. Verified for `engineering.review-diff`:

- `plugins/engineering/skills/review-diff/references/codex-tools.md`
- `plugins/engineering/skills/review-diff/references/copilot-tools.md`

The pattern scales to every skill — but the references are authored when a port is genuinely needed, not eagerly. Authors are encouraged to add the reference file when the skill's tool footprint changes meaningfully.

## Next 5 plugins likely to port cleanly

(read-only or near-read-only skills with no composite-artifact patterns)

1. `methodology` — all skills are ephemeral and tool-light. Highest port confidence.
2. `quality` (read-side: `run-unit-tests`) — Bash + Read + Write, no composite.
3. `marketplace` (query-audit only) — Bash + Read, no composite.
4. `release-operate` (`observe`, `track-finops`, `emit-dora`) — Read-heavy + Bash; no composite.
5. `content` (`write-doc`, `write-release-notes`) — Read + Write; the host-side equivalent of `connector-docusaurus` differs but the skill body is portable.

## Next 5 plugins likely to need significant work

(heavy on composite artifacts, hook-driven flows, or platform-mediated primitives)

1. `engineering.review-diff` in the composite-review mode — requires `marketplace.merge-review` orchestration which has no Codex/Copilot equivalent.
2. `platform.run-pipeline` + `platform.apply-iac` — depend on the platform-owned PEP enforcing `iac:apply` HITL via M-tier checkpoints. Host-side equivalents exist but are not 1:1.
3. `security.review-iam` — Tied to the platform's permission-broker registry; no equivalent on Codex/Copilot until they expose grant inspection.
4. `release-operate.release` — Multi-stage HITL with `RolloutPlan` semantics is router-mediated. Codex/Copilot have no workflow runtime.
5. `data.promote-model` — Two-person approval (checkpoint 11) is HITL Router-mediated; host equivalents are coarser.

## Recommendation

Per ROADMAP.md the Phase 9 scope was "one plugin to Copilot, one skill to Codex". Both built and exercised. The follow-up (Phase 10 or P1 of post-MVP1) should:

1. Extend per-skill translation references to the top 5 portable plugins.
2. Author conformance fixtures per-host (`conformance run-golden --agent=copilot-cli`, `--agent=codex-cli`) so drift between agent versions surfaces weekly.
3. Decide whether to invest in workflow-runtime equivalents on Codex/Copilot or treat those hosts as "skill-only" targets.

The portable core is `SKILL.md + MCP + capability-contract markdown`. The non-portable core is everything that depends on the platform's PEP, audit sink, parent workflow executor, and HITL router. This split is stable; design choices that strengthen the portable core (per-path disjointness encoded in artifact schemas, methodology-skill inline composition) help every host. Choices that strengthen the non-portable core (deeper workflow YAML, more HITL automation) help Claude Code only.
