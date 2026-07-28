#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT_DIR/.." && pwd)"

API_REPO="${IDELIUM_API_REPO:-$WORKSPACE_DIR/idelium-api}"
WEB_REPO="${IDELIUM_WEB_REPO:-$WORKSPACE_DIR/idelium-web}"
CLI_REPO="${IDELIUM_CLI_REPO:-$WORKSPACE_DIR/idelium-cli}"
DOCKER_REPO="${IDELIUM_DOCKER_REPO:-$ROOT_DIR}"

fail() {
  echo "Supply-chain provenance gate failed: $*" >&2
  exit 1
}

require_file() {
  local label="$1"
  local path="$2"

  test -f "$path" || fail "$label missing at $path"
}

require_absent() {
  local label="$1"
  local path="$2"

  test ! -e "$path" || fail "$label must not exist at $path"
}

require_pattern() {
  local label="$1"
  local path="$2"
  local pattern="$3"

  require_file "$label" "$path"
  grep -Eq "$pattern" "$path" || fail "$label missing required pattern in $path"
}

require_apache_license() {
  local repo_name="$1"
  local repo_path="$2"

  require_file "$repo_name LICENSE" "$repo_path/LICENSE"
  require_absent "$repo_name legacy LICENSE.txt" "$repo_path/LICENSE.txt"
  require_pattern "$repo_name Apache license text" "$repo_path/LICENSE" "Apache License"
}

require_git_repository() {
  local repo_name="$1"
  local repo_path="$2"

  git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || fail "$repo_name is not a Git repository at $repo_path"
  git -C "$repo_path" rev-parse HEAD | grep -Eq '^[0-9a-f]{40}$' \
    || fail "$repo_name source commit is not a full SHA"
}

for repo in \
  "Idelium API:$API_REPO" \
  "Idelium Web:$WEB_REPO" \
  "Idelium CLI:$CLI_REPO" \
  "Idelium Docker:$DOCKER_REPO"; do
  repo_name="${repo%%:*}"
  repo_path="${repo#*:}"
  require_git_repository "$repo_name" "$repo_path"
  require_apache_license "$repo_name" "$repo_path"
done

require_pattern "Idelium API npm license metadata" "$API_REPO/package.json" '"license"[[:space:]]*:[[:space:]]*"Apache-2.0"'
require_pattern "Idelium API Composer license metadata" "$API_REPO/composer.json" '"license"[[:space:]]*:[[:space:]]*"Apache-2.0"'
require_file "Idelium API npm lockfile" "$API_REPO/package-lock.json"
require_file "Idelium API Composer lockfile" "$API_REPO/composer.lock"

require_pattern "Idelium Web npm license metadata" "$WEB_REPO/package.json" '"license"[[:space:]]*:[[:space:]]*"Apache-2.0"'
require_pattern "Idelium Web npm package version" "$WEB_REPO/package.json" '"version"[[:space:]]*:[[:space:]]*"[^"]+"'
require_file "Idelium Web npm lockfile" "$WEB_REPO/package-lock.json"

require_pattern "Idelium CLI package license metadata" "$CLI_REPO/setup.py" "license='Apache-2.0'"
require_pattern "Idelium CLI package version source" "$CLI_REPO/setup.py" "version=get_version"

require_file "Supply-chain provenance policy" "$DOCKER_REPO/docs/release/supply-chain-provenance-policy.md"
require_pattern "Coordinated release train matrix" "$DOCKER_REPO/docs/release/coordinated-release-train.md" "Supported compatibility matrix"
require_pattern "Coordinated release train gates" "$DOCKER_REPO/docs/release/coordinated-release-train.md" "Release candidate gates"
require_pattern "Release runbook artifact traceability" "$DOCKER_REPO/docs/release/release-and-rollback-runbook.md" "checksums"
require_pattern "Version compatibility source references" "$DOCKER_REPO/docs/release/versioning-and-compatibility-policy.md" "source references"
require_pattern "Release regression gate policy linkage" "$DOCKER_REPO/docs/ci/release-regression-gates.md" "release notes include the pinned source references"

if rg -n 'idelium\.io' "$DOCKER_REPO/docs/release/supply-chain-provenance-policy.md"; then
  fail "Docker provenance policy must use idelium.org instead of idelium.io"
fi

echo "Supply-chain provenance gate passed."
