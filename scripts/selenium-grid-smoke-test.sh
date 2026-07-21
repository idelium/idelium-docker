#!/usr/bin/env bash
set -euo pipefail

echo "Running the Selenium Grid WebDriver smoke test."

docker compose "$@" exec --no-TTY selenium-grid sh -eu -c '
  payload='\''{"capabilities":{"alwaysMatch":{"browserName":"chrome","goog:chromeOptions":{"args":["--headless=new","--no-sandbox","--disable-dev-shm-usage"]}}}}'\''
  response="$(curl --fail --silent --show-error \
    --header "Content-Type: application/json" \
    --data "$payload" \
    http://127.0.0.1:4444/session)"
  session_id="$(printf "%s" "$response" | sed -n "s/.*\"sessionId\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p")"
  if [ -z "$session_id" ]; then
    printf "%s\n" "$response" >&2
    exit 1
  fi

  curl --fail --silent --show-error \
    --header "Content-Type: application/json" \
    --data "{\"url\":\"data:text/html,<title>Idelium Selenium smoke</title><h1>ok</h1>\"}" \
    "http://127.0.0.1:4444/session/$session_id/url" >/dev/null

  title_response="$(curl --fail --silent --show-error \
    "http://127.0.0.1:4444/session/$session_id/title")"
  printf "%s" "$title_response" | grep -q "Idelium Selenium smoke"

  curl --fail --silent --show-error \
    --request DELETE \
    "http://127.0.0.1:4444/session/$session_id" >/dev/null
'

echo "Selenium Grid WebDriver smoke test passed."
