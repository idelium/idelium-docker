#!/bin/sh
set -eu

cert_dir=/usr/local/apache2/certs
cert_file="$cert_dir/server.crt"
key_file="$cert_dir/server.key"

if [ "${TLS_MODE:-production}" = "development" ]; then
    if [ ! -s "$cert_file" ] || [ ! -s "$key_file" ]; then
        echo "Generating a development-only TLS certificate for ${TLS_COMMON_NAME:-localhost}."
        openssl req -x509 -newkey rsa:2048 -nodes -days 30 \
            -keyout "$key_file" \
            -out "$cert_file" \
            -subj "/CN=${TLS_COMMON_NAME:-localhost}" \
            -addext "subjectAltName=DNS:${TLS_COMMON_NAME:-localhost},DNS:localhost,IP:127.0.0.1"
        chmod 0600 "$key_file"
    fi
elif [ ! -s "$cert_file" ] || [ ! -s "$key_file" ]; then
    echo "Production TLS requires server.crt and server.key in $cert_dir." >&2
    exit 1
fi

exec "$@"
