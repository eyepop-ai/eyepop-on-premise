---
description: Account registration, runtime settings, and local API behavior
icon: gear
---

# Runtime configuration

The shared Compose file passes account registration through environment variables and mounts a mode-specific runtime configuration at `/etc/eyepop-instance.yml`.

### Environment file

`.env` holds everything the Compose files read. `install.sh` creates it from `.env.example` on first run and restricts it to `0600`. Values may be quoted; the variable name must start the line without `export`.

| Variable | Required | Purpose |
| --- | --- | --- |
| `EYEPOP_URL` | Yes | Compute API used for registration, model coordination, and usage delivery |
| `EYEPOP_API_KEY` | Yes | Authenticates the runtime |
| `EYEPOP_ACCOUNT_UUID` | Yes | Associates the instance with the EyePop account |
| `EYEPOP_HTTP_PORT` | No | Changes the loopback host port from `8080` |
| `EYEPOP_RUNTIME_IMAGE` | No | Overrides the selected hardware image, normally for a controlled rollback |
| `RENDER_GROUP_ID` | Intel only | Host `render` group ID, added to the container |
| `OPENVINO_DEVICE_TYPE` | No | OpenVINO device selection; defaults to `AUTO` |
| `QAIRT_SDK_ROOT` | Qualcomm only | Host QAIRT SDK directory, bind-mounted read-only at `/opt/qairt` |
| `FASTRPC_GROUP_ID` | Qualcomm only | Host `fastrpc` group ID |
| `DMAHEAP_GROUP_ID` | Qualcomm only | Host `dmaheap` group ID |
| `TS_AUTHKEY` | No | Tailscale auth key; its presence makes the installer set Tailscale up |
| `TS_HOSTNAME` | No | Tailscale hostname for this node; defaults to `eyepop-agent` |

The installer also reads `EYEPOP_REGISTRY_USERNAME` and `EYEPOP_REGISTRY_PASSWORD` from its own environment for unattended installation. Keep those out of `.env` — they are needed only while images are pulled. See [Installation](../getting-started/installation.md).

The hardware overlays default to the matching `registry.eyepop.ai/ai/runtime-*:latest` image. Do not use an image built for a different accelerator.

### Runtime files

- `instance/standalone.yaml` configures the local runtime API.
- `compose.yaml` owns networking, health checks, persistent volumes, and account environment.

The mounted instance file is where runtime behavior is set. The package ships these keys:

| Key | Shipped value | What it does |
| --- | --- | --- |
| `instance-name` | `on-premise-standalone` | Name the instance reports for itself |
| `http-host` | `0.0.0.0` | Container bind address; Compose is what restricts the host to loopback |
| `http-port` | `8080` | Container port |
| `model-cache-dir` | `/opt/eyepop/models` | Model cache, backed by `eyepop_instance_models` |
| `private-config-dir` | `/opt/eyepop/private` | Private state and the usage spool, backed by `eyepop_instance_private` |
| `pipeline-exec` | `/usr/bin/eyepop-pipeline` | Pipeline executable in the image |
| `pipeline-platform-mode` | `default` | Pipeline platform selection |
| `public-file-dir` | `/usr/share/eyepop-ai/public` | Static files served by the runtime |
| `pipeline-log-passthrough` | `true` | Send pipeline logs to the container log |
| `routes.debug.enabled` | `false` | Debug and pipeline-introspection routes |
| `routes.swagger.enabled` | `true` | Swagger UI at `/docs` |

Two more keys are useful in a deployment and are not set by the package:

- `log-level` — `debug`, `info`, `warn`, or `error`; `info` unless set. `EYEPOP_LOG_LEVEL` in the container environment sets it without editing the file.
- `allow-v4l2` — set `true` to let the runtime open local V4L2 camera devices. The devices must also be mapped into the container. See [NVIDIA Jetson](../hardware/nvidia-jetson.md).

Editing a mounted instance file takes effect on the next container recreate, not on a running container.

### Local API

Compose publishes the API as `127.0.0.1:8080` by default. Set `EYEPOP_HTTP_PORT` to change the host port without changing the container port. Node SDK clients in local mode always connect to port `8080`, so leave the default when they are used.

| Endpoint | Purpose |
| --- | --- |
| `/health` | Liveness |
| `/ready` | Readiness, including the pipeline service |
| `/version` | Instance version and build |
| `/metrics` | Prometheus metrics |
| `/docs` | Swagger UI |

None of these require a login in the shipped configuration, and `/metrics` exposes operational detail about the instance. That is why the package binds the published port to the loopback interface.

The supplied package has no configurable bind address and cannot be exposed directly on another host interface. To reach it from another machine, put an authenticated access layer in front of the loopback endpoint — see [Remote access](../operations/remote-access.md). Do not publish port 8080 directly to the public internet.

### Next steps

- [First inference](../getting-started/first-inference.md) — verify the instance and run a Pop against it
- [Security and networking](../operations/security-and-networking.md) — exposure, secrets, and outbound requirements
