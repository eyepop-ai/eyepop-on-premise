#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODES=(standalone agent)
HARDWARE=(cpu nvidia-cuda nvidia-jetson intel-openvino qualcomm-qnn)
REQUIRED_DOCS=(
  README.md
  docs/README.md
  docs/concepts/modes.md
  docs/getting-started/installation.md
  docs/configuration/runtime.md
  docs/configuration/agent.md
  docs/hardware/cpu.md
  docs/hardware/nvidia-cuda.md
  docs/hardware/nvidia-jetson.md
  docs/hardware/intel-openvino.md
  docs/hardware/qualcomm-qnn.md
  docs/operations/security-and-networking.md
  docs/operations/storage-and-upgrades.md
  docs/operations/billing-and-connectivity.md
  docs/operations/troubleshooting.md
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
      config --no-interpolate >/dev/null
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
    r"\b(?:[a-z0-9.-]+(?::[0-9]+)?/)+runtime-[a-z0-9-]+:[a-zA-Z0-9._-]+"
)
approved_pattern = re.compile(
    r"^registry\.eyepop\.ai/ai/runtime-[a-z0-9-]+:latest$"
)

for document in root.rglob("*"):
    if not document.is_file() or ".git" in document.parts:
        continue
    if "superpowers/plans" in document.as_posix() or document.name == "CHANGELOG.md":
        continue
    try:
        content = document.read_text()
    except UnicodeDecodeError:
        continue
    for image in runtime_pattern.findall(content):
        if not approved_pattern.match(image):
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
        if path and not (document.parent / path).resolve().exists():
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
