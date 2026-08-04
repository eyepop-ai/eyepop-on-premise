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
printf 'QAIRT_SDK_ROOT=%s\n' "$QAIRT_SDK_ROOT" >> .env
printf 'FASTRPC_GROUP_ID=%s\n' "$(getent group fastrpc | cut -d: -f3)" >> .env
printf 'DMAHEAP_GROUP_ID=%s\n' "$(getent group dmaheap | cut -d: -f3)" >> .env
```

```shell
sudo ./install.sh --mode standalone --hardware qualcomm-qnn
sudo ./install.sh --mode agent --hardware qualcomm-qnn
```

The QNN overlay uses privileged mode and broad `/dev` access because the validated QAIRT stack requires it. Run this target only on a dedicated, trusted host with trusted EyePop images. Other QNN-capable devices require platform-specific validation before use.
