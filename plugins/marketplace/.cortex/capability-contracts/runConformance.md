---
capability_interface_id: runConformance
version: 1
bundle_contract_id: plugin-conformance-eval
schema_in: PluginPackage@v1
schema_out: ConformanceVerdict@v1
---

# runConformance@v1

Runs the platform conformance harness against a Plugin Package and produces a signed `ConformanceVerdict@v1`. Wraps `platform/conformance/conformance` (the CLI tool).

## Inputs

- `PluginPackage@v1` (required) — a reference to a plugin directory under `plugins/`. The plugin's `.cortex/contract.json` and `.cortex/conformance.yaml` are loaded.

## Outputs

- `ConformanceVerdict@v1` written to durable CAS with mutable reference `verdict_<plugin>_<version>`. Schema: `platform/schemas/conformance-verdict.v1.json`.

## Procedure (delegated to the CLI)

The marketplace plugin's `run-conformance` skill is a thin wrapper that shells out to:

```bash
$CORTEX_HOME/platform/conformance/conformance all <plugin-dir>
```

The CLI handles: `validate`, `run-golden`, `run-adversarial`, `check-perf`, `produce-verdict`. The wrapper exists so plugin authors can invoke conformance via `/conformance <plugin>` inside Claude Code rather than dropping to the shell.

## Cadence (per ROADMAP.md + GOVERNANCE.md)

- **Authors** run conformance locally on demand (`/conformance my-plugin`).
- **CI** runs full golden + adversarial on PRs that touch a plugin directory.
- **The marketplace catalog** runs conformance at publish time and signs the resulting attestation.
- **Sessions do not invoke conformance** (per-edit conformance is a performance killer — explicitly NOT done).

## Failure handling

- A verdict of `fail` blocks admission. **No flag bypasses this.**
- A verdict of `incomplete` (runtime skipped because the plugin isn't installed yet) blocks admission unless the admin sets the `--force-incomplete-admission` flag.
- A verdict of `pass` admits the plugin and signs the attestation.

## Admission gate

The gate is implemented at `${CORTEX_HOME}/platform/conformance/check-admission.sh`. It loads the latest `ConformanceVerdict@v1` for the plugin from CAS (via mutable reference `verdict_<plugin>_<version>`) and emits one of:

| Exit | Verdict | Meaning |
| --- | --- | --- |
| 0 | `pass`, or `incomplete` + force flag | admission allowed |
| 1 | `fail` | BLOCKED — fix conformance + re-run; no flag bypasses |
| 2 | `incomplete`, no force flag | paused — install + re-run `produce-verdict` to convert to `pass` |
| 3 | no verdict found | run conformance first |
| 4 | misuse | usage error |

The `/install-plugin` slash command invokes this gate as a pre-flight before any `claude /plugin install`. CI should also call it explicitly before publishing a verdict to the durable catalog.
