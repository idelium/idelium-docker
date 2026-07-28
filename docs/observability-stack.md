# Observability stack

This document defines the optional Idelium observability profile for production
and staging environments.

The profile is intentionally separate from the demo stack. Demo users can run
Idelium without observability services; enterprise deployments should enable an
observability backend that captures correlation IDs, structured redacted logs,
metrics, traces, dashboards, and actionable alerts.

## Objectives

- Connect Web requests, API operations, execution launches, runner activity,
  results, and artifact descriptors with one correlation ID.
- Keep logs structured, bounded, tenant-aware, and redacted.
- Cover RED metrics for request/launch paths and USE metrics for infrastructure
  resources.
- Trace launch, queue, execution, storage, database, and worker boundaries.
- Provide dashboards and alerts with ownership, severity, and runbook links.
- Keep the deployment profile optional, pinned, health-checked, and free of
  embedded credentials.

## Correlation contract

Every component must accept or create a correlation identifier named
`X-Idelium-Correlation-Id`.

| Component | Responsibility |
| --- | --- |
| Web | Create the ID for user-initiated browser actions when absent and forward it to the API. |
| API | Validate or create the ID, include it in structured logs, queue payloads, result descriptors, and response headers. |
| CLI | Create the ID for local launches, forward it to API calls, and include it in local reports. |
| Runner | Preserve the ID across execution steps, worker logs, result submissions, and artifact descriptors. |
| Artifacts | Store the ID in descriptors, not in unstructured filenames that may leak customer data. |

Correlation IDs must not encode tenant names, customer names, email addresses,
API keys, session identifiers, or project secrets.

## Structured logging contract

Logs must be JSON or another parseable structured format with these fields:

| Field | Requirement |
| --- | --- |
| `timestamp` | ISO-8601 UTC timestamp. |
| `level` | Controlled severity such as `debug`, `info`, `warning`, `error`, or `critical`. |
| `service` | `web`, `api`, `cli`, `runner`, `worker`, or infrastructure service name. |
| `correlationId` | Current correlation ID. |
| `tenantId` | Redacted or opaque tenant identifier when available. |
| `projectId` | Project identifier when authorized and relevant. |
| `event` | Stable event name. |
| `durationMs` | Numeric duration for timed operations. |
| `result` | `success`, `failure`, `blocked`, or `degraded`. |
| `errorCode` | Stable error code for failures. |

Logs must redact passwords, API keys, bearer tokens, session identifiers,
authorization headers, cookies, secret file contents, and customer payloads.

## Metrics and traces

Required metric families:

| Area | Required signals |
| --- | --- |
| Web/API requests | Rate, errors, duration, saturation, status class, route family. |
| Launch control plane | Launch count, rejected launches, queue submit latency, timeout count. |
| Queue and workers | Queue depth, oldest queued job age, worker concurrency, retry count, dead-letter count. |
| Execution | Step duration, pass/fail/blocked count, dependency failure count, interruption count. |
| Storage and artifacts | Descriptor write count, object write/read errors, checksum failures, retention deletes. |
| Database | Connection saturation, migration state, query latency, lock wait, backup freshness. |
| Security | Authorization denials, cross-tenant denial count, redaction failure count. |

Traces must cross Web, API, queue, runner, external test dependency, result
submission, and artifact descriptor boundaries where instrumentation is
available. Trace attributes must use opaque tenant/project IDs and avoid payload
or credential values.

## Dashboards and alerts

Dashboards must show:

- control-plane availability and latency;
- launch and queue health;
- runner pool health by capability;
- Selenium, Appium, and Postman/Newman dependency health;
- database, cache, queue, and object storage health;
- report/artifact write and read failures;
- backup freshness, restore drill age, RPO, and RTO;
- security denials and redaction failures.

Each actionable alert must include:

- owner;
- severity;
- impact statement;
- threshold;
- correlation or trace lookup hint;
- runbook link;
- rollback or mitigation hint when relevant.

## Optional deployment profile

The optional profile is defined in [`compose.observability.yml`](../compose.observability.yml).

It provides example services for:

- OpenTelemetry Collector;
- Prometheus;
- Grafana.

All image references are required environment variables so production operators
can pin exact tags or digests in their environment-specific release record:

| Variable | Purpose |
| --- | --- |
| `IDELIUM_OTEL_COLLECTOR_IMAGE` | Pinned OpenTelemetry Collector image reference. |
| `IDELIUM_PROMETHEUS_IMAGE` | Pinned Prometheus image reference. |
| `IDELIUM_GRAFANA_IMAGE` | Pinned Grafana image reference. |
| `IDELIUM_GRAFANA_ADMIN_PASSWORD_FILE` | Secret file containing the Grafana admin password. |

The example does not enable public unauthenticated dashboards and does not
contain real credentials. Production deployments should place Grafana behind the
same enterprise ingress, identity provider, and network policy used for
operations tooling.

## Sizing guidance

Initial sizing must record:

- log events per second;
- metrics samples per second;
- trace spans per execution;
- artifact descriptor write rate;
- dashboard retention target;
- alert evaluation interval;
- storage retention and downsampling policy;
- expected peak concurrent workers.

Cost-sensitive dimensions are log retention, trace sampling rate, metric
cardinality, dashboard retention, and object-storage lifecycle policy.

## Verification

Run:

```bash
./scripts/observability-contract-check.sh
```

The check verifies that the observability document and optional Compose profile
retain correlation, redaction, metrics, traces, dashboards, alerts, pinned image
variables, health checks, and secret-file requirements.
