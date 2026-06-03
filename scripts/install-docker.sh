#!/usr/bin/env bash
#
# Install Docker Engine and Compose v2 on Debian/Ubuntu.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

require_root
require_apt

if ! command -v docker >/dev/null 2>&1; then
  log "installing Docker..."
  "$HERE/install-apt-packages.sh"
  install -m 0755 -d /etc/apt/keyrings

  distro="$(. /etc/os-release && echo "${ID:-ubuntu}")"
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}")"
  [ -n "$codename" ] || die "could not determine Debian/Ubuntu codename"

  curl -fsSL "https://download.docker.com/linux/${distro}/gpg" -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${distro} ${codename} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get -o Acquire::Retries=3 update
  apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
  log "Docker present: $(docker --version)"
fi

systemctl enable --now docker >/dev/null 2>&1 || true
docker compose version >/dev/null 2>&1 || die "docker compose v2 plugin is required"
