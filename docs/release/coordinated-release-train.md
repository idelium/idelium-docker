# Coordinated release train

This document defines the Idelium release train used to publish compatible Web,
API, CLI, Docker, runtime, browser, and test-tool combinations.

Use it together with:

- [Versioning and compatibility](versioning-and-compatibility-policy.md)
- [Changelog and release notes](changelog-and-release-notes.md)
- [Release and rollback runbook](release-and-rollback-runbook.md)
- [Supply-chain provenance](supply-chain-provenance-policy.md)
- [Release regression gates](../ci/release-regression-gates.md)

## Release train cadence

Idelium components may release independently only when the compatibility
contract remains backward compatible. A coordinated release train is required
when any change affects:

- API routes, authentication, tenant scoping, result contracts, or migrations;
- Web flows that depend on new API fields or changed routes;
- CLI request/response contracts, DSL versions, plugin contracts, or report
  schemas;
- Docker topology, ports, environment variables, images, health checks, or
  startup orchestration;
- Selenium, Appium, Postman/Newman, browser, Python, PHP, Node.js, or database
  support boundaries.

Release trains use immutable component references and produce one product
release record containing every source commit, version, artifact, checksum, and
rollback target.

## Supported compatibility matrix

The current release train must publish a matrix with at least these dimensions.
Concrete release notes replace `current train` with exact tags, package
versions, Docker digests, or full commit SHAs.

| Dimension | Supported train value | Verification owner | Required evidence |
| --- | --- | --- | --- |
| Product train | Current coordinated release | Release owner | Release note with all component refs. |
| `idelium-web` | Current compatible Web build | Web owner | Build metadata, Web CI, API route smoke tests. |
| `idelium-api` | Current compatible Laravel API | API owner | API tests, migration check, tenant isolation checks. |
| `idelium-cli` | Current compatible CLI package | CLI owner | CLI unit tests, package metadata, Postman/Newman, Selenium, and Appium contract tests. |
| `idelium-docker` | Current stack definition | Docker owner | Compose validation, health checks, startup smoke test. |
| Python | Supported CLI Python range | CLI owner | Python matrix output and package classifiers. |
| PHP | Supported API PHP range | API owner | Composer platform and API CI output. |
| Node.js | Supported Web/API asset build runtime | Web/API owners | Lockfiles, npm audit status, build output. |
| Database | Supported MariaDB version | Docker/API owners | Migration, backup, restore, and rollback evidence. |
| Browser | Supported browser families and versions | Web/CLI owners | Browser smoke tests and Selenium Grid matrix. |
| Selenium | Supported Selenium client and Grid versions | CLI/Docker owners | Selenium contract and cross-browser smoke tests. |
| Appium | Supported Appium server and driver families | CLI/Docker owners | Capability validation and mobile topology evidence. |
| Postman/Newman | Supported Newman runtime version | CLI owner | Newman availability check and collection conformance report. |
| DSL | Supported DSL language and AST schema versions | CLI owner | DSL parser/runtime validation. |
| Result schema | Supported execution-report schema | CLI/API/Web owners | Report contract tests and viewer compatibility. |
| Plugin manifest | Supported plugin API versions | CLI/API/Web owners | Plugin manifest validation and migration note. |

## Release candidate gates

A release candidate cannot be promoted until the release owner records evidence
for these gates:

1. Component repositories are checked out at immutable full commit SHAs.
2. `./scripts/cross-repository-contract-gate.sh` passes.
3. `./scripts/supply-chain-provenance-gate.sh` passes.
4. API migrations are tested forward and rollback implications are documented.
5. Docker startup, health readiness, backup, restore, upgrade, and rollback
   checks pass or are explicitly marked not applicable with approval.
6. CLI compatibility checks pass for Selenium, Appium, Postman/Newman, DSL,
   plugin API, result schema, and report exports.
7. Web compatibility checks pass for project-scoped routes, authentication,
   tenant-aware API calls, result viewers, and enterprise UX flows.
8. Security checks review dependency changes, credential redaction, tenant
   isolation, least privilege, and artifact access.
9. Release notes include changelog, migration, deprecation, support window,
   known issues, checksums, provenance, and rollback target.

## Deprecation and removal gates

Deprecation follows the compatibility policy and must include:

- announcement in English release notes;
- telemetry or usage evidence where the feature can be observed safely;
- migration guide or replacement behavior;
- support window and first unsupported release;
- removal RFC when the change affects public API, CLI, DSL, plugin, result,
  configuration, or persisted-data contracts.

Removal is blocked until the support window has expired and the migration guide
has been available for at least one compatible release train.

## Supply-chain and artifact evidence

Each published package or image must include:

- Apache-2.0 license evidence;
- source commit or tag;
- package version, Docker tag, or registry digest;
- lockfile or dependency manifest reference;
- checksum, registry digest, or signature when supported;
- SBOM or dependency inventory when produced by the component pipeline;
- provenance record linking the artifact to the release workflow.

If SBOM or signing automation is temporarily unavailable for a component, the
release note must record the gap, owner, compensating check, and follow-up issue.

## Publication rule

Publishing is allowed only when the matrix, release candidate gates, supply-chain
evidence, and rollback decision are complete for the release scope.

Publishing is blocked when:

- a component is referenced by a moving branch or mutable tag;
- a required gate fails without an approved scope reduction;
- a migration lacks rollback or forward-fix guidance;
- a published artifact cannot be traced to source commit and license evidence;
- security or tenant-isolation implications are unresolved.
