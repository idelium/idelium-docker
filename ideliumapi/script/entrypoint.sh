#!/bin/sh
set -eu

read_secret() {
    variable_name="$1"
    file_variable_name="${variable_name}_FILE"
    eval "file_path=\${$file_variable_name:-}"
    if [ -n "$file_path" ]; then
        if [ ! -r "$file_path" ]; then
            echo "Required secret file for $variable_name is not readable: $file_path" >&2
            exit 1
        fi
        value=$(cat "$file_path")
        export "$variable_name=$value"
    fi
}

read_secret DB_PASSWORD
read_secret APP_KEY
read_secret IDELIUM_DEMO_EMAIL
read_secret IDELIUM_DEMO_PASSWORD
read_secret IDELIUM_ADMIN_EMAIL
read_secret IDELIUM_ADMIN_PASSWORD

if [ -z "${DB_PASSWORD:-}" ]; then
    echo "DB_PASSWORD must be provided through a runtime secret." >&2
    exit 1
fi
if [ -z "${APP_KEY:-}" ]; then
    echo "APP_KEY must be provided through a runtime secret." >&2
    exit 1
fi

exec "$@"
