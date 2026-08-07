# NVIDIA Jetson

Use this target for Jetson Orin AGX and NX devices. The arm64 image includes the Tegra CUDA libraries expected by the Jetson platform.

- Runtime image: `registry.eyepop.ai/ai/runtime-cuda:latest-jetpack6`
- Hardware identifier: `nvidia-jetson`
- Container access: the host NVIDIA runtime with compute and utility driver capabilities

## Host requirements

- Jetson Orin AGX or NX
- JetPack 6.2.1 with Jetson Linux (L4T) 36.4.4; `registry.eyepop.ai/ai/runtime-cuda:latest-jetpack6` is validated on this release pair
- Docker with the NVIDIA runtime configured by JetPack

The JetPack build lives in the `runtime-cuda` repository under a `-jetpack6` tag suffix — it is a tag, not a separate image. Keep the suffix: the untagged `runtime-cuda:latest` is the datacenter build and does not carry the Orin compatibility libraries. Do not mount host CUDA libraries into the container.

```shell
sudo ./install.sh --mode standalone --hardware nvidia-jetson
sudo ./install.sh --mode agent --hardware nvidia-jetson
```

During inference, use `tegrastats` to confirm that `GR3D_FREQ` rises above zero.

For a local V4L2 camera, add `allow-v4l2: true` to the selected instance YAML. Discover devices with `ls -1 /dev/video*`, then add an explicit one-to-one mapping such as `/dev/video0:/dev/video0` to the Jetson hardware overlay for each required camera.
