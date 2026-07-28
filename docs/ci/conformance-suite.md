# Cross-repository conformance suite

The Idelium conformance suite defines shared, versioned fixtures and assertions
for Web, API, CLI, and Docker release gates.

It is intentionally repository-neutral. Component repositories may implement the
same fixture with their native test framework, but the expected contracts must
remain aligned with this document.

## Fixture source

The canonical fixture is
[`conformance-fixtures/core-flows.v1.json`](conformance-fixtures/core-flows.v1.json).

The fixture is versioned with:

- `schemaVersion`
- `fixtureVersion`
- `compatibilityWindow`
- named `flows`
- required `securityAssertions`
- required `diagnostics`
- required `gateThresholds`

Changes to fixture meaning, required assertions, thresholds, or compatibility
windows require a decision record through the RFC process.

## Required flow coverage

Every implementation must cover these flow families:

| Flow | Required coverage |
| --- | --- |
| Authentication | Successful login, failed login, logout, session/CSRF boundary, API key boundary. |
| Tenant context | Tenant-scoped list/read/write access and cross-tenant denial. |
| Asset lifecycle | Project, environment, step, test, test cycle, plugin, and artifact lifecycle. |
| Cycle launch | Manual launch, queued execution, runner handoff, timeout, and failed dependency. |
| Parallel execution | Isolated workers, bounded resources, deterministic report merge. |
| Reporting | JSON, HTML, Markdown, JUnit, result schema, redaction, and artifact descriptors. |
| Backward compatibility | Current supported upgrade path and one legacy fixture path. |

## Negative-security assertions

Conformance implementations must include negative checks for:

- cross-tenant data access;
- unauthorized project access;
- artifact retrieval outside the tenant and project scope;
- leaked API keys, session identifiers, authorization headers, passwords, or
  customer payloads in logs, reports, screenshots, and CI diagnostics;
- unbounded waits, unbounded retries, and missing timeout errors;
- unsupported CLI/API/Web schema versions.

## CI behavior

CI jobs using this fixture must:

1. run without production credentials;
2. use immutable component references;
3. fail when required thresholds are not met;
4. publish actionable diagnostics as artifacts;
5. redact secret-like values before logs or artifacts are uploaded;
6. keep thresholds read-only unless an RFC or release decision explicitly changes
   them.

## Upgrade and legacy paths

At least one supported upgrade path must be exercised from a previous compatible
release train to the current train. The legacy path must prove that current
components either:

- execute the legacy fixture without behavior drift; or
- reject it with a documented migration and deprecation error.

## Non-mutating check

Run:

```bash
./scripts/conformance-suite-check.sh
```

The check verifies fixture structure, required flow names, security assertions,
diagnostic requirements, threshold protections, and the absence of forbidden
public domains or literal credentials.
