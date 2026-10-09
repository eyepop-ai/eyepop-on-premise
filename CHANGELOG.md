# Changelog

## Unreleased

- Fix the Agent stream template's insight-events key so a copied template passes the strict config loader (`events.insights`, not a job-level `insights.enabled`).
- Validate the shipped `agents.d` templates against the eyepop-instance stream loader in CI, simulating the documented copy-to-real-name onboarding flow.
- Support Standalone and Beta Agent modes across CPU, NVIDIA CUDA, NVIDIA Jetson, Intel OpenVINO, and Qualcomm QNN.
- Provide composable mode and hardware overlays with registry-hosted, latest-tagged runtime images.
- Persist private runtime state, queued usage, Agent history, and downloaded models.
- Document installation, configuration, hardware, security, storage, billing, connectivity, and troubleshooting in this repository.
- Use the EyePop `needs-review` label to opt pull requests into CodeRabbit review.
