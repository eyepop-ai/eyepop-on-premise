# EyePop On-Premise

The Docker Compose package for running the EyePop inference runtime on your own hardware.

**📖 Docs: [docs.eyepop.ai/deploying/on-premise](https://docs.eyepop.ai/deploying/on-premise)**

Most machines do not need this package. The CLI installs and manages an instance in one command:

```shell
eyepop instance init --pop eyepop.person:latest
```

Use the package here when you need a hardware target the CLI does not provision yet — discrete NVIDIA GPUs or Intel OpenVINO — or when you want to own the Compose project yourself.

## Hardware

| Hardware | Architecture |
| --- | --- |
| CPU | amd64 or arm64 |
| NVIDIA CUDA | amd64 |
| NVIDIA Jetson | arm64 |
| Intel OpenVINO | amd64 |
| Qualcomm QNN | arm64 |

Most targets use the `latest` tag from `registry.eyepop.ai`; NVIDIA Jetson uses `latest-jetpack6`. Prerequisites and device access differ per target — see the [hardware guides](docs/reference/README.md#hardware).

## Install

```shell
git clone https://github.com/eyepop-ai/eyepop-on-premise.git
cd eyepop-on-premise
cp .env.example .env
```

Add the API key and account UUID from [My Servers](https://dashboard.eyepop.ai/servers) to `.env`, then run the installer with the hardware target for this host:

```shell
sudo ./install.sh --mode standalone --hardware cpu
```

The installer prompts for the EyePop registry credentials and passes the password to Docker through standard input. The runtime API is available only on `127.0.0.1:8080` by default.

Full instructions are in [`docs/reference`](docs/reference/README.md).

## Documentation

| Directory | Published | Contents |
| --- | --- | --- |
| [`docs/gitbook`](docs/gitbook) | Yes, to [docs.eyepop.ai/deploying/on-premise](https://docs.eyepop.ai/deploying/on-premise) | One page: create an instance, change its Pop, run inference |
| [`docs/reference`](docs/reference/README.md) | No | This package in full: manual install, configuration keys, hardware, operations |
| [`docs/agent`](docs/agent/README.md) | No | Agent mode, held back until it is announced |

## Validate this repository

```shell
bash scripts/validate.sh
```

The validator renders every mode and hardware combination, checks runtime image references, and verifies local documentation links.
