# Idelium Changelog and Release Notes Policy

This policy defines how Idelium changelogs and release notes are prepared,
reviewed, and published across the Idelium repositories.

## Goals

Release notes must be:

- traceable to immutable commits or tags;
- reviewable before publication;
- grouped by component ownership;
- explicit about features, fixes, security changes, deprecations, migrations,
  deployment impact, and rollback considerations;
- written in English.

## Immutable inputs

Generate or draft release notes only from immutable references:

- Git tags;
- commit SHAs;
- merged pull requests tied to commits;
- reviewed issues linked from the release scope.

Do not generate release notes from a moving branch name without recording the
resolved commit SHA.

## Required sections

Every coordinated Idelium release note must include:

```markdown
# Idelium Release <version>

## Source references

- idelium-api: <tag-or-commit>
- idelium-web: <tag-or-commit>
- idelium-cli: <tag-or-commit>
- idelium-docker: <tag-or-commit>

## Features

## Fixes

## Security

## Deprecations

## Migrations

## Compatibility

## Deployment notes

## Rollback notes

## Verification
```

If a section has no entries, write `No changes.` so reviewers can tell the
section was intentionally considered.

## Component ownership

Each entry must identify the owning component:

```markdown
- idelium-web: Added shareable execution filters. Commit: <sha>.
- idelium-cli: Hardened plugin subprocess execution. Commit: <sha>.
```

Cross-repository changes must list every affected component and link the parent
issue or RFC.

## Security and migration review

Security and migration sections are mandatory even for UI-only releases.
Reviewers must confirm:

- no secrets, credentials, customer data, or session values are included;
- tenant-isolation behavior is unchanged or explicitly documented;
- deprecations include compatibility windows;
- database, API, CLI, Docker, and persisted-data migrations include rollback or
  recovery notes.

## Review workflow

1. Draft release notes from immutable input references.
2. Component owners review entries for their repositories.
3. Security reviewer checks the Security section.
4. Operations owner checks Deployment notes and Rollback notes.
5. Release owner approves publication.
6. Published notes are linked from the release tag or deployment record.

Generated output must be committed or attached for review before publication.
Automation may prepare a draft, but it must not publish without explicit review.

## Non-mutating verification

Release-note verification should be reproducible and non-mutating:

- check that required sections exist;
- check that source references are commit SHAs or tags;
- check that empty sections use `No changes.`;
- check that public Idelium references use `idelium.org`;
- check that obvious secret patterns are absent;
- check that implementation issues, pull requests, or RFCs are linked when
  cross-repository behavior changes.

## Relationship to release and RFC processes

Use the [release and rollback runbook](release-and-rollback-runbook.md) for
deployment execution. Use the [RFC process](../rfc/README.md) when a release
changes compatibility windows, major contracts, deployment topology, persistence,
or security boundaries.
