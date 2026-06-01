# syntax=docker/dockerfile:1

# renovate: datasource=docker depName=caddy
ARG CADDY_VERSION=2.11.3
# renovate: datasource=github-releases depName=caddy-dns/cloudflare
ARG CLOUDFLARE_DNS_VERSION=v0.2.4
# renovate: datasource=github-releases depName=pberkel/caddy-storage-redis
ARG REDIS_STORAGE_VERSION=v1.8.0
# renovate: datasource=go depName=go.opentelemetry.io/otel
ARG OTEL_VERSION=v1.43.0

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG CLOUDFLARE_DNS_VERSION
ARG REDIS_STORAGE_VERSION
ARG OTEL_VERSION

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_DNS_VERSION} \
    --with github.com/pberkel/caddy-storage-redis@${REDIS_STORAGE_VERSION} \
    --with go.opentelemetry.io/otel@${OTEL_VERSION}

FROM caddy:${CADDY_VERSION}-alpine

ARG CADDY_VERSION
ARG CLOUDFLARE_DNS_VERSION
ARG REDIS_STORAGE_VERSION
ARG OTEL_VERSION

LABEL org.opencontainers.image.title="caddy-cloudflare-redis" \
      org.opencontainers.image.description="Caddy with Cloudflare DNS and Redis storage modules" \
      org.opencontainers.image.source="https://github.com/iuliandita/caddy-cloudflare-redis" \
      org.opencontainers.image.documentation="https://github.com/iuliandita/caddy-cloudflare-redis#readme" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${CADDY_VERSION}" \
      org.opencontainers.image.base.name="docker.io/library/caddy:${CADDY_VERSION}-alpine"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Health check via the Caddy admin API, available by default on localhost:2019.
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:2019/config/ || exit 1

RUN set -eux; \
    apk upgrade --no-cache; \
    if ! id caddy >/dev/null 2>&1; then \
      addgroup -S caddy; \
      adduser -S -G caddy caddy; \
    fi; \
    apk add --no-cache su-exec

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
