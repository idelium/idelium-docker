# Backup, restore, upgrade, and rollback test plan

This plan defines the deterministic recovery gates required before promoting an
Idelium Docker/API release to production.

It complements:

- [Release and rollback runbook](release-and-rollback-runbook.md)
- [Coordinated release train](coordinated-release-train.md)
- [High-availability reference architecture](../architecture/high-availability-reference-architecture.md)

## Scope

The recovery gate covers:

- database backups;
- execution artifact backups and retention;
- backup encryption and integrity checks;
- restore verification in an isolated environment;
- API migration preflight;
- supported upgrade paths;
- rollback limits and forward-fix plans;
- startup readiness when migration, seed, restore, or initialization fails.

## Recovery objectives

Each production release record must publish:

| Objective | Baseline | Evidence |
| --- | --- | --- |
| Database RPO | 15 minutes or better | Backup schedule and latest successful backup timestamp. |
| Artifact RPO | 15 minutes or better for artifact descriptors and retained objects | Object storage replication or backup evidence. |
| Control-plane RTO | 60 minutes or better | Latest restore drill duration. |
| Artifact restore RTO | 120 minutes or better for retained artifacts | Latest artifact restore drill duration. |
| Upgrade validation | Previous compatible train to current train | Upgrade test report. |
| Rollback validation | Current train to previous compatible train or documented forward-fix | Rollback drill or approved rollback-limit note. |

Teams may set stricter values per environment. Weaker values require explicit
release approval and a follow-up issue.

## Backup requirements

Database and artifact backups must be:

- encrypted before leaving the service boundary or encrypted by the managed
  service with customer-approved keys;
- integrity-checked with checksums or provider restore validation;
- retention-aware with documented expiration and legal hold behavior;
- stored outside the application runtime account or Compose host;
- associated with the release train and source commits that produced the data
  shape;
- excluded from application logs, screenshots, and public CI artifacts.

Backups must never contain plaintext passwords, API keys, access tokens, session
identifiers, or authorization headers in diagnostic output.

## Restore verification

Restore verification must run on a schedule and before production promotion when
the release changes schema, artifact descriptors, storage policy, or startup
initialization.

The restore job must:

1. create or select a recent backup set;
2. restore the database into an isolated environment;
3. restore artifact descriptors and at least one representative retained
   artifact;
4. run API migration status checks without mutating production;
5. start Web/API against the restored data;
6. run tenant-scoped smoke checks;
7. verify artifact checksums and authorization;
8. produce a redacted evidence report with timestamps, source release, target
   release, RPO, RTO, and result.

## Migration preflight

Migration preflight must run before destructive or incompatible changes. It must
fail before applying migrations when:

- the source version is outside the supported compatibility window;
- required columns, indexes, or tables are missing;
- duplicate or invalid tenant ownership would break isolation;
- artifact descriptors reference missing retained objects;
- the release note does not describe rollback or forward-fix behavior;
- required backup evidence is missing or older than the allowed RPO.

Preflight must be read-only against production data.

## Upgrade path

Each coordinated release must test at least one supported upgrade path:

1. start the previous compatible train;
2. create representative tenants, projects, environments, steps, cycles,
   executions, reports, and artifacts;
3. take database and artifact backups;
4. upgrade to the candidate train;
5. run migrations and initialization;
6. verify health checks do not pass before initialization is complete;
7. execute conformance smoke checks;
8. verify reports and artifacts remain readable only by authorized tenants.

## Rollback path

Rollback documentation must state whether rollback is:

- fully reversible with down migrations and prior artifacts;
- database-restore based;
- forward-fix only.

Rollback evidence must include:

- previous compatible release train;
- backup set identifier;
- database restore or down-migration result;
- artifact restore result;
- health check and smoke-test output after rollback;
- customer-impact statement;
- security confirmation that recovery artifacts did not expose secrets or
  customer payloads.

Never run an undocumented destructive database operation during rollback.

## Startup failure gates

The stack must not report ready when:

- database migrations fail;
- base seeders fail;
- explicitly enabled demo seeders fail;
- required secret files are missing;
- restore validation fails;
- API cannot inspect migration status;
- frontend cannot reach the API health boundary.

Startup checks must depend on service health and one-shot initialization success,
not container creation alone.

## Scheduled evidence record

Every scheduled recovery job should record:

| Field | Requirement |
| --- | --- |
| `schemaVersion` | `idelium-recovery-evidence.v1` |
| `sourceTrain` | Previous or current release train under test. |
| `targetTrain` | Candidate or restored train. |
| `backupSet` | Redacted backup identifier. |
| `databaseRpoSeconds` | Numeric RPO measurement. |
| `databaseRtoSeconds` | Numeric RTO measurement. |
| `artifactRpoSeconds` | Numeric artifact RPO measurement. |
| `artifactRtoSeconds` | Numeric artifact RTO measurement. |
| `integrityChecked` | Boolean. |
| `tenantSmokePassed` | Boolean. |
| `artifactSmokePassed` | Boolean. |
| `secretsRedacted` | Boolean. |
| `result` | `passed`, `failed`, or `blocked`. |

## Non-mutating check

Run:

```bash
./scripts/recovery-gate-check.sh
```

The check verifies that the recovery plan, release runbook, HA reference
architecture, and Compose startup model retain the required backup, restore,
upgrade, rollback, RPO/RTO, migration preflight, and readiness-gate language.
