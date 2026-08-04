# Troubleshooting

## The installer rejects `.env`

Confirm `EYEPOP_URL`, `EYEPOP_API_KEY`, and `EYEPOP_ACCOUNT_UUID` are present and non-empty. Values can be quoted, but the variable name must start the line without `export`.

## Registry login or image pull fails

Use the registry username and password supplied when the server was created in the EyePop dashboard. Authenticate against `registry.eyepop.ai`, and confirm the account can pull the image selected by the hardware overlay.

## The runtime is unhealthy

```shell
docker compose ps
docker compose logs --tail 200 eyepop-instance
curl --verbose http://127.0.0.1:8080/health
```

Agent mode uses `/agent/health`. A first start can take longer while the instance registers and downloads models.

## NVIDIA CUDA is unavailable

Run `nvidia-smi` on the host, then verify Docker access:

```shell
docker run --rm --gpus all ubuntu nvidia-smi -L
```

For Jetson, confirm `/etc/nv_tegra_release` exists and `docker info` lists the `nvidia` runtime. Do not use the generic CUDA overlay on Jetson.

## Intel acceleration is unavailable

Confirm `/dev/dri` exists, the `render` group exists, and `RENDER_GROUP_ID` in `.env` matches the host group ID. Run a representative inference because service health does not confirm which OpenVINO device was selected.

## Qualcomm QNN fails to initialize

Confirm `QAIRT_SDK_ROOT` contains `lib/hexagon-v73/unsigned`, and verify the `FASTRPC_GROUP_ID` and `DMAHEAP_GROUP_ID` values against the host. The supplied overlay is validated for the Innodisk EXEC-Q911 layout.

## Agent has no active streams

Confirm `agents.d/streams` contains at least one `.yaml` file that does not end in `.example.yaml`. Check the source URL from the host and container network, then inspect `/agent/streams` and the runtime logs.

## Usage cannot be delivered

Preserve the private volume, restore outbound access to `compute.eyepop.ai`, and inspect the runtime logs. See [Billing and connectivity](billing-and-connectivity.md) for the retry path.
