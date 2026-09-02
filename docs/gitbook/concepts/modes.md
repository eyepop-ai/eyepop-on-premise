# Modes

The mode controls who creates and maintains inference workloads. It does not change the supported hardware, account registration, image delivery, persistent storage, or usage reporting.

## Standalone

Standalone mode exposes the runtime HTTP API on the local host. An application or EyePop SDK creates pipelines, submits media, reads results, and controls the workload lifecycle.

Choose Standalone when:

- an application already owns the request or stream lifecycle;
- workloads are interactive, batch-oriented, or created on demand;
- application code needs direct control of Pop definitions and results.

Standalone uses `instance/standalone.yaml` and the `deployments/modes/standalone.yaml` overlay.

## Agent (Beta)

Agent mode runs persistent stream definitions from `agents.d/streams` and sends selected results through outputs in `agents.d/events-config.yaml`. The runtime stores Agent history in the persistent private-state volume.

Choose Agent when:

- streams should restart with the host;
- configuration, rather than application code, owns the stream lifecycle;
- results should be delivered to webhook, MQTT, or NATS integrations.

Agent is Beta on CPU, NVIDIA CUDA, NVIDIA Jetson, Intel OpenVINO, and Qualcomm QNN. Agent uses `instance/agent.yaml` and the `deployments/modes/agent.yaml` overlay.

## What the modes share

Both modes:

- register the instance with the EyePop account in `.env`;
- bind the local API to `127.0.0.1:8080` by default;
- keep private runtime state and the usage spool in `eyepop_instance_private`;
- cache downloaded models in `eyepop_instance_models`;
- emit usage through the same durable billing path;
- use the selected hardware runtime image from `registry.eyepop.ai`.
