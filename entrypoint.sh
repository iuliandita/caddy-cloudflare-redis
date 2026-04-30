#!/bin/sh
set -eu

# Fix volume permissions for the common Caddy writable paths, then drop
# privileges before starting Caddy. This keeps first-run bind mounts sane
# without running the Caddy process as root.
for dir in /var/log/caddy /data /config; do
    if [ -d "$dir" ] && [ "$(stat -c %u "$dir")" != "$(id -u caddy)" ]; then
        chown -R caddy:caddy "$dir"
    fi
done

exec su-exec caddy "$@"
