#!/usr/bin/env bash

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

TARGET="${1:-cuda}"
NVIDIA_CONTAINER_TOOLKIT_VERSION="${NVIDIA_CONTAINER_TOOLKIT_VERSION:-1.19.1-1}"

require_root

if [ "$TARGET" = "jetson" ]; then
  [ -f /etc/nv_tegra_release ] || die "Jetson Linux was not detected"
  docker info --format '{{json .Runtimes}}' | grep -q 'nvidia' \
    || die "the NVIDIA container runtime is not configured; install it through JetPack"
  log "Jetson NVIDIA container runtime available."
  exit 0
fi

[ "$TARGET" = "cuda" ] || die "unknown NVIDIA target: $TARGET"
require_apt

if ! command -v nvidia-smi >/dev/null 2>&1 || ! nvidia-smi >/dev/null 2>&1; then
  die "NVIDIA driver not working. Install the driver for this host, then re-run."
fi
log "GPU driver OK: $(nvidia-smi --query-gpu=name --format=csv,noheader | paste -sd', ' -)"

if ! command -v nvidia-ctk >/dev/null 2>&1; then
  log "installing NVIDIA Container Toolkit..."
  "$HERE/install-apt-packages.sh"
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --dearmor --yes -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    > /etc/apt/sources.list.d/nvidia-container-toolkit.list

  apt-get -o Acquire::Retries=3 update
  apt-get install -y --no-install-recommends \
    nvidia-container-toolkit="${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
    nvidia-container-toolkit-base="${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
    libnvidia-container-tools="${NVIDIA_CONTAINER_TOOLKIT_VERSION}" \
    libnvidia-container1="${NVIDIA_CONTAINER_TOOLKIT_VERSION}"
else
  log "NVIDIA Container Toolkit present."
fi

nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

docker run --rm --gpus all ubuntu nvidia-smi -L >/dev/null 2>&1 \
  || die "GPU not visible inside containers. Check the toolkit and driver."
log "GPU visible in containers."
