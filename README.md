# EyePop On-Premise

This repository is the Docker Compose package for running EyePop on-premise, and the source of truth for its documentation.

**📖 Read the docs: [docs.eyepop.ai/on-premise](https://docs.eyepop.ai/on-premise)**

The pages under [`docs/gitbook`](docs/gitbook) are published there — edit them here and the site follows.

## Choose hardware

| Hardware | Architecture |
| --- | --- |
| CPU | amd64 or arm64 |
| NVIDIA CUDA | amd64 |
| NVIDIA Jetson | arm64 |
| Intel OpenVINO | amd64 |
| Qualcomm QNN | arm64 |

Most hardware selections use the `latest` tag from `registry.eyepop.ai`; NVIDIA Jetson uses `latest-jetpack6`. Hardware prerequisites and device access differ, so use the matching [hardware guide](docs/gitbook/README.md#hardware).

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

Continue with [First inference](docs/gitbook/getting-started/first-inference.md) to run a Pop against the instance, or browse the [documentation index](docs/gitbook/README.md).

## Validate this repository

```shell
bash scripts/validate.sh
```

The validator renders every mode and hardware combination, checks runtime image references, and verifies local documentation links.
