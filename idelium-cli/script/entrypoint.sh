#!/usr/bin/env sh
set -eu

if [ -f /run/secrets/idelium_cli_api_key ]; then
  install -m 600 /run/secrets/idelium_cli_api_key "$HOME/.idelium"
fi

exec "$@"
