#!/usr/bin/env bash
set -euo pipefail

echo "Running the HTTPS frontend and proxied API smoke test."
docker compose "$@" exec --no-TTY ideliumfe \
  curl --fail --silent --show-error \
  --cacert /usr/local/apache2/certs/server.crt \
  https://localhost/api/sanctum/csrf-cookie >/dev/null
echo "HTTPS API smoke test passed."
