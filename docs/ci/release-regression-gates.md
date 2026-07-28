# Idelium Release Regression Gates

Release regression gates prevent incompatible Idelium component combinations
from being published or deployed. They complement the
[cross-repository contract gate](cross-repository-contracts.md) and the
[versioning policy](../release/versioning-and-compatibility-policy.md).

## Gate objectives

Each release gate must:

- validate a pinned CLI, API, Web, Docker, DSL, schema, and plugin-manifest
  combination;
- fail before publication when a component boundary is incompatible;
- report the failing boundary without printing credentials, tenant data, report
  payloads, session values, or authorization headers;
- run in a non-mutating mode that can be repeated by reviewers;
- use immutable commits, tags, package versions, or image tags as inputs.

## Required input metadata

Coordinated releases must provide:

| Input | Required metadata |
| --- | --- |
| API | Git commit or tag, migration status, API contract notes. |
| Web | Git commit or tag, build metadata, API compatibility notes. |
| CLI | Git commit or tag, package version, runtime contract notes. |
| Docker | Git commit or tag, Compose files, image tags or build revisions. |
| DSL | Supported language version and migration notes. |
| Result schema | Supported schema versions and redaction contract. |
| Plugin manifest | Supported manifest API versions and approval policy. |

The gate must reject moving references when a release candidate is being
published.

## Compatibility matrix

Use this matrix during release review:

| Boundary | Gate check | Failure example |
| --- | --- | --- |
| CLI ↔ API | CLI can fetch configuration and report canonical results against the API contract. | CLI expects a required field that the API does not return. |
| Web ↔ API | Web uses project-scoped endpoints and can render execution state returned by the API. | Web assumes a result field that is missing or unversioned. |
| Docker ↔ API/Web | Compose topology exposes healthy API and Web services using explicit image/build refs. | API health is green locally but not through the frontend route. |
| CLI ↔ DSL/schema | CLI accepts declared DSL and result schema versions. | A persisted DSL document declares an unsupported language version. |
| Plugin manifest ↔ CLI/API/Web | Approved plugin metadata is present and compatible with the CLI execution boundary. | Plugin approval or source hash is missing. |

## Gate stages

1. Resolve immutable component references.
2. Verify repository checkout refs match the declared release metadata.
3. Validate CI examples and Compose syntax without mutating files.
4. Run static cross-repository contract checks.
5. Run representative smoke tests when credentials and local services are
   intentionally provided by the operator.
6. Record the gate output in the release notes before publication.

## Failure behavior

Failures must identify:

- the boundary that failed;
- the expected contract;
- the repository or file that needs review;
- whether the failure blocks publication or only blocks a specific optional
  topology.

Failures must not include secrets, request bodies, customer records, API keys,
authorization headers, cookies, or raw execution payloads.

## Local non-mutating command

With sibling repositories checked out next to `idelium-docker`, run:

```bash
IDELIUM_DOCKER_REF="$(git rev-parse HEAD)" \
IDELIUM_API_REF="$(git -C ../idelium-api rev-parse HEAD)" \
IDELIUM_WEB_REF="$(git -C ../idelium-web rev-parse HEAD)" \
IDELIUM_CLI_REF="$(git -C ../idelium-cli rev-parse HEAD)" \
./scripts/cross-repository-contract-gate.sh
```

For local development the ref variables can be omitted. For release candidates
they must be full commit SHAs.

## Publication rule

A coordinated release cannot be published until:

- the gate passes for the release matrix;
- release notes include the pinned source references;
- rollback notes describe the previous compatible matrix;
- unresolved failures are either fixed or explicitly removed from release scope.

## Related policies

- [Changelog and release notes](../release/changelog-and-release-notes.md)
- [Release and rollback runbook](../release/release-and-rollback-runbook.md)
- [Versioning and compatibility](../release/versioning-and-compatibility-policy.md)
