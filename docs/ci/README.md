# Idelium CI integration examples

This directory contains reproducible CI examples for running Idelium in delivery
pipelines while preserving the security and compatibility rules used by the
Docker stack.

## Examples

- [`github-actions-idelium.yml`](github-actions-idelium.yml) provides a pinned
  GitHub Actions workflow that checks out fixed component revisions, validates
  the stack, starts Idelium, runs an Idelium cycle through the CLI runner, and
  uploads JSON, HTML, Markdown, and JUnit reports.
- [`gitlab-ci-idelium.yml`](gitlab-ci-idelium.yml) provides the equivalent
  GitLab CI jobs with pinned Docker images, protected variables, JUnit report
  collection, and cleanup in `after_script`.

## Required protected variables

Configure these values as protected CI variables or workflow inputs. Never
commit real values to this repository or to an application repository.

| Variable | Purpose |
| --- | --- |
| `IDELIUM_DOCKER_REF` / `idelium_docker_ref` | Full commit SHA for `idelium-docker`. |
| `IDELIUM_API_REF` / `idelium_api_ref` | Full commit SHA for `idelium-api`. |
| `IDELIUM_WEB_REF` / `idelium_web_ref` | Full commit SHA for `idelium-web`. |
| `IDELIUM_CLI_REF` / `idelium_cli_ref` | Full commit SHA for `idelium-cli`. |
| `IDELIUM_API_KEY` | Idelium API key materialized as a protected file inside the runner. |
| `IDELIUM_PROJECT_ID` / `idelium_project_id` | Project identifier to execute. |
| `IDELIUM_CYCLE_ID` / `idelium_cycle_id` | Cycle identifier to execute. |
| `IDELIUM_ENVIRONMENT` / `idelium_environment` | Environment name configured in Idelium. |
| `IDELIUM_BASE_URL` / `idelium_base_url` | HTTPS origin trusted by the CLI runner. |

Every component reference must be a 40-character commit SHA. This prevents the
pipeline from silently changing behavior because a branch or tag moved.

## Runtime behavior

Both examples:

1. validate that component revisions are immutable commit SHAs;
2. build the Docker stack from sibling checkouts;
3. start the demo stack and wait for health through `start-idelium.sh --demo`;
4. run `idelium-cli-runner` against the configured HTTPS Idelium origin with a
   read-only key file mounted at
   `/home/idelium/.idelium`;
5. write reports under `reports/`;
6. collect reports even if the test cycle fails;
7. stop containers and remove volumes in the cleanup step.

The examples intentionally do not print secrets, pass API keys on the command
line, use `latest` images, or disable TLS verification.

## Regression checks

Run these non-mutating contract checks after changing the examples:

```bash
./scripts/validate-github-actions-example.sh
./scripts/validate-gitlab-ci-example.sh
./scripts/cross-repository-contract-gate.sh
./scripts/supply-chain-provenance-gate.sh
```

The checks fail when action/image references drift to moving major tags, required
report outputs disappear, health readiness is no longer exercised, or obvious
embedded credentials are introduced. The cross-repository gate additionally
checks that the local CLI, API, Web, and Docker checkouts still expose the
published authentication, configuration, execution, result, and report
boundaries. The supply-chain gate verifies Apache-2.0 licensing, package
metadata, lockfiles, release artifact traceability, and provenance policy links
across the four local repositories without mutating files or requiring
credentials.

## Adapting the examples

Use the examples as templates. Keep these contracts intact when adapting them:

- use immutable component revisions;
- keep API keys in protected CI secret storage;
- preserve CLI exit codes so failed cycles fail the pipeline;
- always publish standard reports as artifacts;
- keep cleanup under `if: always()` or `after_script`;
- review dependency and action version changes deliberately.
