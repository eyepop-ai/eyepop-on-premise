# NVIDIA CUDA

Use this target for discrete and data-center NVIDIA GPUs on amd64 Linux. NVIDIA Jetson uses a different image and host runtime.

- Runtime image: `registry.eyepop.ai/ai/runtime-cuda:latest`
- Hardware identifier: `nvidia-cuda`
- Container access: one NVIDIA GPU through the Compose device reservation

## Host requirements

- A CUDA-compatible NVIDIA GPU
- A working NVIDIA driver (`nvidia-smi` succeeds)
- A Debian or Ubuntu release supported by both Docker's apt repository and NVIDIA Container Toolkit 1.19.1-1

The installer derives the Docker repository from the host distribution and codename, installs NVIDIA Container Toolkit 1.19.1-1 through apt, configures the Docker runtime, and verifies GPU access with the authenticated EyePop runtime image. It stops installation rather than falling back silently to CPU.

```shell
sudo ./install.sh --mode standalone --hardware nvidia-cuda
sudo ./install.sh --mode agent --hardware nvidia-cuda
```

After startup, run a representative inference while observing `nvidia-smi`. Health and readiness confirm service availability, not accelerator utilization.

If setup fails after an apt repository, toolkit package, driver, or Docker runtime change, correct the reported host configuration and rerun the installer. Reboot after a driver update, confirm host `nvidia-smi` succeeds, then rerun the installer and its container GPU verification.
