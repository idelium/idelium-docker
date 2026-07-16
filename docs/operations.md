# Idelium stack operations

## Readiness and logs

Startup succeeds only after the database is healthy, the initialization container
has completed migrations and explicitly enabled seeds, the API is serving HTTP
and can inspect migrations, and the HTTPS frontend responds.

Useful commands:

```sh
docker compose ps
docker compose logs --tail=100 ideliuminit
docker compose logs --tail=100 ideliumapi
docker compose logs --tail=100 ideliumfe
./scripts/smoke-test.sh -f docker-compose.yml -f compose.production.yml
```

If startup fails, inspect `ideliuminit` first. It is a one-shot service and its
non-zero exit status intentionally prevents the API from starting.

## Secrets and rotation

The tracked configuration contains paths and variable names only. Database
passwords, the Laravel `APP_KEY`, administrator and demo credentials, and TLS private keys must come
from Docker secrets or an equivalent runtime provider.

Rotate database credentials by creating new secret versions, updating the
database account in a controlled maintenance window, updating the mounted secret
files, and recreating the database, initialization, and API containers. Keep the
previous secret version until the new API is healthy. Rotating `APP_KEY` invalidates
encrypted application data and sessions, so follow the Laravel key-rotation plan
and force reauthentication. Rotate TLS certificates by replacing both files
atomically and recreating the frontend container.

Never print secret files in CI or support logs. Revoke and replace a value
immediately if secret scanning or operational review finds an exposure.

## Certificates

Demo mode creates a short-lived self-signed certificate at container startup and
the smoke test trusts that exact certificate through `--cacert`. It never disables
TLS verification. Production mode requires a certificate issued by the
organization's trusted CA in the directory selected by `TLS_CERT_DIR`.

The public HTTPS virtual host sends a restrictive Content Security Policy and
standard browser hardening headers. When adding a third-party browser integration,
update the smallest relevant CSP directive and validate the complete login and
authenticated flows before deployment. Do not add wildcard script sources or
`unsafe-eval`.

## Runtime privilege model

All services set `no-new-privileges` and use an init process for signal handling
and zombie reaping. MariaDB and Apache retain their upstream entrypoint model so
their root startup process can initialize mounted storage, bind privileged ports,
and then switch to the image's unprivileged worker account. Do not add privileged
mode, host networking, host PID namespaces, or the Docker socket to these
services. Review required capabilities before introducing any runtime tool.

## Deployment and rollback

Migrations run before the API and must remain backward compatible with the
previous release during a rolling deployment. Back up the database before a
release containing schema changes. Roll back by restoring the prior versioned
image references; if a migration is not backward compatible, restore the matching
database backup according to that release's migration note.
