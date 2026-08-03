FROM node:26.5.1-bookworm-slim@sha256:9e6f9357d371591e32ab6f2d8a26d63bdd0d17c29eee3f4f3e7e454d9634bf73 AS web-build

WORKDIR /build
COPY --from=web_source package.json package-lock.json ./
RUN npm ci
COPY --from=web_source . ./
RUN npm run build

FROM httpd:2.4.65-bookworm@sha256:fbc12199ccad031d8047e9c789d65aceee2d14f99ba90664cd3a3996867a5582

ARG WEB_SOURCE_REVISION=unknown
ARG STACK_SOURCE_REVISION=unknown
LABEL org.opencontainers.image.source="https://github.com/idelium/idelium-web" \
      org.opencontainers.image.revision="${WEB_SOURCE_REVISION}" \
      io.idelium.stack.revision="${STACK_SOURCE_REVISION}"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends curl openssl \
    && rm -rf /var/lib/apt/lists/*

COPY idelium-fe/conf/apache-httpd.conf /usr/local/apache2/conf/httpd.conf
COPY idelium-fe/conf/httpd-vhosts-idelium-ssl.conf /usr/local/apache2/conf/extra/httpd-vhosts-idelium-ssl.conf
COPY idelium-fe/script/entrypoint.sh /usr/local/bin/idelium-web-entrypoint
COPY --from=web-build /build/dist/ /usr/local/apache2/htdocs/

RUN chmod 0755 /usr/local/bin/idelium-web-entrypoint \
    && mkdir -p /usr/local/apache2/certs

ENTRYPOINT ["/usr/local/bin/idelium-web-entrypoint"]
CMD ["httpd-foreground"]
