# Cross-repository CI contract gates

Idelium delivery pipelines depend on four repositories staying compatible at
their published boundaries:

- `idelium-docker` owns Compose topology, health readiness, CI examples, and
  artifact collection.
- `idelium-api` owns authentication, tenant-scoped execution APIs, parallel-run
  scheduling, worker updates, cancellation, and result aggregation.
- `idelium-web` owns project-aware UX controls for execution monitoring and
  report downloads.
- `idelium-cli` owns non-interactive execution, environment resolution, exit-code
  propagation, and JSON, HTML, Markdown, and JUnit report generation.

The `scripts/cross-repository-contract-gate.sh` script is a non-mutating
regression gate. It checks pinned component revisions when expected refs are
provided, then verifies that representative authentication, configuration,
execution, result, and report contracts are still present in each sibling
repository.

## Usage

Run from `idelium-docker` with sibling repositories checked out next to it:

```bash
IDELIUM_DOCKER_REF="$(git rev-parse HEAD)" \
IDELIUM_API_REF="$(git -C ../idelium-api rev-parse HEAD)" \
IDELIUM_WEB_REF="$(git -C ../idelium-web rev-parse HEAD)" \
IDELIUM_CLI_REF="$(git -C ../idelium-cli rev-parse HEAD)" \
./scripts/cross-repository-contract-gate.sh
```

The ref variables are optional for local development. When set, each must be a
full 40-character commit SHA and must match the checked-out repository.

## Failure behavior

Failures name the incompatible contract and repository path only. The gate does
not read, print, or require tenant data, API keys, application secrets, report
payloads, or runtime credentials.
