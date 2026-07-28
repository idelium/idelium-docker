# Idelium Release and Rollback Runbook

This runbook defines the repeatable release flow for coordinated Idelium
component releases and emergency rollback. It is intentionally repository
neutral; each component may add stricter local steps in its own release notes.

## Scope

The runbook covers:

- `idelium-api`
- `idelium-web`
- `idelium-cli`
- `idelium-docker`

Use the RFC process for release changes that alter compatibility windows,
deployment topology, persistence contracts, or security boundaries.

## Roles and responsibilities

| Role | Responsibility |
| --- | --- |
| Release owner | Coordinates scope, release notes, tags, deployment order, and rollback decision. |
| Component owner | Verifies build, tests, packaging, and component-specific release notes. |
| Operations owner | Verifies Docker topology, secrets, backup, deployment, health checks, and recovery. |
| Security reviewer | Reviews credential handling, tenant isolation, redaction, and dependency provenance. |

Emergency rollback requires the release owner and operations owner. If security
or tenant isolation is affected, the security reviewer must be notified before
traffic is restored.

## Clean checkout and pinned inputs

Start from a clean checkout for every repository:

```bash
git status --short
git fetch --tags --prune
```

The status output must be empty before building release artifacts. Build inputs
must be pinned:

- Git commits or signed tags for application source;
- lockfiles for package managers;
- versioned Docker base images or digests;
- versioned Python, Node.js, PHP, and database runtime images;
- explicit Compose files instead of implicit local overrides.

Do not build a release from a dirty tree, moving branch reference, or unpinned
`latest` image.

## Pre-release checks

Before tagging or publishing:

1. Confirm the release scope and linked issues.
2. Confirm API, CLI, Web, Docker, and database compatibility notes.
3. Confirm migration and rollback notes for every persisted-data change.
4. Run component verification:
   - API tests, tenant-isolation tests, migration checks;
   - Web unit/component tests, lint, format check, production build;
   - CLI unit tests, compile/import check, help check, representative command;
   - Docker Compose validation, healthcheck review, and stack smoke test when
     deployment files change.
5. Review changed files for secrets and public domain references.
6. Confirm release notes describe new behavior, migration, rollback, and known
   compatibility constraints.

## Artifact verification

Every release artifact must be traceable to a commit or tag:

- Docker image tags include the component version or source commit;
- Python distributions are built from a clean tree and checked before publish;
- frontend assets are generated from the locked dependency graph;
- Compose examples reference explicit image tags or build contexts.

Record artifact names, versions, checksums when available, and source commits in
the release notes.

## Deployment order

Use the least risky compatible order:

1. Back up the database and configuration.
2. Deploy backward-compatible API/database changes.
3. Deploy Web assets that can talk to both old and new API behavior.
4. Deploy CLI release after server contracts are available.
5. Deploy Docker topology or operational changes after component health is
   verified.
6. Run smoke tests through the public frontend and representative API/CLI paths.

If a migration is not backward compatible, document the required maintenance
window, customer impact, rollback limits, and data recovery approach before
deployment.

## Secret handling

Secrets must come from environment-specific secret management. Do not place real
passwords, tokens, keys, private certificates, provider credentials, or session
values in release notes, logs, Compose files, screenshots, or support bundles.

During emergency work:

- rotate exposed credentials before restoring traffic;
- redact support logs before sharing them;
- document who handled the secret and where it was rotated;
- avoid copying production data into local developer environments.

## Rollback procedure

Use rollback when health checks, smoke tests, security review, or customer impact
show that the release cannot safely continue.

1. Stop new deployment steps.
2. Preserve logs, metrics, failed health checks, and release artifact metadata.
3. Restore the previous known-good image tags or package versions.
4. Revert Web assets and CLI distribution links if they depend on the failed
   server contract.
5. If database migration rollback is safe, run the documented down migration.
6. If rollback is not safe, activate the documented recovery plan and keep the
   forward-fix path explicit.
7. Re-run health checks and smoke tests.
8. Publish an incident note with impact, root cause, restored version, and
   follow-up issues.

Never run an undocumented destructive database operation during rollback.

## Recovery validation

After rollback or recovery:

- confirm login and authenticated navigation;
- confirm API health and tenant-scoped access checks;
- confirm CLI can fetch configuration and report a minimal execution result;
- confirm Docker service health checks are green;
- confirm no secrets or customer data were exposed in recovery artifacts.

## Non-mutating verification

Runbook verification can be performed without changing deployment state by:

- checking that mandatory sections exist;
- checking for forbidden public domains and obvious secret patterns;
- validating Compose configuration syntax;
- confirming referenced scripts and docs exist;
- reviewing changed release files against the contribution and RFC policies.
