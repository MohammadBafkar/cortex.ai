# ADR Anti-Patterns

Cited by `engineering.propose-adr` (and `architecture.propose-adr` at P1). When
authoring an ADR, the model reads this in its current context and refuses to
emit an ADR that exhibits any of the patterns below.

## 1. Single-option ADR

> "We will use PostgreSQL." — no alternatives, no trade-offs.

**Why it's wrong:** an ADR is the record of a *decision* — a decision implies
choosing among options. If there's truly only one option, it's not a decision,
it's a constraint; document it as an NFR or a comment in the SystemDesignDoc.

**Fix:** name at least one alternative — "do nothing" or "use the existing X"
counts. Explain why it wasn't chosen.

## 2. Vague trade-offs

> "Option A is faster but Option B is simpler."

**Why it's wrong:** future-you (and the next reviewer) can't tell *how* much
faster, simpler in what sense, faster on which workload. The trade-off has no
falsifiable substance.

**Fix:** quantify or qualify. "Option A is faster at the p99 tail under
write-heavy workloads (the cache miss path); Option B has a smaller
operational surface (no separate process to monitor)."

## 3. Marketing prose for the chosen option

> "Our innovative caching strategy leverages best-of-breed Redis clustering."

**Why it's wrong:** ADRs are read by engineers years later trying to figure
out *why*. Marketing language adds noise and decays badly.

**Fix:** Plain technical English. "We chose Redis because <specific
property>."

## 4. Risks without mitigations

> "Risks: cache stampede, hot-key contention, memory pressure."

**Why it's wrong:** a risk without a mitigation isn't risk management; it's
list-making. Anyone could write the same list.

**Fix:** every medium/high risk gets a concrete mitigation. "Cache stampede →
add a 50ms request coalescing window on miss; verified in the load test."

## 5. Decision that's actually a PRD

> "We will let users export their data as CSV."

**Why it's wrong:** that's a *requirement* (user-visible behavior), not an
architecture decision. ADRs answer "how do we build this?", not "what should
we build?".

**Fix:** the answer to "what?" goes in the PRD. The ADR answers something
like "how do we structure the export job to handle accounts up to 5GB
without holding a memory copy?"

## 6. Status: accepted with no review trail

**Why it's wrong:** "accepted" is the post-review state. An ADR can be
"proposed" without reviews; promoting to "accepted" requires named reviewers
who signed off. The conformance harness rejects an ADR whose `Status:
accepted` doesn't list reviewers.

**Fix:** keep status as `proposed` until reviews land. Then list reviewers
explicitly.

## 7. Editing prior ADRs in place

**Why it's wrong:** ADRs are records. Editing an old one rewrites history.
The convention is to author a new ADR that supersedes the old one — the old
one stays readable, the new one is the current truth.

**Fix:** new ADR titled "Supersedes ADR-007: Caching strategy revision". Old
ADR's status flips to `superseded by ADR-NEW` and adds a one-line
back-reference. The supersession is captured in *one place* (the new ADR),
not by rewriting both.

## 8. Reference loop

When a brand-new ADR points only at "see the SystemDesignDoc", and the
SystemDesignDoc says "see the relevant ADR" — neither contains the decision.

**Fix:** the decision lives in the ADR. The SystemDesignDoc *cites* the ADR
but doesn't paraphrase it.
