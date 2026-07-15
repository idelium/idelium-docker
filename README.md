![Idelium](https://idelium.io/assets/images/idelium.png)

# Idelium local stack

This repository builds the Idelium API, Web application, and MariaDB images from
the adjacent `idelium-api` and `idelium-web` checkouts. Builds never clone a
moving branch. Application dependencies come from `composer.lock` and
`package-lock.json`.

## Repository layout

Place the repositories next to each other:

```text
idelium-api/
idelium-docker/
idelium-web/
```

Copy `.env.example` to `.env` and adjust non-secret configuration. Secret values
must be stored in ignored files or supplied by the deployment secret provider.

## Explicit demo startup

Demo data and a development certificate are enabled only by the demo overlay:

```sh
./start-idelium.sh --demo
```

The command creates random ignored development secrets when they are absent,
builds the three local images, waits for the database, one-shot migrations and
seeds, API, and frontend, then runs an HTTPS request through the frontend proxy.
The generated demo identity is stored in `secrets/demo_email` and
`secrets/demo_password`; credentials are never printed or committed.

Stop the stack without deleting database data:

```sh
docker compose -f docker-compose.yml -f compose.demo.yml down
```

To remove demo database and certificate volumes as well, explicitly add
`--volumes`.

## Production-oriented startup

Create the database password, root password, and Laravel application key through
your secret provider. Mount a trusted certificate directory containing
`server.crt` and `server.key`, set `TLS_CERT_DIR`, and run:

```sh
./start-idelium.sh --production
```

Production mode fails instead of generating a self-signed certificate. Demo seeds
remain disabled. See [operations.md](docs/operations.md) for certificate, secret
rotation, troubleshooting, and rollback guidance.

## Reproducible local images

Commit all three repositories, then build from their exact revisions:

```sh
./scripts/build-local.sh --no-cache
./scripts/build-local.sh
```

The script refuses dirty source trees, applies versioned image tags, and verifies
OCI revision labels against every checkout. Repeating it without source changes
uses the same application revisions and lockfiles.

## Published release images

Pulling published images is deliberately separate from local builds. Set complete
versioned image references or digests in `API_RELEASE_IMAGE`, `WEB_RELEASE_IMAGE`,
and `DB_RELEASE_IMAGE`, then run:

```sh
docker compose -f docker-compose.yml -f compose.production.yml -f compose.release.yml pull
./start-idelium.sh --release
```

The release startup uses `--no-build`; it cannot silently replace published
artifacts with local sources.
