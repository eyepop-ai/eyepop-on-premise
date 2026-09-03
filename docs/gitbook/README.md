---
description: Run the EyePop inference runtime on infrastructure you control
icon: server
---

# On-Premise

EyePop on-premise runs the EyePop inference runtime inside infrastructure you control. Images, video, streams, and inference results remain on that infrastructure by default. The runtime makes outbound connections for registration, model access, and usage delivery.

These pages cover the Docker Compose package in [eyepop-ai/eyepop-on-premise](https://github.com/eyepop-ai/eyepop-on-premise), which supports both modes and all five hardware targets. The EyePop CLI can also install and manage a single-Pop instance with `eyepop instance init` — see [On-Premise Instances](https://docs.eyepop.ai/cli/on-premise). Use one or the other on a given host, not both.

### Start here

- [Installation](getting-started/installation.md): prepare the host, register the instance, and start it.
- [First inference](getting-started/first-inference.md): confirm the instance is serving and run a Pop against it.
- [Runtime configuration](configuration/runtime.md): environment, runtime settings, and local API behavior.

### Hardware

- [CPU](hardware/cpu.md)
- [NVIDIA CUDA](hardware/nvidia-cuda.md)
- [NVIDIA Jetson](hardware/nvidia-jetson.md)
- [Intel OpenVINO](hardware/intel-openvino.md)
- [Qualcomm QNN](hardware/qualcomm-qnn.md)

### Operations

- [Remote access](operations/remote-access.md)
- [Security and networking](operations/security-and-networking.md)
- [Storage and upgrades](operations/storage-and-upgrades.md)
- [Billing and connectivity](operations/billing-and-connectivity.md)
- [Troubleshooting](operations/troubleshooting.md)
