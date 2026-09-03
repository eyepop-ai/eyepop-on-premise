---
description: Run the EyePop inference runtime on your own hardware
icon: server
---

# On-Premise

An on-premise **instance** is the EyePop runtime installed on one machine, serving one Pop. Media and inference results stay on that machine. The runtime reaches out to EyePop only to register, pull models, and report usage.

The CLI installs and manages an instance for you:

```bash
eyepop instance init --pop eyepop.person:latest
```

Once a machine has an instance, `eyepop run` goes to it and no EyePop compute is started.

### What you need

* A Linux host with Docker and Compose v2
* An API key from [the dashboard](https://dashboard.eyepop.ai), and a signed-in CLI (`eyepop auth login`)
* Outbound HTTPS to `registry.eyepop.ai` and `compute.eyepop.ai`

### Supported hardware

| Hardware | Profile |
| --- | --- |
| Any machine, no accelerator | `cpu` |
| NVIDIA Jetson on JetPack 6 | `cuda-jetpack6` |
| Qualcomm Dragonwing, QAIRT SDK on the host | `qnn` |

`eyepop instance init` detects the profile. Discrete NVIDIA GPUs and Intel OpenVINO run through the Docker Compose package in [eyepop-ai/eyepop-on-premise](https://github.com/eyepop-ai/eyepop-on-premise) instead — `init` does not provision them yet.

### Next steps

* [Quickstart](quickstart.md) — create an instance, change its Pop, and run inference against it
* [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise) — every `instance` command, hardware profiles, and repair
