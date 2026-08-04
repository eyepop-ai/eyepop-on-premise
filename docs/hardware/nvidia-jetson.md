# NVIDIA Jetson

Use this target for Jetson Orin AGX and NX devices. The arm64 image includes the Tegra CUDA libraries expected by the Jetson platform.

- Runtime image: `registry.eyepop.ai/ai/runtime-cuda-jetson:latest`
- Hardware identifier: `nvidia-jetson`
- Container access: the host NVIDIA runtime with compute and utility driver capabilities

## Host requirements

- Jetson Orin AGX or NX
- JetPack 6.2 / L4T r36.4
- Docker with the NVIDIA runtime configured by JetPack

Do not substitute the generic `runtime-cuda` image or mount host CUDA libraries into the container.

```shell
sudo ./install.sh --mode standalone --hardware nvidia-jetson
sudo ./install.sh --mode agent --hardware nvidia-jetson
```

During inference, use `tegrastats` to confirm that `GR3D_FREQ` rises above zero.

For a local V4L2 camera, add `allow-v4l2: true` to the selected instance YAML and add a `/dev/video*` device mapping to the Jetson hardware overlay for each required camera.
