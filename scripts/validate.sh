#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODES=(standalone agent)
HARDWARE=(cpu nvidia-cuda nvidia-jetson intel-openvino qualcomm-qnn)
REQUIRED_DOCS=(
  README.md
  docs/gitbook/README.md
  docs/gitbook/getting-started/installation.md
  docs/gitbook/getting-started/first-inference.md
  docs/gitbook/configuration/runtime.md
  docs/gitbook/hardware/cpu.md
  docs/gitbook/hardware/nvidia-cuda.md
  docs/gitbook/hardware/nvidia-jetson.md
  docs/gitbook/hardware/intel-openvino.md
  docs/gitbook/hardware/qualcomm-qnn.md
  docs/gitbook/operations/remote-access.md
  docs/gitbook/operations/security-and-networking.md
  docs/gitbook/operations/storage-and-upgrades.md
  docs/gitbook/operations/billing-and-connectivity.md
  docs/gitbook/operations/troubleshooting.md
)

fail() {
  printf 'validation failed: %s\n' "$*" >&2
  exit 1
}

for path in "${REQUIRED_DOCS[@]}"; do
  [ -f "$ROOT/$path" ] || fail "missing $path"
done

command -v docker >/dev/null 2>&1 || fail "docker is required"
docker compose version >/dev/null 2>&1 || fail "Docker Compose is required"
command -v shellcheck >/dev/null 2>&1 || fail "shellcheck is required"
bash -n "$ROOT/install.sh" "$ROOT"/scripts/*.sh
shellcheck --severity=warning "$ROOT/install.sh" "$ROOT"/scripts/*.sh

tracked_streams="$(git -C "$ROOT" ls-files -- 'agents.d/streams/*.yaml')" \
  || fail "could not enumerate tracked Agent stream configuration"
tracked_streams="$(printf '%s\n' "$tracked_streams" | sed '/\.example\.yaml$/d')"
[ -z "$tracked_streams" ] || fail "tracked Agent stream configuration may contain credentials: $tracked_streams"

for mode in "${MODES[@]}"; do
  mode_file="$ROOT/deployments/modes/$mode.yaml"
  [ -f "$mode_file" ] || fail "missing deployments/modes/$mode.yaml"

  for hardware in "${HARDWARE[@]}"; do
    hardware_file="$ROOT/deployments/hardware/$hardware.yaml"
    [ -f "$hardware_file" ] || fail "missing deployments/hardware/$hardware.yaml"

    EYEPOP_URL=https://compute.eyepop.ai \
      EYEPOP_API_KEY=validation-key \
      EYEPOP_ACCOUNT_UUID=00000000-0000-0000-0000-000000000000 \
      RENDER_GROUP_ID=109 \
      FASTRPC_GROUP_ID=1001 \
      DMAHEAP_GROUP_ID=1002 \
      QAIRT_SDK_ROOT=/opt/qairt \
      docker compose \
      --project-directory "$ROOT" \
      --env-file "$ROOT/.env.example" \
      -f "$ROOT/compose.yaml" \
      -f "$mode_file" \
      -f "$hardware_file" \
      config >/dev/null
  done
done

python3 - "$ROOT" <<'PY'
import re
import sys
from pathlib import Path
from urllib.parse import unquote

root = Path(sys.argv[1])
missing = []
invalid_images = []
runtime_pattern = re.compile(
    r"(?<![a-zA-Z0-9._/])"
    r"(?:(?:[a-z0-9][a-z0-9.-]*(?::[0-9]+)?/)?"
    r"(?:[a-z0-9][a-z0-9._-]*/)*)"
    r"runtime-[a-z0-9-]+"
    r"(?::[a-zA-Z0-9._-]+|@sha256:[a-fA-F0-9]{64})"
)
approved_pattern = re.compile(
    r"^registry\.eyepop\.ai/ai/"
    r"(?:runtime-[a-z0-9-]+:latest|runtime-cuda:latest-jetpack6)$"
)

for document in root.rglob("*"):
    if not document.is_file() or ".git" in document.parts:
        continue
    if document == root / "scripts/validate.sh":
        continue
    if "superpowers/plans" in document.as_posix() or document.name == "CHANGELOG.md":
        continue
    try:
        content = document.read_text()
    except UnicodeDecodeError:
        continue
    for image in runtime_pattern.findall(content):
        if not approved_pattern.fullmatch(image):
            invalid_images.append(f"{document.relative_to(root)} -> {image}")

for document in [root / "README.md", *(root / "docs").rglob("*.md")]:
    if "superpowers/plans" in document.as_posix():
        continue
    content = document.read_text()
    for target in re.findall(r"!?\[[^]]+\]\(([^)]+)\)", content):
        target = target.strip().split(maxsplit=1)[0].strip("<>")
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        path = unquote(target.split("#", 1)[0])
        if path:
            resolved = (document.parent / path).resolve()
            try:
                resolved.relative_to(root)
            except ValueError:
                missing.append(f"{document.relative_to(root)} -> {target} (outside repository)")
            else:
                if not resolved.exists():
                    missing.append(f"{document.relative_to(root)} -> {target}")

if invalid_images:
    print(
        "validation failed: public examples must use "
        "registry.eyepop.ai runtime images with the latest tag",
        file=sys.stderr,
    )
    print("\n".join(invalid_images), file=sys.stderr)
    raise SystemExit(1)

if missing:
    print("validation failed: broken local Markdown links", file=sys.stderr)
    print("\n".join(missing), file=sys.stderr)
    raise SystemExit(1)
PY

printf 'validated %d mode/hardware combinations and canonical documentation\n' \
  "$(( ${#MODES[@]} * ${#HARDWARE[@]} ))"
