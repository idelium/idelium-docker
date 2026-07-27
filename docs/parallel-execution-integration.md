# Deterministic parallel execution integration test

`scripts/parallel-execution-integration-test.sh` validates stack-level parallel
execution without changing the default sequential runtime behavior.

The test starts the pinned Idelium stack, Selenium Grid, and CLI runner profile,
waits for every service healthcheck, runs the configured cycle or cycles
sequentially, runs the same cycle set through concurrent CLI runner containers,
and compares normalized JSON report outcomes.

## Required inputs

Provide these values through CI protected variables or a local secret manager:

| Variable | Purpose |
| --- | --- |
| `IDELIUM_PROJECT_ID` | Project containing the test cycle. |
| `IDELIUM_CYCLE_ID` or `IDELIUM_CYCLE_IDS` | One cycle id or comma-separated cycle ids to execute. |
| `IDELIUM_ENVIRONMENT` | Environment configured for the project. |
| `IDELIUM_API_KEY_FILE` | Path to a protected file containing the Idelium API key. |

Optional variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `IDELIUM_PARALLEL_WORKERS` | `2` | Maximum number of concurrent CLI runner containers. |
| `IDELIUM_PARALLEL_REPORT_DIR` | `reports/parallel-integration` | Host report directory. |
| `IDELIUM_PARALLEL_PROJECT` | `idelium-parallel-it` | Docker Compose project name. |
| `IDELIUM_BASE_URL` | `https://ideliumfe` | URL used by CLI runners inside the Compose network. |

## Guarantees

- Sequential execution remains the baseline and runs first.
- Parallel execution uses isolated runner containers and separate report
  directories per cycle.
- Service readiness is based on Docker healthchecks, not container creation.
- Reports are compared after removing generated timestamps and artifact paths.
- API keys are mounted read-only from a protected file and are not printed.
- Cleanup removes temporary report files while preserving the generated reports
  for CI artifact upload.

## Example

```bash
IDELIUM_PROJECT_ID=3 \
IDELIUM_CYCLE_IDS=21,22 \
IDELIUM_ENVIRONMENT=ci \
IDELIUM_API_KEY_FILE="$PWD/.secrets/idelium-api-key" \
IDELIUM_PARALLEL_WORKERS=2 \
scripts/parallel-execution-integration-test.sh
```

If sequential and parallel normalized outcomes differ, the script exits with a
non-zero status and leaves both report sets under
`reports/parallel-integration/` for diagnosis.
