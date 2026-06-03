#!/usr/bin/env bash

log() {
  printf '\n[install] %s\n' "$*"
}

die() {
  printf '\n[install] ERROR: %s\n' "$*" >&2
  exit 1
}

require_root() {
  [ "$(id -u)" -eq 0 ] || die "run as root: sudo $0"
}

require_apt() {
  command -v apt-get >/dev/null 2>&1 || die "this installer supports Debian/Ubuntu (apt) hosts"
  export DEBIAN_FRONTEND=noninteractive
}

env_value() {
  local name="$1"
  local file="$2"
  local line value

  line="$(grep -E "^[[:space:]]*${name}=" "$file" | tail -n 1 || true)"
  [ -n "$line" ] || return 1
  value="${line#*=}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  if [ "${#value}" -ge 2 ]; then
    if { [ "${value:0:1}" = "'" ] && [ "${value: -1}" = "'" ]; } ||
       { [ "${value:0:1}" = '"' ] && [ "${value: -1}" = '"' ]; }; then
      value="${value:1:${#value}-2}"
    fi
  fi

  printf '%s' "$value"
}

require_env() {
  local name="$1"
  local file="$2"
  local value

  value="$(env_value "$name" "$file" || true)"
  [ -n "$value" ] || die "$name is empty in $file"
  printf '%s' "$value"
}

resolve_path() {
  local root="$1"
  local path="$2"

  if [ "${path:0:1}" = "/" ]; then
    printf '%s' "$path"
  else
    printf '%s/%s' "$root" "$path"
  fi
}
