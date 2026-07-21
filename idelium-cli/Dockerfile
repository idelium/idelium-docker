FROM node:22.17.0-bookworm-slim@sha256:b04ce4ae4e95b522112c2e5c52f781471a5cbc3b594527bcddedee9bc48c03a0

ARG CLI_SOURCE_REVISION=unknown
ARG STACK_SOURCE_REVISION=unknown
LABEL org.opencontainers.image.source="https://github.com/idelium/idelium-cli" \
      org.opencontainers.image.revision="${CLI_SOURCE_REVISION}" \
      io.idelium.stack.revision="${STACK_SOURCE_REVISION}"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/idelium-cli
COPY --from=cli_source pyproject.toml setup.py setup.cfg MANIFEST.in README.md LICENSE ./
COPY --from=cli_source src ./src
RUN python3 -m venv /opt/idelium-cli \
    && /opt/idelium-cli/bin/python -m pip install --upgrade pip \
    && /opt/idelium-cli/bin/python -m pip install .

COPY idelium-cli/script/entrypoint.sh /usr/local/bin/idelium-cli-entrypoint
RUN useradd --create-home --shell /usr/sbin/nologin idelium \
    && chmod 0755 /usr/local/bin/idelium-cli-entrypoint

USER idelium
WORKDIR /home/idelium
ENV PATH="/opt/idelium-cli/bin:${PATH}"
ENTRYPOINT ["/usr/local/bin/idelium-cli-entrypoint"]
CMD ["idelium", "--help"]
