#!/usr/bin/env bash
set -euo pipefail

umask 077
mkdir -p secrets

create_random_secret() {
  local path=$1
  if [[ ! -s "$path" ]]; then
    openssl rand -base64 32 | tr -d '\n' >"$path"
  fi
}

create_random_secret secrets/db_password
create_random_secret secrets/db_root_password
if [[ ! -s secrets/app_key ]]; then
  printf 'base64:' >secrets/app_key
  openssl rand -base64 32 | tr -d '\n' >>secrets/app_key
fi
if [[ ! -s secrets/demo_email ]]; then
  printf 'demo@example.invalid' >secrets/demo_email
fi
create_random_secret secrets/demo_password
if [[ ! -s secrets/admin_email ]]; then
  printf 'admin@idelium.io' >secrets/admin_email
fi
if [[ ! -s secrets/admin_password ]]; then
  printf 'admin' >secrets/admin_password
fi

echo "Development secrets are present in the ignored secrets directory."
echo "The generated demo password is stored in secrets/demo_password and is not printed."
echo "The demo administrator defaults are stored in secrets/admin_email and secrets/admin_password."
