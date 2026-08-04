# Qualcomm QNN

Use this arm64 target for the Hexagon NPU on the validated Innodisk EXEC-Q911 platform.

- Runtime image: `registry.eyepop.ai/ai/runtime-qnn:latest`
- Hardware identifier: `qualcomm-qnn`
- Container access: FastRPC, DMA-heap, QAIRT libraries, host libraries, and privileged device access

## Host requirements

- Innodisk EXEC-Q911 with the Innodisk-provided Ubuntu image
- QAIRT Community 2.41.0.251128 installed on the host
- `fastrpc` and `dmaheap` host groups

Use [iQ-Studio](https://github.com/InnoIPA/iQ-Studio) for device flashing and BSP setup. Add the host integration values to `.env`:

```shell
QAIRT_SDK_ROOT=/opt/qcom/aistack/qairt/2.41.0.251128
FASTRPC_GROUP_ID="$(getent group fastrpc | cut -d: -f3)"
DMAHEAP_GROUP_ID="$(getent group dmaheap | cut -d: -f3)"
[ -n "$FASTRPC_GROUP_ID" ] || { echo 'fastrpc group not found' >&2; exit 1; }
[ -n "$DMAHEAP_GROUP_ID" ] || { echo 'dmaheap group not found' >&2; exit 1; }
sed -i \
  -e '/^QAIRT_SDK_ROOT=/d' \
  -e '/^FASTRPC_GROUP_ID=/d' \
  -e '/^DMAHEAP_GROUP_ID=/d' \
  .env
printf 'QAIRT_SDK_ROOT=%s\n' "$QAIRT_SDK_ROOT" >> .env
printf 'FASTRPC_GROUP_ID=%s\n' "$FASTRPC_GROUP_ID" >> .env
printf 'DMAHEAP_GROUP_ID=%s\n' "$DMAHEAP_GROUP_ID" >> .env
```

```shell
sudo ./install.sh --mode standalone --hardware qualcomm-qnn
sudo ./install.sh --mode agent --hardware qualcomm-qnn
```

The QNN overlay uses privileged mode and broad `/dev` access because the validated QAIRT stack requires it. Run this target only on a dedicated, trusted host with trusted EyePop images. Other QNN-capable devices require platform-specific validation before use.
