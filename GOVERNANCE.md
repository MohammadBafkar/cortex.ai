# Governance

The active governance model is intentionally small. See [`SPEC.md`](./SPEC.md)
for the full V1 contract.

The previous governance design has been archived at
[`docs/archive/0.x-future-governance.md`](./docs/archive/0.x-future-governance.md).

## V1 Mandatory Gates

V1 has three mandatory human gates:

1. production deploy or irreversible infrastructure apply;
2. marketplace plugin admission;
3. break-glass identity or permission escalation.

Everything else is configurable future policy. Do not make the default product
feel like an enterprise approval simulator before the core workflow is proven.

## Production Principle

Governance should be enforced by small mechanisms that users can understand:

- clear ownership of state paths;
- conformance before admission;
- audit after tool use;
- human approval for irreversible actions.

Long RACI matrices, dozens of inactive checkpoints, and public-marketplace
publisher tiers are out of scope for V1.

