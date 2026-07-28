#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAN="$ROOT_DIR/docs/release/backup-restore-upgrade-test-plan.md"
RUNBOOK="$ROOT_DIR/docs/release/release-and-rollback-runbook.md"
HA_DOC="$ROOT_DIR/docs/architecture/high-availability-reference-architecture.md"
COMPOSE="$ROOT_DIR/docker-compose.yml"
INIT_SCRIPT="$ROOT_DIR/ideliumapi/script/initialize.sh"
START_SCRIPT="$ROOT_DIR/start-idelium.sh"

fail() {
  echo "Recovery gate check failed: $*" >&2
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

require_file "recovery test plan" "$PLAN"

for section in \
  "Scope" \
  "Recovery objectives" \
  "Backup requirements" \
  "Restore verification" \
  "Migration preflight" \
  "Upgrade path" \
  "Rollback path" \
  "Startup failure gates" \
  "Scheduled evidence record" \
  "Non-mutating check"; do
  require_pattern "$section section" "$PLAN" "^## $section$"
done

for term in \
  "Database RPO" \
  "Artifact RPO" \
  "Control-plane RTO" \
  "integrity-checked" \
  "tenant-scoped smoke checks" \
  "read-only against production data" \
  "health checks do not pass before initialization is complete" \
  "forward-fix only" \
  "idelium-recovery-evidence.v1"; do
  require_pattern "$term requirement" "$PLAN" "$term"
done

require_pattern "runbook backup ownership" "$RUNBOOK" "backup"
require_pattern "runbook rollback health checks" "$RUNBOOK" "Re-run health checks and smoke tests"
require_pattern "HA architecture RPO" "$HA_DOC" "RPO"
require_pattern "HA architecture RTO" "$HA_DOC" "RTO"
require_pattern "Compose initialization dependency" "$COMPOSE" "condition: service_completed_successfully"
require_pattern "Compose health dependency" "$COMPOSE" "condition: service_healthy"
require_pattern "API migration initialization" "$INIT_SCRIPT" "php artisan migrate --force --no-interaction"
require_pattern "startup health wait" "$START_SCRIPT" "waiting for health checks"

if rg -n 'idelium\.io|:latest|password[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|token[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|authorization[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]' "$PLAN"; then
  fail "recovery plan contains forbidden domain, mutable image tag, or literal credential pattern"
fi

echo "Recovery gate check passed."
