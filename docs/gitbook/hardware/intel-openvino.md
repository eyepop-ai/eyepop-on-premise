---
description: Intel GPU and NPU acceleration on amd64 hosts
icon: microchip
---

# Intel OpenVINO

Use this target for Intel GPU or NPU acceleration on an amd64 host.

- Runtime image: `registry.eyepop.ai/ai/runtime-openvino:latest`
- Hardware identifier: `intel-openvino`
- Container access: `/dev/dri` and the host `render` group

### Host requirements

- Ubuntu 24.04 on amd64
- Intel compute runtime for the selected accelerator
- A render device under `/dev/dri`

Add the host render group ID to `.env`:

```shell
RENDER_GROUP_ID="$(getent group render | cut -d: -f3)"
[ -n "$RENDER_GROUP_ID" ] || { echo 'render group not found' >&2; exit 1; }
sed -i '/^RENDER_GROUP_ID=/d' .env
printf 'RENDER_GROUP_ID=%s\n' "$RENDER_GROUP_ID" >> .env
```

`OPENVINO_DEVICE_TYPE` defaults to `AUTO`. Set it to `GPU`, `NPU`, or another target supported by the installed Intel runtime when the deployment needs an explicit selection.

```shell
sudo ./install.sh --mode standalone --hardware intel-openvino
sudo ./install.sh --mode agent --hardware intel-openvino
```

Run a representative inference to confirm accelerator use. Runtime health alone does not prove that OpenVINO selected the intended device.
