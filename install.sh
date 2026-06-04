#!/usr/bin/env bash
#
# install.sh - set up and launch the EyePop on-premise stack.
#
# Usage:
#   sudo ./install.sh
#   sudo ./install.sh --no-start
#
set -euo pipefail

START=1
[ "${1:-}" = "--no-start" ] && START=0

HERE="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/lib.sh
. "$HERE/scripts/lib.sh"

DEFAULT_EYEPOP_RUNTIME_IMAGE="us-west1-docker.pkg.dev/eyepop-staging/worker/runtime-cuda:v3.36.4"
DEFAULT_EYEPOP_VLM_WORKER_IMAGE="us-west1-docker.pkg.dev/eyepop-staging/vlm-worker/qwen3-instruct:v3.12.2"
COMPOSE_ARGS=(-f compose.yaml)

add_registry_host() {
  local image="$1"
  local host existing

  host="${image%%/*}"
  [ "$host" != "$image" ] || return 0
  printf '%s' "$host" | grep -qE '\.pkg\.dev$' || return 0

  for existing in "${REGISTRY_HOSTS[@]}"; do
    [ "$existing" != "$host" ] || return 0
  done
  REGISTRY_HOSTS+=("$host")
}

image_env_or_default() {
  local name="$1"
  local default="$2"
  local value

  value="$(env_value "$name" "$HERE/.env" || true)"
  printf '%s' "${value:-$default}"
}

require_root
[ -f "$HERE/compose.yaml" ] || die "run from the repository root (compose.yaml not found here)"
[ -d "$HERE/agents.d" ] || die "agents.d directory is missing"
[ -d "$HERE/agents.d/streams" ] || die "agents.d/streams directory is missing"

if [ ! -f "$HERE/.env" ]; then
  cp "$HERE/.env.example" "$HERE/.env"
  die ".env created from .env.example. Fill it in, add .eyepop/creds.json, then re-run."
fi

require_env EYEPOP_URL "$HERE/.env" >/dev/null
require_env EYEPOP_API_KEY "$HERE/.env" >/dev/null
require_env EYEPOP_ACCOUNT_UUID "$HERE/.env" >/dev/null
GOOGLE_CREDS_JSON_VALUE="$(env_value GOOGLE_CREDS_JSON "$HERE/.env" || true)"
GOOGLE_CREDS_JSON_PATH="$(resolve_path "$HERE" "${GOOGLE_CREDS_JSON_VALUE:-.eyepop/creds.json}")"
[ -f "$GOOGLE_CREDS_JSON_PATH" ] || die "Google service account credentials are missing: $GOOGLE_CREDS_JSON_PATH"
[ -r "$GOOGLE_CREDS_JSON_PATH" ] || die "Google service account credentials are not readable: $GOOGLE_CREDS_JSON_PATH"

if ! find "$HERE/agents.d/streams" -maxdepth 1 -type f -name '*.yaml' ! -name '*.example.yaml' | grep -q .; then
  die "add at least one stream config, for example: cp agents.d/streams/camera_1.example.yaml agents.d/streams/camera_1.yaml"
fi

"$HERE/scripts/install-docker.sh"
"$HERE/scripts/install-nvidia.sh"

if [ -n "$(env_value TS_AUTHKEY "$HERE/.env" || true)" ]; then
  "$HERE/scripts/install-tailscale.sh"
else
  log "Tailscale auth key not set; skipping Tailscale setup."
fi

REGISTRY_HOSTS=()
add_registry_host "$(image_env_or_default EYEPOP_RUNTIME_IMAGE "$DEFAULT_EYEPOP_RUNTIME_IMAGE")"
add_registry_host "$(image_env_or_default EYEPOP_VLM_WORKER_IMAGE "$DEFAULT_EYEPOP_VLM_WORKER_IMAGE")"
[ "${#REGISTRY_HOSTS[@]}" -gt 0 ] || die "no Google Artifact Registry image hosts found in compose image settings"

for registry_host in "${REGISTRY_HOSTS[@]}"; do
  log "authenticating Docker to ${registry_host}..."
  docker login -u _json_key --password-stdin "https://${registry_host}" < "$GOOGLE_CREDS_JSON_PATH" >/dev/null \
    || die "Docker login failed for ${registry_host}. Check .eyepop/creds.json and Artifact Registry permissions."
done

log "pulling container images..."
( cd "$HERE" && docker compose "${COMPOSE_ARGS[@]}" pull )

if [ "$START" -ne 1 ]; then
  log "host ready and images pulled. Start when you like: (cd $HERE && docker compose ${COMPOSE_ARGS[*]} up -d)"
  exit 0
fi

log "starting the stack..."
( cd "$HERE" && docker compose "${COMPOSE_ARGS[@]}" up -d )

log "waiting for agent health..."
for _ in $(seq 1 36); do
  if curl -fsS http://127.0.0.1:8080/agent/health >/dev/null 2>&1; then
    log "agent healthy."
    log "  dashboard: http://127.0.0.1:8080/dashboard/"
    log "  health:    curl -sf http://127.0.0.1:8080/agent/health"
    log "  streams:   curl -sf http://127.0.0.1:8080/agent/streams"
    exit 0
  fi
  sleep 5
done

log "stack started but /agent/health is not ready yet. Check: (cd $HERE && docker compose ${COMPOSE_ARGS[*]} logs -f eyepop-instance)"
