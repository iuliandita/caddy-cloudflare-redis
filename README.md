# caddy-cloudflare-redis

Public Caddy image with two extra modules:

- [`github.com/caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare) for Cloudflare DNS-01 ACME challenges
- [`github.com/pberkel/caddy-storage-redis`](https://github.com/pberkel/caddy-storage-redis) for Redis-backed Caddy storage

The image tracks the official `caddy:<version>-alpine` image and rebuilds daily from GitHub Actions.

## Images

```text
ghcr.io/iuliandita/caddy-cloudflare-redis
docker.io/iuliandita/caddy-cloudflare-redis
```

Tags published by CI follow the official Caddy tag alias layout for the tracked upstream version:

```text
latest
alpine
2
2.11
2.11.3
2-alpine
2.11-alpine
2.11.3-alpine
```

Published platforms:

```text
linux/amd64
linux/arm64
```

The `arm64` image is built on GitHub's native `ubuntu-24.04-arm` runner instead of QEMU. CI pushes architecture-specific temporary tags, then merges them into the public multi-arch tags.

## Included versions

| Component | Version |
| --- | --- |
| Caddy | `2.11.3` |
| Cloudflare DNS module | `v0.2.4` |
| Redis storage module | `v1.8.0` |
| Final base image | `caddy:2.11.3-alpine` |

These reflect the latest build; the authoritative pins live in `.github/workflows/build.yml` (kept current by Renovate).

## Quick use

```bash
docker run --rm \
  -p 80:80 \
  -p 443:443 \
  -e CLOUDFLARE_API_TOKEN='[REDACTED]' \
  -v "$PWD/Caddyfile:/etc/caddy/Caddyfile:ro" \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/iuliandita/caddy-cloudflare-redis:alpine
```

## Cloudflare DNS example

```caddyfile
{
    email admin@example.com
}

example.com {
    tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    }

    reverse_proxy 127.0.0.1:8080
}
```

Use a Cloudflare API token with the minimum required DNS edit permissions for the relevant zone.
Do not bake the token into the image or commit it into your Caddyfile.

## Redis storage example

```caddyfile
{
    storage redis {
        host redis
        port 6379
        db 0
        key_prefix caddy
    }
}
```

Check the upstream Redis storage module docs for the full option set before using it in production.

## Entrypoint behavior

The image starts as root only long enough to repair ownership on common Caddy writable paths:

```text
/var/log/caddy
/data
/config
```

It then drops privileges with `su-exec` and runs Caddy as the `caddy` user.

That means bind-mounted volumes get self-healed on first start, but the Caddy process itself does not run as root.

## Healthcheck

The Docker healthcheck probes Caddy's admin API:

```text
http://localhost:2019/config/
```

This works with Caddy's default admin endpoint. If you disable the admin API in global Caddy config, the container healthcheck will fail unless you override it.

## Build locally

```bash
docker build -t caddy-cloudflare-redis:local .
docker run --rm caddy-cloudflare-redis:local caddy list-modules | grep -E 'dns.providers.cloudflare|storage.redis'
```

## Publishing

GitHub Actions publishes to GHCR automatically on `main`, on the daily schedule, and on manual dispatch.

Docker Hub publishing is also wired in, but requires these repository secrets:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

If those secrets are missing, the Docker Hub step is skipped and GHCR still publishes.

## License

MIT.
