# Idelium Contribution and Code Review Policy

This policy defines the minimum contribution, review, testing, security,
documentation, and definition-of-done expectations for all Idelium repositories:

- `idelium-api`
- `idelium-web`
- `idelium-cli`
- `idelium-docker`

Repository-specific `AGENTS.md` directives remain authoritative for local
implementation details. This policy provides the shared baseline that reviewers
use when work crosses repository boundaries.

## Contribution expectations

Every contribution must:

- keep documentation, comments, diagnostics, and technical user-facing messages
  in English;
- be small enough to review without mixing unrelated refactors, feature work, and
  generated artifacts;
- preserve customer isolation, credentials, authorization boundaries, and
  redaction guarantees;
- include tests for behavior changes and regression tests for bug fixes;
- document compatibility, migration, deployment, and rollback implications when
  behavior, data, API, CLI, or deployment contracts change;
- avoid committing secrets, debug payloads, real customer data, session values,
  access tokens, passwords, private keys, or authorization headers.

## Setup and submission requirements

New contributors should start by reading:

- the workspace-level `AGENTS.md`;
- the target repository `AGENTS.md`;
- relevant files under `docs/`;
- open roadmap or implementation issues linked to the change.

Before submitting a change, contributors must:

1. identify the affected repositories and contracts;
2. describe the user-visible or operational behavior being changed;
3. run the repository-required checks;
4. include test evidence in the issue, pull request, or commit handoff;
5. call out any check that could not be run and why.

## Required checks by repository

Use the stricter repository-specific `AGENTS.md` when it adds requirements.

| Repository | Required checks |
| --- | --- |
| `idelium-api` | PHPUnit suite, tenant-isolation tests, authorization tests, migration checks, response-field review. |
| `idelium-web` | Unit/component tests, lint check, format check, production build, login/authenticated-route smoke test when UI routing changes. |
| `idelium-cli` | Unit tests without network access, compile/import check, CLI help check, representative command invocation when CLI behavior changes. |
| `idelium-docker` | Compose validation, healthcheck review, stack smoke test for deployment changes, secret scan of changed files, execution-profile smoke tests when runner/Grid/Appium topology changes. |

Documentation-only changes still require a non-mutating review appropriate to
the files touched, such as checking links, required sections, public domains,
and absence of secrets.

## Reviewer responsibilities

Reviewers must verify that:

- the change is scoped to the issue or pull request;
- security, tenant isolation, and credential handling were considered;
- API, CLI, database, Docker, and persisted-data compatibility is preserved or a
  migration/deprecation plan exists;
- tests cover the behavior and negative-security cases where relevant;
- user-facing text is localized when the target repository supports
  localization;
- public Idelium references use `idelium.org`;
- generated artifacts, local caches, and temporary files are not accidentally
  included.

Cross-repository work requires at least one reviewer from each affected
repository area. Security-sensitive work requires an explicit security review.

## Definition of done

A change is done only when:

- acceptance criteria are met;
- relevant tests and checks pass;
- security and tenant-isolation implications are reviewed;
- documentation is updated in English when behavior or configuration changes;
- compatibility, migration, deployment, and rollback implications are documented
  when relevant;
- no secret, debug output, or temporary file was introduced;
- affected issues are updated with commit references, verification evidence, and
  any remaining cross-repository dependency.

## Escalation to RFC

Use the [Idelium RFC process](../rfc/README.md) when a contribution changes a
major contract, security boundary, deployment topology, data model, DSL syntax,
runtime compatibility promise, or release governance rule.

## Non-mutating verification

Policy verification should be reproducible and non-mutating. Examples:

- search changed documentation for forbidden public domains;
- check mandatory sections in governance templates;
- run repository check commands in report-only mode;
- inspect staged files before committing to avoid unrelated or generated files.
