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

configure_docker_group() {
  local user="${SUDO_USER:-}"

  [ -n "$user" ] || return 0
  [ "$user" != "root" ] || return 0

  if ! getent group docker >/dev/null 2>&1; then
    groupadd docker
  fi

  if id -nG "$user" | tr ' ' '\n' | grep -qx docker; then
    log "$user is already in the docker group"
    return 0
  fi

  usermod -aG docker "$user"
  log "added $user to the docker group"
  log "log out and back in for non-sudo docker commands to work"
}

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
configure_docker_group
