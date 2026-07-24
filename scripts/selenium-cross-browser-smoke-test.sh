#!/usr/bin/env bash
set -euo pipefail

grid_url=${SELENIUM_GRID_URL:-http://127.0.0.1:${SELENIUM_GRID_PORT:-4444}}
page_url='data:text/html,<title>Idelium Selenium cross browser smoke</title><h1>ok</h1>'

redact_webdriver_payload() {
  sed -E 's/"sessionId"[[:space:]]*:[[:space:]]*"[^"]+"/"sessionId":"[REDACTED]"/g'
}

webdriver_request() {
  local method=$1
  local path=$2
  local payload=${3:-}

  if [ -n "$payload" ]; then
    curl --fail --silent --show-error \
      --request "$method" \
      --header "Content-Type: application/json" \
      --data "$payload" \
      "$grid_url$path"
  else
    curl --fail --silent --show-error \
      --request "$method" \
      "$grid_url$path"
  fi
}

wait_for_grid() {
  local attempts=${SELENIUM_GRID_WAIT_ATTEMPTS:-30}
  local attempt=1

  while [ "$attempt" -le "$attempts" ]; do
    if curl --fail --silent --show-error "$grid_url/status" | grep -q '"ready"[[:space:]]*:[[:space:]]*true'; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  echo "Selenium Grid did not become ready at $grid_url/status." >&2
  return 1
}

create_session_payload() {
  local browser=$1

  case "$browser" in
    chrome)
      printf '%s' '{"capabilities":{"alwaysMatch":{"browserName":"chrome","goog:chromeOptions":{"args":["--headless=new","--no-sandbox","--disable-dev-shm-usage"]}}}}'
      ;;
    firefox)
      printf '%s' '{"capabilities":{"alwaysMatch":{"browserName":"firefox","moz:firefoxOptions":{"args":["-headless"]}}}}'
      ;;
    *)
      echo "Unsupported browser '$browser'." >&2
      return 2
      ;;
  esac
}

extract_session_id() {
  sed -n 's/.*"sessionId"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

run_browser_smoke() {
  local browser=$1
  local session_id=
  local response=
  local title_response=

  echo "Running WebDriver smoke test on $browser."
  response=$(webdriver_request POST /session "$(create_session_payload "$browser")") || {
    echo "Failed to create a $browser WebDriver session." >&2
    printf '%s\n' "$response" | redact_webdriver_payload >&2
    return 1
  }
  session_id=$(printf '%s' "$response" | extract_session_id)
  if [ -z "$session_id" ]; then
    echo "WebDriver response did not include a session id." >&2
    printf '%s\n' "$response" | redact_webdriver_payload >&2
    return 1
  fi

  cleanup_session() {
    webdriver_request DELETE "/session/$session_id" >/dev/null || true
  }
  trap cleanup_session RETURN

  webdriver_request POST "/session/$session_id/url" "{\"url\":\"$page_url\"}" >/dev/null
  title_response=$(webdriver_request GET "/session/$session_id/title")
  if ! printf '%s' "$title_response" | grep -q "Idelium Selenium cross browser smoke"; then
    echo "Unexpected page title returned by $browser." >&2
    printf '%s\n' "$title_response" | redact_webdriver_payload >&2
    return 1
  fi

  echo "$browser WebDriver smoke test passed."
}

wait_for_grid
run_browser_smoke chrome
run_browser_smoke firefox

echo "Cross-browser WebDriver smoke test passed."
