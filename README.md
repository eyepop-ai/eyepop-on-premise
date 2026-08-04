# EyePop On-Premise

This repository is the source of truth for installing, configuring, and operating EyePop on-premise. It contains the Docker Compose package and the complete documentation for every supported mode and hardware target.

## Choose a mode

- **Standalone** exposes the local EyePop inference API for applications and SDKs that control each workload.
- **Agent (Beta)** continuously manages configured streams and event outputs without an application holding an inference session open.

Both modes use the same runtime, registration, persistent storage, and billing path. See [Modes](docs/concepts/modes.md) for the full comparison.

## Choose hardware

| Hardware | Architecture | Standalone | Agent |
| --- | --- | --- | --- |
| CPU | amd64 or arm64 | Supported | Beta |
| NVIDIA CUDA | amd64 | Supported | Beta |
| NVIDIA Jetson | arm64 | Supported | Beta |
| Intel OpenVINO | amd64 | Supported | Beta |
| Qualcomm QNN | arm64 | Supported | Beta |

Each hardware selection uses the `latest` tag from `registry.eyepop.ai`. Hardware prerequisites and device access differ, so use the matching [hardware guide](docs/README.md#hardware).

## Install

```shell
git clone https://github.com/eyepop-ai/eyepop-on-premise.git
cd eyepop-on-premise
cp .env.example .env
```

Add the API key and account UUID from [My Servers](https://dashboard.eyepop.ai/servers) to `.env`. Agent mode also needs at least one stream configuration:

```shell
cp agents.d/streams/camera_1.example.yaml agents.d/streams/camera_1.yaml
```

Run the installer with one mode and one hardware target:

```shell
sudo ./install.sh --mode standalone --hardware cpu
sudo ./install.sh --mode agent --hardware nvidia-cuda
```

The installer prompts for the EyePop registry credentials and passes the password to Docker through standard input. The runtime API is available only on `127.0.0.1:8080` by default.

Continue with the [installation guide](docs/getting-started/installation.md) or browse the [documentation index](docs/README.md).

## Validate this repository

```shell
bash scripts/validate.sh
```

The validator renders every mode and hardware combination, checks runtime image references, and verifies local documentation links.
