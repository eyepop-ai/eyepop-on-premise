# Changelog

## Unreleased

- Run the Intel OpenVINO overlay on the GPU by default. The previous `AUTO` default left OpenVINO with no part of the model, so inference ran on the CPU.
- Support Standalone and Beta Agent modes across CPU, NVIDIA CUDA, NVIDIA Jetson, Intel OpenVINO, and Qualcomm QNN.
- Provide composable mode and hardware overlays with registry-hosted, latest-tagged runtime images.
- Persist private runtime state, queued usage, Agent history, and downloaded models.
- Document installation, configuration, hardware, security, storage, billing, connectivity, and troubleshooting in this repository.
- Use the EyePop `needs-review` label to opt pull requests into CodeRabbit review.
