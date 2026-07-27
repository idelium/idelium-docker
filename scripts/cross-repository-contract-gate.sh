#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker_repo="${IDELIUM_DOCKER_REPO:-$root_dir}"
api_repo="${IDELIUM_API_REPO:-$root_dir/../idelium-api}"
web_repo="${IDELIUM_WEB_REPO:-$root_dir/../idelium-web}"
cli_repo="${IDELIUM_CLI_REPO:-$root_dir/../idelium-cli}"

fail() {
  echo "Contract gate failed: $*" >&2
  exit 1
}

require_file() {
  local file=$1
  [[ -f "$file" ]] || fail "missing file $file"
}

require_pattern() {
  local contract=$1
  local file=$2
  local pattern=$3
  require_file "$file"
  grep -Eq -- "$pattern" "$file" || fail "$contract missing in $file"
}

verify_ref() {
  local name=$1
  local repo=$2
  local expected=${3:-}

  [[ -d "$repo/.git" ]] || fail "$name repository is not checked out at $repo"

  if [[ -n "$expected" ]]; then
    [[ "$expected" =~ ^[0-9a-f]{40}$ ]] || fail "$name ref must be a full commit SHA"
    local actual
    actual="$(git -C "$repo" rev-parse HEAD)"
    [[ "$actual" == "$expected" ]] || fail "$name ref mismatch"
  fi
}

verify_ref "idelium-docker" "$docker_repo" "${IDELIUM_DOCKER_REF:-}"
verify_ref "idelium-api" "$api_repo" "${IDELIUM_API_REF:-}"
verify_ref "idelium-web" "$web_repo" "${IDELIUM_WEB_REF:-}"
verify_ref "idelium-cli" "$cli_repo" "${IDELIUM_CLI_REF:-}"

"$docker_repo/scripts/validate-github-actions-example.sh"
"$docker_repo/scripts/validate-gitlab-ci-example.sh"

require_pattern \
  "API Sanctum authentication boundary" \
  "$api_repo/routes/api.php" \
  "middleware\\('auth:sanctum'\\)"
require_pattern \
  "API Idelium-Key authentication boundary" \
  "$api_repo/app/Http/Middleware/AuthenticateIdeliumKey.php" \
  "Idelium-Key"
require_pattern \
  "API parallel scheduling boundary" \
  "$api_repo/routes/api.php" \
  "parallel-runs"
require_pattern \
  "API worker cancellation boundary" \
  "$api_repo/app/Http/Controllers/ParallelRunScheduleController.php" \
  "claimWorker|updateWorker|cancel"
require_pattern \
  "API deterministic result aggregation" \
  "$api_repo/app/Http/Controllers/ParallelRunScheduleController.php" \
  "resultSummary|ksort"

require_pattern \
  "Web project-scoped parallel run endpoint" \
  "$web_repo/src/main.js" \
  "parallelRuns: \"admin/projects\""
require_pattern \
  "Web report download controls" \
  "$web_repo/src/view/testsperformed.vue" \
  "downloadReport|availableReports|reportFormats"
require_pattern \
  "Web localized parallel monitoring labels" \
  "$web_repo/src/languages/english.js" \
  "Parallel executions"

require_pattern \
  "CLI non-interactive configuration inputs" \
  "$cli_repo/src/idelium/_internal/ideliumclib.py" \
  "--idProject|--idCycle|--environment"
require_pattern \
  "CLI report generation options" \
  "$cli_repo/src/idelium/_internal/ideliumclib.py" \
  "--jsonReport|--htmlReport|--markdownReport|--junitReport"
require_pattern \
  "CLI canonical report writers" \
  "$cli_repo/src/idelium/_internal/ideliumws.py" \
  "write_json_report|write_junit_report"

require_pattern \
  "Docker GitHub CI result artifacts" \
  "$docker_repo/docs/ci/github-actions-idelium.yml" \
  "idelium-report\\.json|idelium-junit\\.xml"
require_pattern \
  "Docker GitLab CI result artifacts" \
  "$docker_repo/docs/ci/gitlab-ci-idelium.yml" \
  "idelium-report\\.json|idelium-junit\\.xml"

echo "Cross-repository Idelium contract gate passed."
