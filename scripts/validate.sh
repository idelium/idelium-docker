#!/usr/bin/env bash
set -euo pipefail

for script in start-idelium.sh scripts/*.sh; do
  bash -n "$script"
done

docker compose --env-file .env.example -f docker-compose.yml -f compose.demo.yml config --quiet

if awk '/^FROM / && $2 !~ /@sha256:/ { print FILENAME ":" FNR ": unpinned base image"; failed=1 } END { exit failed }' \
  idelium-fe/Dockerfile ideliumapi/Dockerfile ideliumdb/Dockerfile; then
  :
else
  exit 1
fi

if rg -n '(:latest|git clone|curl .*--insecure|curl .*-k\b|MYSQL_(ROOT_)?PASSWORD[=:][[:space:]]*[^$])' \
  Dockerfile docker-compose.yml compose.*.yml idelium-fe ideliumapi ideliumdb 2>/dev/null; then
  echo "Mutable sources, disabled TLS, or embedded database passwords were found." >&2
  exit 1
fi

for service in ideliumdb ideliumapi ideliumfe; do
  docker compose --env-file .env.example config | grep -q "  $service:"
done

echo "Compose and shell validation passed."
