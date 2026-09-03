# Compose package reference (not published)

The Docker Compose package in this repository, documented in full. These pages
are not published: [docs.eyepop.ai/deploying/on-premise](https://docs.eyepop.ai/deploying/on-premise)
carries one page built on `eyepop instance init`, and this is the depth
behind it — the manual install, every configuration key, and operations.

The package supports all five hardware targets and both modes. The CLI
provisions `cpu`, `cuda-jetpack6`, and `qnn` only. Use one or the other on a
given host, not both: they share the Compose project name `eyepop-on-premise`.

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
