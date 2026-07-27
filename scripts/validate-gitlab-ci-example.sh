#!/usr/bin/env bash
set -euo pipefail

pipeline=${1:-docs/ci/gitlab-ci-idelium.yml}

if [[ ! -f "$pipeline" ]]; then
  echo "GitLab CI example not found: $pipeline" >&2
  exit 2
fi

required_patterns=(
  'image: docker:28\.3\.3-cli'
  'name: docker:28\.3\.3-dind'
  'IDELIUM_DOCKER_REF'
  'IDELIUM_API_REF'
  'IDELIUM_WEB_REF'
  'IDELIUM_CLI_REF'
  './start-idelium\.sh --demo'
  '--jsonReport=/workspace/reports/idelium-report\.json'
  '--htmlReport=/workspace/reports/idelium-report\.html'
  '--markdownReport=/workspace/reports/idelium-report\.md'
  '--junitReport=/workspace/reports/idelium-junit\.xml'
  'junit: idelium-docker/reports/idelium-junit\.xml'
  'idelium-docker/diagnostics/'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Eq -- "$pattern" "$pipeline"; then
    echo "Missing required GitLab CI contract: $pattern" >&2
    exit 1
  fi
done

if grep -En 'image: .*:latest|name: .*:latest' "$pipeline"; then
  echo "GitLab CI images must not use latest tags." >&2
  exit 1
fi

if grep -En '(password|secret|token|api[_-]?key):[[:space:]]*[^$]' "$pipeline"; then
  echo "Potential embedded credential found in GitLab CI example." >&2
  exit 1
fi

echo "GitLab CI example contract is valid."
