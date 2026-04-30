# Security policy

## Reporting a vulnerability

Open a private vulnerability report through GitHub Security Advisories if available, or contact the maintainer directly.

Do not open a public issue for exploitable vulnerabilities until there is a fix or mitigation.

## Supported image

Only the current Caddy release tracked by this repository is supported.

## Scope

This repository packages Caddy with selected third-party modules. Vulnerabilities may come from:

- the official Caddy base image
- Caddy itself
- bundled Go dependencies
- `github.com/caddy-dns/cloudflare`
- `github.com/pberkel/caddy-storage-redis`
- Alpine packages in the final image

The CI rebuilds daily to pick up upstream base-image fixes.
