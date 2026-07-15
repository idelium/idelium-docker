#!/usr/bin/env bash
set -euo pipefail

for repository in ../idelium-api ../idelium-web .; do
  if ! git -C "$repository" diff --quiet || ! git -C "$repository" diff --cached --quiet; then
    echo "Refusing a reproducible build because $repository has uncommitted changes." >&2
    exit 1
  fi
done

export API_SOURCE_REVISION=${API_SOURCE_REVISION:-$(git -C ../idelium-api rev-parse HEAD)}
export WEB_SOURCE_REVISION=${WEB_SOURCE_REVISION:-$(git -C ../idelium-web rev-parse HEAD)}
export STACK_SOURCE_REVISION=${STACK_SOURCE_REVISION:-$(git rev-parse HEAD)}
export IDELIUM_VERSION=${IDELIUM_VERSION:-${STACK_SOURCE_REVISION:0:12}}

echo "Building Idelium $IDELIUM_VERSION from fixed local revisions."
echo "API revision: $API_SOURCE_REVISION"
echo "Web revision: $WEB_SOURCE_REVISION"
echo "Stack revision: $STACK_SOURCE_REVISION"
docker compose build "$@"

test "$(docker image inspect "${API_IMAGE:-idelium/api}:$IDELIUM_VERSION" --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}')" = "$API_SOURCE_REVISION"
test "$(docker image inspect "${WEB_IMAGE:-idelium/web}:$IDELIUM_VERSION" --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}')" = "$WEB_SOURCE_REVISION"
test "$(docker image inspect "${DB_IMAGE:-idelium/db}:$IDELIUM_VERSION" --format '{{ index .Config.Labels "org.opencontainers.image.revision" }}')" = "$STACK_SOURCE_REVISION"
echo "Image revision metadata matches every checked-out source revision."
