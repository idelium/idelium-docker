# Idelium Enterprise Roadmap

This roadmap is derived from
[`idelium-console-walkthrough-enterprise.md`](../idelium-console-walkthrough-enterprise.md)
and turns the walkthrough analysis into a release-oriented product and
engineering plan.

## Product positioning

Idelium is an open source, self-hosted test automation platform with an
enterprise-oriented foundation: a Web console, API control plane, CLI execution
engine, Docker deployment stack, reusable test assets, multi-project
organization, Selenium/Appium/Postman execution support, runtime environments,
platform targets, parallel execution concepts, and reporting.

The platform should be positioned as **enterprise-capable after hardening** until
the security, tenant isolation, credential lifecycle, plugin governance, audit,
artifact, and release-governance gates in this roadmap are complete.

## Roadmap principles

- Security and tenant isolation are product foundations, not optional features.
- Documentation, source comments, diagnostics, and release notes must be in
  English.
- Every behavioral change requires a regression test at the lowest useful level.
- API, CLI, configuration, database, and persisted-data changes must remain
  backward compatible or include an explicit migration and release note.
- Runner, plugin, artifact, and secret flows must be deny-by-default and
  observable.
- The Web UI can guide the user, but the API remains the authoritative security
  and authorization boundary.

## Release sequence

| Release | Theme | Target outcome |
| --- | --- | --- |
| R0 | Enterprise blockers | Safe tenant context, credentials, launcher, plugin, secret, audit, and artifact foundations. |
| R1 | QA asset governance | Versioned, reviewable, auditable Step/Test/Cycle/Environment lifecycle. |
| R2 | Execution control plane | Parallel launch, worker leasing, platform discovery, and reliable cancellation. |
| R3 | Results and observability | Structured execution timeline, artifact viewer, analytics, filters, and correlation. |
| R4 | API and UX standardization | API v1, OpenAPI, design system, enterprise data grids, terminology migration. |
| R5 | Operations and reliability | Backup/restore, upgrade tests, SLOs, observability stack, retention, archive. |
| R6 | Enterprise integrations | SSO/MFA/SCIM, OIDC workload identity, webhooks, Jira/Slack/Teams integrations. |
| R7 | Scale and governance | HA reference architecture, release train, compatibility matrix, SBOM/provenance. |

## R0 — Enterprise blockers

R0 must be completed before Idelium is described as production-ready for
regulated or mission-critical enterprise environments.

### Epic R0.1 — Secure remote launch channel

**Problem:** remote launch can become unsafe if TLS verification, hostname
validation, credentials, or timeouts are weak.

**Outcome:** agent launch traffic is authenticated, verified, scoped,
replay-resistant, finite, and observable.

**Implementation tickets**

- `IDL-SEC-001` — Restore TLS verification in remote launcher.
- `IDL-SEC-002` — Introduce short-lived run tokens and mTLS agent identity.

**Acceptance criteria**

- Untrusted, expired, or hostname-mismatched certificates block remote launch.
- Customer API keys are never sent to runners.
- Run tokens are signed, one-time, short-lived, tenant-scoped, and agent-scoped.
- Replay, wrong-agent, expired-token, and MITM tests fail safely.
- Logs and diagnostics never expose credentials or session identifiers.

### Epic R0.2 — Tenant context and impersonation safety

**Problem:** tenant switching must not mutate the authenticated user identity or
weaken tenant isolation.

**Outcome:** the authenticated actor is immutable, while active tenant context is
explicit, authorized, audited, and visible in the UI.

**Implementation tickets**

- `IDL-TEN-001` — Replace customer switch with explicit `TenantContext`.

**Acceptance criteria**

- User identity and active tenant are separate fields.
- Unauthorized tenant switches return `403`.
- All tenant-scoped queries use the validated active tenant.
- Impersonation requires reason, timeout, audit entry, and visible banner.
- Cross-tenant and IDOR tests cover every critical resource.

### Epic R0.3 — Service credentials and API key lifecycle

**Problem:** singleton/plaintext API keys are not acceptable for enterprise
machine-to-machine access.

**Outcome:** service accounts and credentials are scoped, hashed, revocable,
rotatable, expiring, auditable, and revealed only once.

**Implementation tickets**

- `IDL-KEY-001` — Add service accounts and hashed credentials.

**Acceptance criteria**

- Secrets are never retrievable after creation.
- Database records do not contain plaintext credentials.
- Revoked credentials fail immediately.
- Scope violations return a standard `403` response.
- Rotation supports a controlled overlap period.
- CLI and Web flows support the new credential model.

### Epic R0.4 — Plugin isolation and supply-chain governance

**Problem:** Python plugins are powerful and must not compromise runners,
network boundaries, filesystem boundaries, or secrets.

**Outcome:** plugins are versioned, reviewed, approved, scanned, sandboxed, and
executed with minimal capability.

**Implementation tickets**

- `IDL-PLG-001` — Add plugin approval, manifest, hash, and sandbox execution.

**Acceptance criteria**

- Unapproved plugins cannot execute.
- Plugin source/package hash is stored and verified.
- Execution is isolated by subprocess/container boundary with timeout and memory
  limits.
- Network egress is denied by default.
- Only explicitly requested secrets are available.
- Escape, timeout, filesystem, and unauthorized-network tests fail safely.

### Epic R0.5 — Secret references in environments

**Problem:** environment JSON can accidentally persist secrets in database
configuration, API responses, logs, reports, or screenshots.

**Outcome:** environments reference secrets by opaque handles, with runtime
resolution, centralized redaction, and audit.

**Implementation tickets**

- `IDL-SEC-003` — Add `secretRef` support for environment configuration.

**Acceptance criteria**

- Secret values never appear in persisted environment config.
- API export and UI display return redacted values.
- Runtime resolution is audited.
- Provider unavailability returns a classified error.
- Logs, reports, screenshots, and artifacts are covered by leakage tests.

### Epic R0.6 — Capability-based authorization

**Problem:** numeric role checks and UI-only authorization are too coarse for
enterprise governance.

**Outcome:** access is deny-by-default, capability-driven, enforced by API
policies, and reflected in the UI.

**Implementation tickets**

- `IDL-IAM-001` — Add capability-based authorization.

**Acceptance criteria**

- A permission catalog maps roles to capabilities.
- Laravel Policy/Gate checks protect every critical endpoint.
- The UI uses capabilities for affordances, but never as the security boundary.
- Unauthorized access returns a standard `403` error envelope.
- Role × resource × tenant tests cover all critical actions.

### Epic R0.7 — Append-only audit trail

**Problem:** enterprise operations need durable evidence for privileged actions,
configuration changes, launches, report access, and secret usage.

**Outcome:** audit events are append-only, correlated, searchable, redacted, and
retention-aware.

**Implementation tickets**

- `IDL-AUD-001` — Add append-only audit events.

**Acceptance criteria**

- Minimum events include login/logout/failure, tenant switch, account/role
  changes, project/config/test changes, plugin publication, key lifecycle,
  launch/cancel, report access, secret access, and platform status changes.
- Audit records include actor, tenant, project, action, target, redacted
  before/after, result, IP, and correlation ID.
- Application users cannot modify audit records.
- Audit export and retention are configurable.

### Epic R0.8 — Report and artifact contract

**Problem:** report buttons and documentation need a server-side contract for
artifact availability, authorization, retention, and integrity.

**Outcome:** reports and artifacts are described by authoritative descriptors,
stored centrally, checked by checksum, and downloaded through authorized short
links.

**Implementation tickets**

- `IDL-REP-001` — Add artifact service and report descriptor API.

**Acceptance criteria**

- CLI uploads JSON, JUnit, Markdown, HTML, screenshots, and logs through the
  artifact contract.
- Web enables report/download actions only from real descriptors.
- Cross-tenant artifact access is impossible.
- Checksums are verified.
- Expired or unavailable artifacts produce explicit states.

### Epic R0.9 — Password and session hardening

**Problem:** local authentication must remain safe even when SSO is not enabled.

**Outcome:** local login, password change, reset, lockout, and session lifecycle
are policy-driven and audited.

**Implementation tickets**

- `IDL-IAM-002` — Harden passwords and sessions.

**Acceptance criteria**

- Weak passwords are rejected server-side.
- Local password changes require current password.
- Login rate limit and lock policy are enforced.
- Session list/revoke is available.
- Reset behavior invalidates sessions according to policy.
- Error messages do not enumerate users.

## R1 — QA asset governance

### Epic R1.1 — Immutable asset versioning

**Implementation tickets**

- `IDL-QA-001` — Version Step, Test, Test Cycle, and Environment assets.

**Acceptance criteria**

- Every change creates a new immutable version.
- Runs preserve exact asset versions.
- Diff and rollback are available.
- Approved versions cannot be edited in place.
- CLI receives a consistent execution snapshot.

### Epic R1.2 — Review and approval workflow

**Implementation tickets**

- `IDL-QA-002` — Add Draft/In Review/Approved/Deprecated lifecycle.

**Acceptance criteria**

- Protected environments can require Approved assets.
- Reviewer and author can be forced to differ.
- Comments, approvals, and state transitions are audited.
- Deprecated assets remain runnable only under explicit compatibility rules.

### Epic R1.3 — Dependency graph and impact analysis

**Implementation tickets**

- `IDL-QA-003` — Add Step/Test/Cycle dependency graph.

**Acceptance criteria**

- A Step shows dependent Tests and Test Cycles.
- Deprecation displays impact before confirmation.
- API responses are paginated and indexed.
- Reference dataset tests avoid significant N+1 regressions.

## R2 — Execution control plane

### Epic R2.1 — Parallel and matrix launcher

**Implementation tickets**

- `IDL-RUN-001` — Add parallel launcher, execution matrix, quota, and
  idempotency.

**Acceptance criteria**

- Users can select multiple platforms, browsers, and environments.
- Concurrency and quota are validated server-side.
- Client-generated idempotency keys prevent double-submit duplicates.
- Run URL is returned immediately.
- Worker summary updates during execution.

### Epic R2.2 — Pipeline and run metadata

**Implementation tickets**

- `IDL-RUN-002` — Store immutable build, commit, branch, repository, initiator,
  and pipeline URL metadata.

**Acceptance criteria**

- Metadata is immutable after launch except controlled annotations.
- Execution filters include metadata fields.
- Reports include metadata.
- CLI and CI integrations populate metadata consistently.

### Epic R2.3 — Worker heartbeat, lease, and lost-worker recovery

**Implementation tickets**

- `IDL-RUN-003` — Add heartbeat, lease renewal, lost-worker state, and
  cancellation acknowledgement.

**Acceptance criteria**

- Workers renew leases periodically.
- Expired leases mark workers as `lost`.
- Aggregated run status distinguishes `lost` from `failed`.
- Cancellation waits for acknowledgement or timeout.
- Retry logic never duplicates an active worker.

### Epic R2.4 — Agent registration and capability discovery

**Implementation tickets**

- `IDL-PLT-001` — Add agent registration, approval, health, capability
  discovery, pools, and maintenance states.

**Acceptance criteria**

- Agents register as pending and must be approved.
- Agent version and capabilities are discovered.
- Incompatible agents do not receive runs.
- Maintenance/draining status removes agents from scheduling.

## R3 — Results and observability

### Epic R3.1 — Timeline and artifact viewer

**Implementation tickets**

- `IDL-OBS-001` — Add execution timeline, artifact viewer, and error taxonomy.

**Acceptance criteria**

- Step duration, status, diagnostics, screenshots, and logs are visible without
  forced download.
- Details have stable deep links.
- Secrets are redacted.
- Keyboard and screen-reader access is supported.

### Epic R3.2 — Filters, pagination, analytics, and executive views

**Implementation tickets**

- `IDL-OBS-002` — Add URL-persisted filters, server pagination, trend analytics,
  flakiness, and async export.

**Acceptance criteria**

- Filters persist in URLs.
- Large datasets use server-side pagination and indexed queries.
- Pass rate, duration, and flaky trends are visible.
- Large exports run asynchronously.

## R4 — API and UX standardization

### Epic R4.1 — API v1 and OpenAPI contract

**Implementation tickets**

- `IDL-API-001` — Publish `/api/v1`, OpenAPI, standard errors, pagination,
  idempotency, deprecation headers, and contract tests.

**Acceptance criteria**

- OpenAPI is validated in CI.
- Web and CLI use generated or contract-tested clients.
- Legacy routes have explicit deprecation windows and migration guides.

### Epic R4.2 — Design system and terminology migration

**Implementation tickets**

- `IDL-UX-001` — Introduce shared components, normalized terminology,
  localization, accessibility, and visual regression coverage.

**Acceptance criteria**

- `Customer` replaces legacy misspellings in UI copy.
- API aliases remain backward compatible for a defined window.
- Main pages use shared layout, modal, form, button, and action components.
- Icon-only actions have accessible names.

### Epic R4.3 — Enterprise data grid

**Implementation tickets**

- `IDL-UX-002` — Add server-side enterprise grids with search, filter, sort,
  pagination, bulk actions, column preferences, and standardized states.

**Acceptance criteria**

- Tables support large datasets without loading everything client-side.
- Empty, loading, error, and permission-denied states are standardized.
- Bulk archive/tag/export is permission-aware.

## R5 — Operations and reliability

### Epic R5.1 — Archive, soft delete, and retention

**Implementation tickets**

- `IDL-DAT-001` — Add non-destructive archive, restore, hard-delete jobs,
  impact summary, legal hold, and retention configuration.

**Acceptance criteria**

- Archive is reversible during a grace period.
- Hard delete requires authorized background job execution.
- Retention and legal hold are tenant-aware and audited.

### Epic R5.2 — Observability stack

**Implementation tickets**

- `IDL-OPS-001` — Add correlation IDs, structured redacted logs, RED/USE
  metrics, launch/run traces, dashboards, alerts, and runbooks.

**Acceptance criteria**

- Correlation ID flows through Web, API, CLI, and runner.
- Logs are structured and redacted.
- Dashboards and alerts cover launch, execution, storage, and worker health.

### Epic R5.3 — Backup, restore, and upgrade tests

**Implementation tickets**

- `IDL-OPS-002` — Add automated database/artifact backup, restore test,
  migration preflight, rollback documentation, and startup failure gates.

**Acceptance criteria**

- Backup and restore are tested on a schedule.
- RPO/RTO are documented.
- Upgrade and rollback paths are tested.
- Failed initialization never reports the stack as ready.

### Epic R5.4 — Shared conformance suite

**Implementation tickets**

- `IDL-TST-001` — Add cross-repository conformance coverage for login, tenant,
  cycle, launch, parallel execution, reporting, security boundaries, and
  compatibility.

**Acceptance criteria**

- Core Web/API/CLI flows have shared fixtures and assertions.
- Critical boundary tests run in CI.
- Coverage thresholds cannot be lowered without a decision record.

## R6 — Enterprise integrations

### Epic R6.1 — SSO, MFA, and lifecycle management

**Implementation tickets**

- `IDL-IAM-003` — Add OIDC/SAML SSO, MFA, SCIM provisioning, group-to-role
  mapping, break-glass account policy, and recovery tests.

### Epic R6.2 — CI workload identity

**Implementation tickets**

- `IDL-CI-001` — Add OIDC workload identity for GitHub, GitLab, and Jenkins.

**Acceptance criteria**

- CI jobs obtain short-lived project-scoped tokens without static API keys.
- Subject and audience policies are enforced.
- Token exchange is audited.

### Epic R6.3 — Webhooks and integrations framework

**Implementation tickets**

- `IDL-INT-001` — Add signed, versioned webhooks, retry/dead-letter delivery,
  and Jira/Slack/Teams adapters.

## R7 — Scale and governance

### Epic R7.1 — High-availability reference architecture

**Implementation tickets**

- `IDL-DEP-001` — Publish HA topology with external database, object storage,
  shared queue/cache, runner autoscaling, ingress/TLS, backup/DR, capacity, and
  failure tests.

### Epic R7.2 — Compatibility matrix and release train

**Implementation tickets**

- `IDL-GOV-001` — Add Web/API/CLI/Docker compatibility matrix, SemVer policy,
  automated changelog, deprecation windows, release-candidate gates, SBOM, and
  provenance.

## Enterprise-ready definition of done

Idelium can be described as enterprise-ready only when these gates are satisfied.

### Security gate

- No production TLS bypass remains.
- Agents use mTLS or workload identity.
- API credentials are hashed, scoped, revocable, expiring, and one-time reveal.
- Secret provider and redaction are integrated.
- Plugins are approved and sandboxed.
- Authorization is capability-based and deny-by-default.
- Privileged access supports SSO/MFA or a hardened break-glass process.
- Audit trail is append-only.
- Dependency, container, and secret scans run in CI.
- High/Critical security findings are remediated.

### Tenant isolation gate

- User identity is separate from tenant context.
- Cross-tenant tests cover every resource family.
- Artifact, report, platform, and secret access are tenant-scoped.
- Impersonation is temporary, reasoned, visible, and audited.
- Data retention is tenant-aware.

### Reliability gate

- Runs are idempotent.
- Workers use heartbeat and lease.
- Cancellation has acknowledgement semantics.
- Lost workers are recovered deterministically.
- Retry policy is classified.
- Scheduler concurrency and load tests pass.
- Backup, restore, upgrade, and rollback are verified.

### Product governance gate

- Test assets are immutable and versioned.
- Review and approval workflows are available.
- API v1 is documented.
- Capability and compatibility matrices are published.
- Changelog and deprecation policies are active.
- Ownership and audit are available for all critical assets.

### UX and accessibility gate

- Terminology is normalized.
- Design system covers critical flows.
- Data grids support large datasets.
- Filters and deep links are stable.
- Error handling is consistent.
- Main journeys meet WCAG 2.2 AA.
- Secrets are never shown by default.
- Async operations provide durable feedback.

### Reporting gate

- Server-side reports exist in declared formats.
- Artifact storage and retention are authoritative.
- Checksums are verified.
- Download authorization is enforced.
- JUnit works with at least two CI systems.
- Execution details are sufficient for failure diagnosis.
- Correlation IDs connect Web, API, CLI, runner, and artifacts.

## Suggested KPI set

| Area | KPI |
| --- | --- |
| Adoption | Active projects, active users, active service accounts, tests launched per week. |
| Authoring | New reusable steps, reuse ratio, import-to-approved conversion rate. |
| Quality | Pass rate, flaky rate, escaped defect correlation, broken asset count. |
| Execution | Queue time, run duration, worker utilization, cancellation latency, lost-worker rate. |
| Security | Secret leakage findings, unauthorized access attempts, key rotation age, plugin approval SLA. |
| Operations | Backup success, restore test age, upgrade success, SLO compliance, incident count. |

## Recommended next planning step

Start with R0.1, R0.2, and R0.3 as the first execution tranche because they
reduce the highest enterprise risk: remote runner trust, tenant isolation, and
machine credential lifecycle. R0.4 and R0.5 should follow immediately because
plugin execution and environment secrets are high-impact blast-radius controls.
