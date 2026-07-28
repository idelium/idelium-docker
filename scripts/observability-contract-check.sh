#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/observability-stack.md"
COMPOSE="$ROOT_DIR/compose.observability.yml"
OTEL="$ROOT_DIR/observability/otel-collector.yml"
PROMETHEUS="$ROOT_DIR/observability/prometheus.yml"
GRAFANA_DS="$ROOT_DIR/observability/grafana/provisioning/datasources/datasources.yml"

fail() {
  echo "Observability contract check failed: $*" >&2
  exit 1
}

require_file() {
  local label="$1"
  local path="$2"

  test -f "$path" || fail "$label missing at $path"
}

require_pattern() {
  local label="$1"
  local path="$2"
  local pattern="$3"

  require_file "$label" "$path"
  grep -Eq "$pattern" "$path" || fail "$label missing required pattern in $path"
}

for section in \
  "Objectives" \
  "Correlation contract" \
  "Structured logging contract" \
  "Metrics and traces" \
  "Dashboards and alerts" \
  "Optional deployment profile" \
  "Sizing guidance" \
  "Verification"; do
  require_pattern "$section section" "$DOC" "^## $section$"
done

for term in \
  "X-Idelium-Correlation-Id" \
  "authorization headers" \
  "RED metrics" \
  "USE metrics" \
  "owner" \
  "severity" \
  "runbook link" \
  "IDELIUM_OTEL_COLLECTOR_IMAGE" \
  "IDELIUM_PROMETHEUS_IMAGE" \
  "IDELIUM_GRAFANA_IMAGE" \
  "IDELIUM_GRAFANA_ADMIN_PASSWORD_FILE"; do
  require_pattern "$term requirement" "$DOC" "$term"
done

require_pattern "observability profile" "$COMPOSE" "profiles:"
require_pattern "collector pinned image variable" "$COMPOSE" 'IDELIUM_OTEL_COLLECTOR_IMAGE:\?'
require_pattern "prometheus pinned image variable" "$COMPOSE" 'IDELIUM_PROMETHEUS_IMAGE:\?'
require_pattern "grafana pinned image variable" "$COMPOSE" 'IDELIUM_GRAFANA_IMAGE:\?'
require_pattern "grafana secret file" "$COMPOSE" 'GF_SECURITY_ADMIN_PASSWORD__FILE'
require_pattern "service health checks" "$COMPOSE" "healthcheck:"
require_pattern "least privilege" "$COMPOSE" "no-new-privileges:true"
require_pattern "otel redaction processor" "$OTEL" "attributes/redaction"
require_pattern "otel health check" "$OTEL" "health_check"
require_pattern "prometheus scrape config" "$PROMETHEUS" "scrape_configs:"
require_pattern "grafana datasource" "$GRAFANA_DS" "Prometheus"

if rg -n 'idelium\.io|:latest|password[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|token[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|authorization[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]' "$DOC" "$COMPOSE" "$OTEL" "$PROMETHEUS" "$GRAFANA_DS"; then
  fail "observability files contain forbidden domain, mutable image tag, or literal credential pattern"
fi

echo "Observability contract check passed."
