<!--
Template: ReleaseNotes — user-facing summary of a shipped release.
Authored by: content.write-release-notes.
Required: lead with breaking changes (don't bury); user-language, not engineer-language;
every breaking change has migration steps.
Remove this block before publishing.
-->

# Release Notes — v<x.y.z>

- **Release date:** <YYYY-MM-DD>
- **ReleaseRecord:** <RR-id>
- **Owner:** <product + content leads>

<!--
ORDER MATTERS. Breaking changes FIRST so readers don't miss them.
Then new features (visible), improvements (visible), bug fixes (visible),
deprecations.
-->

## ⚠ Breaking Changes

<If none, write "No breaking changes in this release." and remove the items below.>

### <Breaking change 1>

- **What changed:** <user-visible behavior>
- **Who is affected:** <named group / use case>
- **Migration:**
  1. ...
  2. ...
- **Deadline:** <by which date users must migrate>
- **Reference:** <RFC / ADR / docs link>

## ✨ What's New

- **<Feature name>:** <one-sentence value for the user>. <Link to docs.>
- **<Feature name>:** <...>

## 🔧 Improvements

- <user-noticeable improvement>
- <...>

## 🐛 Fixes

- <bug fixed — what the user no longer experiences>
- <...>

## 🪦 Deprecations

<If none, omit this section.>

- **<Capability name>:** deprecated as of this release; removal scheduled
  for v<x.y.z+N>. Migration: <link to sunset notice>.

## 🙏 Credits

<Optional: external contributors, researchers who disclosed security issues
under coordinated disclosure (per their preference).>

## References

- PRD(s) shipped: <ids>
- Notable PRs: <links>
- Status page: <link>
- API contract diff: <link if applicable>
