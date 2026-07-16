FROM mariadb:12.3.2@sha256:628f228f0fd5913a220438693576b29b6fe4dc1fa0a1298c0e98579fae28635f

ARG STACK_SOURCE_REVISION=unknown
LABEL org.opencontainers.image.source="https://github.com/idelium/idelium-docker" \
      org.opencontainers.image.revision="${STACK_SOURCE_REVISION}"

COPY ideliumdb/sql/ /docker-entrypoint-initdb.d/
