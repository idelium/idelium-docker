#!/usr/bin/env bash
set -euo pipefail

compose_files=(
  -f docker-compose.yml
  -f compose.runner.yml
  -f compose.selenium.yml
)
project_name=${IDELIUM_PARALLEL_PROJECT:-idelium-parallel-it}
base_url=${IDELIUM_BASE_URL:-https://ideliumfe}
project_id=${IDELIUM_PROJECT_ID:?IDELIUM_PROJECT_ID is required}
environment_name=${IDELIUM_ENVIRONMENT:?IDELIUM_ENVIRONMENT is required}
api_key_file=${IDELIUM_API_KEY_FILE:?IDELIUM_API_KEY_FILE is required}
cycle_ids=${IDELIUM_CYCLE_IDS:-${IDELIUM_CYCLE_ID:?IDELIUM_CYCLE_ID or IDELIUM_CYCLE_IDS is required}}
worker_count=${IDELIUM_PARALLEL_WORKERS:-2}
reports_dir=${IDELIUM_PARALLEL_REPORT_DIR:-reports/parallel-integration}

IFS=',' read -r -a cycles <<<"$cycle_ids"

compose() {
  docker compose -p "$project_name" "${compose_files[@]}" "$@"
}

wait_for_service_health() {
  local service=$1
  local attempts=${IDELIUM_HEALTH_ATTEMPTS:-60}
  local attempt=1

  while [ "$attempt" -le "$attempts" ]; do
    if [ "$(compose ps --format json "$service" | python3 -c 'import json,sys; rows=[json.loads(line) for line in sys.stdin if line.strip()]; print(rows[0].get("Health","") if rows else "")')" = "healthy" ]; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  echo "Service '$service' did not become healthy." >&2
  return 1
}

run_cycle() {
  local mode=$1
  local cycle_id=$2
  local report_dir="$reports_dir/$mode/cycle-$cycle_id"

  mkdir -p "$report_dir"
  compose run --rm \
    --no-deps \
    --volume "$(pwd)/$report_dir:/reports" \
    --volume "$api_key_file:/home/idelium/.idelium:ro" \
    idelium-cli-runner \
    idelium \
      --idProject="$project_id" \
      --idCycle="$cycle_id" \
      --environment="$environment_name" \
      --ideliumwsBaseurl="$base_url" \
      --test \
      --jsonReport="/reports/result.json" \
      --htmlReport="/reports/result.html" \
      --markdownReport="/reports/result.md" \
      --junitReport="/reports/result.xml"
}

run_sequential() {
  for cycle_id in "${cycles[@]}"; do
    run_cycle sequential "$cycle_id"
  done
}

run_parallel() {
  local active=0
  local pids=()

  for cycle_id in "${cycles[@]}"; do
    run_cycle parallel "$cycle_id" &
    pids+=("$!")
    active=$((active + 1))
    if [ "$active" -ge "$worker_count" ]; then
      wait "${pids[0]}"
      pids=("${pids[@]:1}")
      active=$((active - 1))
    fi
  done

  for pid in "${pids[@]}"; do
    wait "$pid"
  done
}

compare_reports() {
  python3 - "$reports_dir" "${cycles[@]}" <<'PY'
import json
import sys
from pathlib import Path

reports_dir = Path(sys.argv[1])
cycles = sys.argv[2:]

def normalized(path):
    payload = json.loads(path.read_text(encoding="utf-8"))
    return {
        "status": payload.get("run", {}).get("status"),
        "summary": payload.get("summary", {}),
        "tests": [
            {
                "name": test.get("name"),
                "steps": [
                    {
                        "name": step.get("name"),
                        "type": step.get("type"),
                        "status": step.get("status"),
                    }
                    for step in test.get("steps", [])
                ],
            }
            for test in payload.get("tests", [])
        ],
    }

for cycle in cycles:
    sequential = normalized(reports_dir / "sequential" / f"cycle-{cycle}" / "result.json")
    parallel = normalized(reports_dir / "parallel" / f"cycle-{cycle}" / "result.json")
    if sequential != parallel:
        raise SystemExit(f"Sequential and parallel outcomes differ for cycle {cycle}.")
PY
}

cleanup_reports() {
  find "$reports_dir" -type f -name '*.tmp' -delete
}

if [ "$worker_count" -le 0 ]; then
  echo "IDELIUM_PARALLEL_WORKERS must be greater than zero." >&2
  exit 2
fi

mkdir -p "$reports_dir"
compose up -d --build ideliumdb ideliuminit ideliumapi ideliumfe selenium-grid
wait_for_service_health ideliumdb
wait_for_service_health ideliumapi
wait_for_service_health ideliumfe
wait_for_service_health selenium-grid
trap cleanup_reports EXIT

run_sequential
run_parallel
compare_reports

echo "Parallel execution integration test passed with equivalent outcomes."
