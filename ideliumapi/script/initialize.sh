#!/bin/sh
set -eu

cd /var/idelium-api
echo "Clearing stale application configuration."
php artisan config:clear

echo "Applying database migrations."
php artisan migrate --force --no-interaction

if [ "${IDELIUM_RUN_BASE_SEEDS:-false}" = "true" ]; then
    echo "Applying explicitly enabled base seeds."
    php artisan db:seed --force --no-interaction
fi

if [ "${IDELIUM_RUN_DEMO_SEEDS:-false}" = "true" ]; then
    if [ -z "${IDELIUM_DEMO_EMAIL:-}" ] || [ -z "${IDELIUM_DEMO_PASSWORD:-}" ]; then
        echo "Demo seeding requires demo email and password secrets." >&2
        exit 1
    fi
    echo "Applying explicitly enabled demo seed data."
    php artisan db:seed --class=DemoProfileSeeder --force --no-interaction
fi

echo "Database initialization completed successfully."
