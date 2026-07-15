FROM mariadb:10.6.22@sha256:7589b386fa6686a5d5f131b504ed21c81e492c48b78c6c4be0d5be1066542559

ARG STACK_SOURCE_REVISION=unknown
LABEL org.opencontainers.image.source="https://github.com/idelium/idelium-docker" \
      org.opencontainers.image.revision="${STACK_SOURCE_REVISION}"

COPY ideliumdb/sql/ /docker-entrypoint-initdb.d/
