#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOC="$ROOT_DIR/docs/ci/conformance-suite.md"
FIXTURE="$ROOT_DIR/docs/ci/conformance-fixtures/core-flows.v1.json"

fail() {
  echo "Conformance suite check failed: $*" >&2
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

require_file "conformance documentation" "$DOC"
require_file "conformance fixture" "$FIXTURE"

for section in \
  "Fixture source" \
  "Required flow coverage" \
  "Negative-security assertions" \
  "CI behavior" \
  "Upgrade and legacy paths" \
  "Non-mutating check"; do
  require_pattern "$section section" "$DOC" "^## $section$"
done

require_pattern "fixture schema version" "$FIXTURE" '"schemaVersion"[[:space:]]*:[[:space:]]*"idelium-conformance-suite.v1"'
require_pattern "fixture version" "$FIXTURE" '"fixtureVersion"[[:space:]]*:[[:space:]]*"1.0.0"'
require_pattern "compatibility window" "$FIXTURE" '"compatibilityWindow"'
require_pattern "threshold protection" "$FIXTURE" 'thresholds cannot be lowered without an RFC or release decision record'

for flow in \
  "authentication" \
  "tenant-context" \
  "asset-lifecycle" \
  "cycle-launch" \
  "parallel-execution" \
  "reporting" \
  "backward-compatibility"; do
  require_pattern "$flow flow" "$FIXTURE" "\"name\"[[:space:]]*:[[:space:]]*\"$flow\""
done

for assertion in \
  "tenant isolation" \
  "credential redaction" \
  "authorization denial" \
  "artifact access control" \
  "bounded retries" \
  "bounded timeouts"; do
  require_pattern "$assertion assertion" "$FIXTURE" "\"$assertion\""
done

if rg -n 'idelium\.io|password[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|token[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]|authorization[[:space:]]*[:=][[:space:]]*[^$`{<[:space:]]' "$DOC" "$FIXTURE"; then
  fail "conformance suite contains forbidden domain or literal credential pattern"
fi

echo "Conformance suite check passed."
