# NVIDIA CUDA

Use this target for discrete and data-center NVIDIA GPUs on amd64 Linux. NVIDIA Jetson uses a different image and host runtime.

- Runtime image: `registry.eyepop.ai/ai/runtime-cuda:latest`
- Hardware identifier: `nvidia-cuda`
- Container access: one NVIDIA GPU through the Compose device reservation

## Host requirements

- A CUDA-compatible NVIDIA GPU
- A working NVIDIA driver (`nvidia-smi` succeeds)
- NVIDIA Container Toolkit

The installer configures the NVIDIA Container Toolkit when it is not present and verifies GPU access from Docker.

```shell
sudo ./install.sh --mode standalone --hardware nvidia-cuda
sudo ./install.sh --mode agent --hardware nvidia-cuda
```

After startup, run a representative inference while observing `nvidia-smi`. Health and readiness confirm service availability, not accelerator utilization.
