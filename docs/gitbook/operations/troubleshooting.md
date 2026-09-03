---
description: Diagnose installation, startup, and inference failures
icon: wrench
---

# Troubleshooting

### The installer rejects `.env`

Confirm `EYEPOP_URL`, `EYEPOP_API_KEY`, and `EYEPOP_ACCOUNT_UUID` are present and non-empty. Values can be quoted, but the variable name must start the line without `export`.

### Registry login or image pull fails

Use the registry username and password supplied when the server was created in the EyePop dashboard. Authenticate against `registry.eyepop.ai`, and confirm the account can pull the image selected by the hardware overlay.

### The runtime is unhealthy

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  ps
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  logs --tail 200 eyepop-instance
curl --verbose http://127.0.0.1:8080/health
```

Replace the mode and hardware overlays with the deployed selection. Agent mode uses `/agent/health`; Standalone uses `/health`. Replace port `8080` when `EYEPOP_HTTP_PORT` selects another host port. A first start can take longer while the instance registers and downloads models.

### NVIDIA CUDA is unavailable

Run `nvidia-smi` on the host, then verify Docker access:

```shell
docker run --rm --gpus all --entrypoint nvidia-smi \
  "${EYEPOP_RUNTIME_IMAGE:-registry.eyepop.ai/ai/runtime-cuda:latest}" \
  -L
```

For Jetson, confirm `/etc/nv_tegra_release` exists and `docker info` lists the `nvidia` runtime. Do not use the generic CUDA overlay on Jetson.

### Intel acceleration is unavailable

Confirm `/dev/dri` exists, the `render` group exists, and `RENDER_GROUP_ID` in `.env` matches the host group ID. Run a representative inference because service health does not confirm which OpenVINO device was selected.

### Qualcomm QNN fails to initialize

Confirm `QAIRT_SDK_ROOT` contains `lib/hexagon-v73/unsigned`, and verify the `FASTRPC_GROUP_ID` and `DMAHEAP_GROUP_ID` values against the host. The supplied overlay is validated for the Innodisk EXEC-Q911 layout.

### The host port is already in use

`docker compose up` fails to bind `127.0.0.1:8080` when another service holds the port. Find it with `sudo lsof -i :8080`, then either stop it or set `EYEPOP_HTTP_PORT` in `.env` to a free port and recreate the container. Node SDK clients in local mode always use port `8080`; move the other service instead when they are involved.

### Agent rejects a stream file

Stream configuration is parsed strictly, and the message names the file and line:

- `field <name> not found in type config.StreamJob` — an unrecognized key. Check it against [Agent configuration](../configuration/agent.md#jobs).
- `filename must match stream id "<id>.yaml"` — the file name and the `id` in it disagree. Rename the file, or remove `id` and let it default to the file name.
- `stream config files must live under streams/` — the file is directly under `agents.d`; move it into `agents.d/streams/`.
- `source.source_type must be URL or V4L2` — the source block has neither `source_type`/`url` nor the older `type`/`uri` pair.
- `pop or pop_file is required` — the job has no Pop; set exactly one of the two.

### Agent has no active streams

Confirm `agents.d/streams` contains at least one `.yaml` file that does not end in `.example.yaml`. Check the source URL from the host and container network, then inspect `/agent/streams` and the runtime logs.

### A camera source never connects

Check the URL from the host first, then from inside the container — a source that works on the host but not in the container is a network path problem, not a configuration one:

```shell
docker compose --project-name eyepop-on-premise --env-file .env \
  -f compose.yaml \
  -f deployments/modes/agent.yaml \
  -f deployments/hardware/cpu.yaml \
  exec eyepop-instance curl -sS --max-time 5 -o /dev/null http://camera-host
```

For cameras on another network, see [Remote access](remote-access.md).

### Usage cannot be delivered

Preserve the private volume, restore outbound access to `compute.eyepop.ai`, and inspect the runtime logs. See [Billing and connectivity](billing-and-connectivity.md) for the retry path.
