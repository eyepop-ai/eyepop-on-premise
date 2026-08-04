# EyePop On-Premise documentation

EyePop on-premise runs the EyePop inference runtime inside infrastructure you control. Images, video, streams, and inference results remain on that infrastructure by default. Configured Agent outputs can send selected results to webhook, MQTT, or NATS destinations. The runtime makes outbound connections for registration, model access, and usage delivery.

## Start here

- [Modes](concepts/modes.md): choose Standalone or Agent.
- [Installation](getting-started/installation.md): prepare the host, register the instance, and start it.
- [Runtime configuration](configuration/runtime.md): common configuration and local API behavior.
- [Agent configuration](configuration/agent.md): streams and event outputs for Agent mode.

## Hardware

- [CPU](hardware/cpu.md)
- [NVIDIA CUDA](hardware/nvidia-cuda.md)
- [NVIDIA Jetson](hardware/nvidia-jetson.md)
- [Intel OpenVINO](hardware/intel-openvino.md)
- [Qualcomm QNN](hardware/qualcomm-qnn.md)

## Operations

- [Security and networking](operations/security-and-networking.md)
- [Storage and upgrades](operations/storage-and-upgrades.md)
- [Billing and connectivity](operations/billing-and-connectivity.md)
- [Troubleshooting](operations/troubleshooting.md)
