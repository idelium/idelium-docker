#!/usr/bin/env bash
set -euo pipefail

workflow=${1:-docs/ci/github-actions-idelium.yml}

if [[ ! -f "$workflow" ]]; then
  echo "GitHub Actions example not found: $workflow" >&2
  exit 2
fi

if grep -En 'uses: [^@[:space:]]+@v[0-9]+([[:space:]]|$)' "$workflow"; then
  echo "GitHub Actions dependencies must be pinned to full versions, not moving majors." >&2
  exit 1
fi

required_patterns=(
  'actions/checkout@v4\.2\.2'
  'actions/upload-artifact@v4\.6\.2'
  'docker compose'
  './start-idelium\.sh --demo'
  '--jsonReport=/workspace/reports/idelium-report\.json'
  '--htmlReport=/workspace/reports/idelium-report\.html'
  '--markdownReport=/workspace/reports/idelium-report\.md'
  '--junitReport=/workspace/reports/idelium-junit\.xml'
  'IDELIUM_API_KEY: \${{ secrets\.IDELIUM_API_KEY }}'
)

for pattern in "${required_patterns[@]}"; do
  if ! grep -Eq -- "$pattern" "$workflow"; then
    echo "Missing required GitHub Actions contract: $pattern" >&2
    exit 1
  fi
done

if grep -En '(password|secret|token|api[_-]?key):[[:space:]]*[^${{]' "$workflow"; then
  echo "Potential embedded credential found in GitHub Actions example." >&2
  exit 1
fi

echo "GitHub Actions CI example contract is valid."
