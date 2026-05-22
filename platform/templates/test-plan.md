<!--
Template: TestPlan — input to quality.write-integration-test (and full quality v1.x suite).
Used as scaffolding for the TestSuite@v1 envelope when authoring crosses module boundaries.
Required: scope (in/out), test type, fixtures, environment isolation, exit criteria.
Remove this block before storing.
-->

# Test Plan: <feature / module>

- **Owner:** <quality lead>
- **PR / artifact under test:** <PR-id or TestSuite-id>
- **Test type:** <unit | integration | contract | mutation | performance | e2e>

## In Scope

<What the suite covers — modules, behaviors, error paths.>

## Out of Scope

<What this suite explicitly does NOT cover. Note who covers those.>

## Fixtures

| Fixture | Source | Notes |
| --- | --- | --- |
| <name> | <inline / file / DB seed / API mock> | <e.g., "captured from prod 2026-04, anonymized"> |

## Environment

- **Test DB:** <ephemeral container / shared dev / production-mirror>
- **External services:** <real / recorded / mocked at the outer boundary>
- **Isolation:** <how tests don't interfere with each other or with prod>

## Cases

| Id | Description | Expected behavior |
| --- | --- | --- |
| <C-1> | <input shape + action> | <observable outcome + assertions> |
| <C-2> | <...> | <...> |

### Per case: setup / act / assert

```
# C-1
Given: <preconditions, fixtures>
When: <action under test>
Then: <assertions — multiple OK; each independently fails the case>
And: <invariants that MUST hold regardless of the test path>
```

## Exit Criteria

- All cases pass on the green path.
- All cases for documented error paths fail with the expected error code.
- No state leakage between cases (each leaves the environment as it started).
- Coverage of the changed surface ≥ <threshold>% — confirmed by
  `quality.run-mutation-tests` for behavior-bearing branches.

## Flake Policy

- 1 automatic retry on a per-case basis.
- Three flakes in seven days → surface as `quality` feedback symptom; treat
  as a real bug, not "just a flake".

## References

- PR / SystemDesignDoc: <link>
- Related TestSuites: <ids>
