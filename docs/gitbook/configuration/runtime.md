---
description: Account registration, runtime settings, and local API behavior
icon: gear
---

# Runtime configuration

The shared Compose file passes account registration through environment variables and mounts a mode-specific runtime configuration at `/etc/eyepop-instance.yml`.

### Account environment

| Variable | Required | Purpose |
| --- | --- | --- |
| `EYEPOP_URL` | Yes | Compute API used for registration, model coordination, and usage delivery |
| `EYEPOP_API_KEY` | Yes | Authenticates the runtime |
| `EYEPOP_ACCOUNT_UUID` | Yes | Associates the instance with the EyePop account |
| `EYEPOP_HTTP_PORT` | No | Changes the loopback host port from `8080` |
| `EYEPOP_RUNTIME_IMAGE` | No | Overrides the selected hardware image, normally for a controlled rollback |

The hardware overlays default to the matching `registry.eyepop.ai/ai/runtime-*:latest` image. Do not use an image built for a different accelerator.

### Runtime files

- `instance/standalone.yaml` enables the local runtime API without Agent stream management.
- `instance/agent.yaml` enables Agent configuration and persistent Agent history.
- `compose.yaml` owns networking, health checks, persistent volumes, and account environment.

Both mode files configure:

- `/opt/eyepop/private` for private runtime state and durable usage delivery;
- `/opt/eyepop/models` for the model cache;
- `/tmp` as an 8 GiB in-memory temporary filesystem;
- the dashboard at `/dashboard` and Swagger routes.

### Local API

Compose publishes the API as `127.0.0.1:8080` by default. Set `EYEPOP_HTTP_PORT` to change the host port without changing the container port.

The supplied package has no configurable bind address and cannot be exposed directly on another host interface. To reach it from another machine, place an authenticated reverse proxy or equivalent relay in front of the loopback endpoint as described in [Security and networking](../operations/security-and-networking.md). Do not publish port 8080 directly to the public internet.
