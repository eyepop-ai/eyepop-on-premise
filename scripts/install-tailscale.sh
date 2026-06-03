#!/usr/bin/env bash
#
# Optional: install Tailscale and join a tailnet for camera-network access.
#
# Usage:
#   sudo TS_AUTHKEY=tskey-auth-xxxxx scripts/install-tailscale.sh
#   sudo scripts/install-tailscale.sh
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

require_root

if [ -f "$ROOT/.env" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$ROOT/.env"
  set +a
fi

TS_HOSTNAME="${TS_HOSTNAME:-eyepop-agent}"
AUTHKEY="${TS_AUTHKEY:-}"

if ! command -v curl >/dev/null 2>&1; then
  "$HERE/install-apt-packages.sh"
fi

if ! command -v tailscale >/dev/null 2>&1; then
  log "installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
  log "Tailscale present: $(tailscale version | head -1)"
fi

systemctl enable --now tailscaled

up_args=(--accept-routes --accept-dns=false --hostname="${TS_HOSTNAME}" --ssh)
if [ -n "$AUTHKEY" ]; then
  log "bringing Tailscale up as ${TS_HOSTNAME}..."
  up_args+=(--authkey="${AUTHKEY}")
else
  log "no TS_AUTHKEY given; Tailscale will print an interactive login URL."
fi
tailscale up "${up_args[@]}"
tailscale set --accept-routes 2>/dev/null || true

log "Tailscale status:"
tailscale status || true
log "This node's tailnet IP:"
tailscale ip -4 || true
