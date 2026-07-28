#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/architecture/high-availability-reference-architecture.md"

fail() {
  echo "HA reference architecture check failed: $*" >&2
  exit 1
}

require_pattern() {
  local label="$1"
  local pattern="$2"

  grep -Eq "$pattern" "$DOC" || fail "$label missing from $DOC"
}

test -f "$DOC" || fail "document missing at $DOC"

require_pattern "architecture goals" "^## Architecture goals$"
require_pattern "logical topology" "^## Logical topology$"
require_pattern "trust boundaries" "^## Trust boundaries$"
require_pattern "data flows" "^## Data flows$"
require_pattern "failure domains" "^## Failure domains$"
require_pattern "scaling units" "^## Scaling units$"
require_pattern "managed services" "^## Required managed services$"
require_pattern "capacity and SLO assumptions" "^## Capacity and SLO assumptions$"
require_pattern "production deployment example requirements" "^## Production deployment example requirements$"
require_pattern "demo and production separation" "^## Demo and production profile separation$"
require_pattern "failure testing checklist" "^## Failure testing checklist$"
require_pattern "compatibility and release evidence" "^## Compatibility and release evidence$"
require_pattern "RPO target" "RPO"
require_pattern "RTO target" "RTO"
require_pattern "object storage" "Object storage"
require_pattern "runner autoscaling" "Runner workers"
require_pattern "secret manager" "Secrets manager"

if rg -n 'idelium\.io|:latest|password[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|token[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]' "$DOC"; then
  fail "document contains forbidden domain, mutable image tag, or literal credential pattern"
fi

echo "HA reference architecture check passed."
