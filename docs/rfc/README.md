# Idelium RFC Process

The Idelium RFC process records major product, architecture, security,
compatibility, persistence, deployment, and automation decisions before they are
implemented across the Idelium repositories.

## When an RFC is required

Create an RFC before starting work that changes any of the following areas:

- public API contracts consumed by Idelium Web, Idelium CLI, or third-party
  integrations;
- CLI flags, exit-code semantics, package metadata, or execution-result
  contracts;
- database schema, tenant-isolation rules, migrations, retention, or rollback
  behavior;
- authentication, authorization, secrets handling, plugin approval, sandboxing,
  or audit logging;
- Docker topology, production deployment, backup, restore, upgrade, or
  high-availability behavior;
- DSL syntax, Postman/Appium/Selenium compatibility, or runtime dispatch
  semantics;
- deprecation, migration, release-train, or support-window policy.

Small bug fixes, documentation-only clarifications, and implementation details
that do not change a contract may skip the RFC process. When uncertain, open a
short draft RFC and mark the decision as pending.

## Lifecycle states

| State | Meaning |
| --- | --- |
| Draft | The problem and options are still being shaped. |
| Review | Security, migration, compatibility, and affected repository owners are reviewing the proposal. |
| Accepted | The decision is approved and can be implemented. |
| Superseded | A newer RFC replaces this decision. |
| Rejected | The decision is intentionally not being implemented. |

Accepted, superseded, and rejected RFCs must remain discoverable in
[`decisions/`](decisions/README.md).

## Decision ownership

Every RFC has a single decision owner and one reviewer for each affected
repository:

- `idelium-api` for API contracts, persistence, authorization, and migrations;
- `idelium-web` for UX, accessibility, localization, and browser contracts;
- `idelium-cli` for CLI behavior, runtime compatibility, and local execution;
- `idelium-docker` for deployment topology, operations, release, and rollback.

Security-sensitive RFCs require an explicit security reviewer before acceptance.
Tenant isolation, redaction, credential handling, and capability boundaries must
be reviewed even when the change appears UI-only.

## Required review sections

Every RFC must include:

- problem statement and goals;
- non-goals;
- affected repositories and owners;
- compatibility and migration plan;
- security and tenant-isolation impact;
- deployment and rollback plan;
- observability and operational ownership;
- test and verification plan;
- rejected alternatives.

Use [`template.md`](template.md) for new RFCs.

## Numbering and storage

Use monotonically increasing RFC identifiers:

```text
RFC-0001-short-title.md
RFC-0002-short-title.md
```

Drafts can live in `docs/rfc/drafts/`. Accepted, superseded, and rejected
decisions move to `docs/rfc/decisions/` and keep their identifier permanently.

## Verification

RFC verification is intentionally non-mutating:

- check that mandatory sections are present;
- check that public Idelium references use `idelium.org`;
- check that security and migration sections are not left blank;
- link implementation issues or pull requests from the RFC before closing the
  related roadmap ticket.

Executable verification should run in CI without rewriting files.
