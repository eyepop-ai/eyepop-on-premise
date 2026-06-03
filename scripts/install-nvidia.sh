#!/usr/bin/env bash
#
# Install NVIDIA Container Toolkit and verify GPU access from Docker.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

NVIDIA_CONTAINER_TOOLKIT_VERSION="${NVIDIA_CONTAINER_TOOLKIT_VERSION:-1.19.1-1}"

require_root
require_apt

if ! command -v nvidia-smi >/dev/null 2>&1 || ! nvidia-smi >/dev/null 2>&1; then
  die "NVIDIA driver not working (nvidia-smi failed). Install the GPU driver for this host, then re-run."
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
  log "NVIDIA Container Toolkit present"
fi

command -v docker >/dev/null 2>&1 || die "Docker is required before configuring the NVIDIA runtime"
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

log "verifying GPU access from a container..."
docker run --rm --gpus all ubuntu nvidia-smi -L >/dev/null 2>&1 \
  || die "GPU not visible inside containers. Check the toolkit/driver and retry."
log "GPU visible in containers."
