# Idelium Versioning and Compatibility Policy

This policy defines how Idelium components, contracts, schemas, DSL documents,
and coordinated product releases are versioned and declared compatible.

## Versioned components

Idelium publishes or operates the following versioned units:

- `idelium-api`
- `idelium-web`
- `idelium-cli`
- `idelium-docker`
- DSL language versions
- execution-result schemas
- plugin manifest schemas
- Docker Compose topology profiles
- coordinated product releases

Each published component must expose or document its version in release notes,
tags, package metadata, image tags, or runtime diagnostics.

## Semantic versioning

Use semantic versioning for published components:

```text
MAJOR.MINOR.PATCH
```

- `MAJOR`: incompatible contract, runtime, schema, migration, or deployment
  changes.
- `MINOR`: backward-compatible functionality or new optional contracts.
- `PATCH`: backward-compatible fixes, documentation corrections, and operational
  hardening that does not change public behavior.

Pre-release identifiers may be used for release candidates:

```text
1.2.0-rc.1
```

## Contract versions

Contracts that can evolve independently from component packages must include
explicit schema or language versions:

- DSL documents use a declared language version.
- execution-result payloads use a schema version.
- plugin manifests use a manifest API version.
- API responses that introduce long-lived public contracts document the contract
  version or compatibility window in release notes.

Do not infer a schema version only from a package version when the payload is
persisted or exchanged across components.

## Independent release scenarios

Components may release independently when the change is backward compatible:

- `idelium-web` can release UI-only changes against the current supported API
  contracts.
- `idelium-cli` can release local-runtime fixes if existing API contracts remain
  supported.
- `idelium-api` can release additive endpoints or optional fields without forcing
  an immediate Web or CLI release.
- `idelium-docker` can release documentation, topology, and operations fixes when
  image tags and component compatibility remain explicit.

Independent releases must still document affected contracts and verification.

## Coordinated release scenarios

Use a coordinated release when:

- API behavior changes require Web and CLI updates;
- database migrations are not fully backward compatible;
- Docker topology changes deployment order or health checks;
- DSL, result schema, or plugin manifest behavior changes across CLI/API/Web;
- security, tenant-isolation, or credential-handling behavior changes;
- rollback requires restoring more than one component.

Coordinated releases must list every component version or commit in the release
notes.

## Compatibility matrix

Every coordinated release should include a matrix like this:

| Product release | API | Web | CLI | Docker | DSL | Result schema | Plugin manifest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1.0.x | `<api-version>` | `<web-version>` | `<cli-version>` | `<docker-version>` | `<dsl-version>` | `<schema-version>` | `<manifest-version>` |

If a component is unchanged, record the previous compatible version instead of
leaving the cell blank.

## Discoverability requirements

Version metadata must be discoverable:

- API: health endpoint, release notes, or deployment metadata;
- Web: build metadata or release notes;
- CLI: `idelium --help` or startup diagnostics plus package metadata;
- Docker: image tags, Compose files, and release notes;
- DSL/schema/plugin contracts: explicit fields inside the document or payload.

## Compatibility windows

Deprecations must include:

- the first version that emits the deprecation;
- the planned removal version or minimum support window;
- migration guidance;
- affected repositories;
- rollback or recovery notes when removal affects persisted data.

Security fixes may shorten compatibility windows, but the release notes must say
why.

## Non-mutating verification

Versioning verification should:

- check that release notes include component source references;
- check that compatibility matrices have no blank affected-component cells;
- check that schema-bearing payloads contain explicit versions;
- check that public Idelium references use `idelium.org`;
- check that no secrets or customer data are included in version metadata;
- avoid rewriting release files during CI checks.

## Related policies

- [Changelog and release notes](changelog-and-release-notes.md)
- [Coordinated release train](coordinated-release-train.md)
- [Release and rollback runbook](release-and-rollback-runbook.md)
- [Supply-chain provenance](supply-chain-provenance-policy.md)
- [RFC process](../rfc/README.md)
