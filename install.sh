#!/usr/bin/env bash

set -euo pipefail

MODE=""
HARDWARE=""
START=1

usage() {
  cat <<'EOF'
Usage: sudo ./install.sh --mode <standalone|agent> --hardware <hardware> [--no-start]

Hardware:
  cpu
  nvidia-cuda
  nvidia-jetson
  intel-openvino
  qualcomm-qnn
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --mode)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      MODE="$2"
      shift 2
      ;;
    --hardware)
      [ "$#" -ge 2 ] || { usage >&2; exit 2; }
      HARDWARE="$2"
      shift 2
      ;;
    --no-start)
      START=0
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

case "$MODE" in
  standalone|agent) ;;
  *) usage >&2; exit 2 ;;
esac

case "$HARDWARE" in
  cpu|nvidia-cuda|nvidia-jetson|intel-openvino|qualcomm-qnn) ;;
  *) usage >&2; exit 2 ;;
esac

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/scripts/lib.sh"

COMPOSE_ARGS=(
  --project-directory "$HERE"
  --env-file "$HERE/.env"
  -f "$HERE/compose.yaml"
  -f "$HERE/deployments/modes/$MODE.yaml"
  -f "$HERE/deployments/hardware/$HARDWARE.yaml"
)
COMPOSE_ENV=()

require_group_id() {
  local group_name="$1"
  local env_name="$2"
  local group_id

  group_id="$(getent group "$group_name" | cut -d: -f3)"
  [ -n "$group_id" ] || die "host group '$group_name' is required for $HARDWARE"
  export "$env_name=$group_id"
}

registry_login() {
  local username="${EYEPOP_REGISTRY_USERNAME:-}"
  local password="${EYEPOP_REGISTRY_PASSWORD:-}"

  if [ -z "$username" ]; then
    [ -t 0 ] || die "set EYEPOP_REGISTRY_USERNAME for non-interactive installation"
    read -r -p 'EyePop registry username: ' username
  fi
  if [ -z "$password" ]; then
    [ -t 0 ] || die "set EYEPOP_REGISTRY_PASSWORD for non-interactive installation"
    read -r -s -p 'EyePop registry password: ' password
    printf '\n'
  fi

  printf '%s' "$password" | docker login registry.eyepop.ai \
    --username "$username" \
    --password-stdin >/dev/null \
    || die "Docker login failed. Check the registry credentials from the EyePop dashboard."
}

require_root
[ -f "$HERE/.env" ] || {
  cp "$HERE/.env.example" "$HERE/.env"
  die ".env created from .env.example. Add the EyePop account credentials, then re-run."
}

require_env EYEPOP_URL "$HERE/.env" >/dev/null
require_env EYEPOP_API_KEY "$HERE/.env" >/dev/null
require_env EYEPOP_ACCOUNT_UUID "$HERE/.env" >/dev/null
HTTP_PORT="$(env_value EYEPOP_HTTP_PORT "$HERE/.env" || true)"
HTTP_PORT="${HTTP_PORT:-8080}"

if [ "$MODE" = "agent" ]; then
  [ -d "$HERE/agents.d/streams" ] || die "agents.d/streams is missing"
  if ! find "$HERE/agents.d/streams" -maxdepth 1 -type f -name '*.yaml' ! -name '*.example.yaml' | grep -q .; then
    die "add a stream config: cp agents.d/streams/camera_1.example.yaml agents.d/streams/camera_1.yaml"
  fi
fi

"$HERE/scripts/install-docker.sh"

case "$HARDWARE" in
  nvidia-cuda)
    "$HERE/scripts/install-nvidia.sh" cuda
    ;;
  nvidia-jetson)
    "$HERE/scripts/install-nvidia.sh" jetson
    ;;
  intel-openvino)
    [ -d /dev/dri ] || die "/dev/dri is required for Intel accelerator access"
    require_group_id render RENDER_GROUP_ID
    COMPOSE_ENV+=("RENDER_GROUP_ID=$RENDER_GROUP_ID")
    ;;
  qualcomm-qnn)
    QAIRT_SDK_ROOT="$(require_env QAIRT_SDK_ROOT "$HERE/.env")"
    export QAIRT_SDK_ROOT
    [ -d "$QAIRT_SDK_ROOT/lib/hexagon-v73/unsigned" ] || die "QAIRT Hexagon libraries not found under $QAIRT_SDK_ROOT"
    require_group_id fastrpc FASTRPC_GROUP_ID
    require_group_id dmaheap DMAHEAP_GROUP_ID
    COMPOSE_ENV+=("FASTRPC_GROUP_ID=$FASTRPC_GROUP_ID" "DMAHEAP_GROUP_ID=$DMAHEAP_GROUP_ID")
    ;;
esac

if [ -n "$(env_value TS_AUTHKEY "$HERE/.env" || true)" ]; then
  "$HERE/scripts/install-tailscale.sh"
fi

registry_login

log "validating $MODE mode on $HARDWARE..."
(cd "$HERE" && docker compose "${COMPOSE_ARGS[@]}" config --quiet)

log "pulling container images..."
(cd "$HERE" && docker compose "${COMPOSE_ARGS[@]}" pull)

if [ "$START" -ne 1 ]; then
  log "host ready and images pulled."
  printf 'Start with: cd %q &&' "$HERE"
  if [ "${#COMPOSE_ENV[@]}" -gt 0 ]; then
    printf ' env'
    printf ' %q' "${COMPOSE_ENV[@]}"
  fi
  printf ' docker compose'
  printf ' %q' "${COMPOSE_ARGS[@]}"
  printf ' up -d\n'
  exit 0
fi

log "starting $MODE mode on $HARDWARE..."
(cd "$HERE" && docker compose "${COMPOSE_ARGS[@]}" up -d)

HEALTH_PATH=/health
[ "$MODE" != "agent" ] || HEALTH_PATH=/agent/health

log "waiting for $HEALTH_PATH..."
for _ in $(seq 1 36); do
  if curl -fsS "http://127.0.0.1:${HTTP_PORT}${HEALTH_PATH}" >/dev/null 2>&1; then
    log "$MODE runtime healthy."
    log "dashboard: http://127.0.0.1:${HTTP_PORT}/dashboard/"
    exit 0
  fi
  sleep 5
done

die "runtime did not become healthy; inspect: docker compose ${COMPOSE_ARGS[*]} logs eyepop-instance"
