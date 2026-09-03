---
description: Prepare the host, register the instance, and start the runtime
icon: download
---

# Installation

### Requirements

- A supported Linux host for the selected [hardware target](../README.md#hardware)
- Docker Engine with the Compose plugin
- Outbound HTTPS access to the EyePop registry and APIs
- An EyePop server registration from [My Servers](https://dashboard.eyepop.ai/servers)

The installer supports Debian and Ubuntu hosts that use `apt`. Hardware guides list additional drivers, runtimes, and device access.

### 1. Clone and configure

```shell
git clone https://github.com/eyepop-ai/eyepop-on-premise.git
cd eyepop-on-premise
cp .env.example .env
```

Set these values in `.env`:

```dotenv
EYEPOP_URL=https://compute.eyepop.ai
EYEPOP_API_KEY=YOUR_API_KEY
EYEPOP_ACCOUNT_UUID=YOUR_ACCOUNT_UUID
```

Treat `.env` as a secret. It is ignored by Git.

### 2. Install and start

Pass the hardware identifier for this host:

```shell
sudo ./install.sh --mode standalone --hardware cpu
```

Valid hardware identifiers are `cpu`, `nvidia-cuda`, `nvidia-jetson`, `intel-openvino`, and `qualcomm-qnn`.

The installer:

1. validates the host integration for the selected hardware;
2. installs Docker when necessary;
3. prompts for the registry credentials supplied by the EyePop dashboard;
4. pulls the hardware-specific runtime image (`latest` for standard targets and `latest-jetpack6` for NVIDIA Jetson);
5. creates the persistent volumes and starts the runtime;
6. waits for the runtime to report healthy.

For unattended installation, run the installer in an existing root automation context and inject registry credentials through its secret manager:

```shell
EYEPOP_REGISTRY_USERNAME="$EYEPOP_REGISTRY_USERNAME" \
EYEPOP_REGISTRY_PASSWORD="$EYEPOP_REGISTRY_PASSWORD" \
./install.sh --mode standalone --hardware cpu
```

Do not use this form from an unprivileged shell. Use short-lived automation secrets and avoid saving the registry password in `.env`, command arguments, or shell history.

Docker stores registry authentication in its configured credential store. After the image pull, run `sudo docker logout registry.eyepop.ai` when the host does not need unattended updates. When automation uses an isolated configuration directory, use that same root-side directory for logout (`sudo docker --config /path/to/docker-config logout registry.eyepop.ai`), then remove it after installation.

Use `--no-start` to prepare the host and pull images without starting the runtime.

### 3. Verify

```shell
curl --fail http://127.0.0.1:8080/health
curl --fail http://127.0.0.1:8080/ready
docker compose logs -f eyepop-instance
```

The first inference may take longer while the runtime downloads and caches models.

Replace `8080` in the verification URLs when `EYEPOP_HTTP_PORT` selects another host port.

Continue with [First inference](first-inference.md) to run a Pop against the instance.

### Compose command shape

The installer combines the shared file with the mode overlay and one hardware overlay. Use the same three files for later Compose operations:

```shell
docker compose --env-file .env \
  -f compose.yaml \
  -f deployments/modes/standalone.yaml \
  -f deployments/hardware/cpu.yaml \
  ps
```

Replace the hardware overlay with the deployed selection. Run commands from the repository root so bind-mount paths resolve correctly.
