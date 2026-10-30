---
description: Run the EyePop runtime on your own hardware
icon: server
---

# On-Premise

EyePop runs your pops in one of two places: in EyePop's cloud, or on hardware you control. On-premise, the EyePop runtime runs on one of your own machines, next to your cameras and your data, and inference happens there.

### How it works

An on-premise **instance** is the EyePop runtime installed on one machine with Docker. It serves one pop, a single ability or a pipeline of several, and uses the machine's accelerator when it has one: an NVIDIA or Intel GPU, an Intel or Qualcomm NPU, or else the CPU.

You set an instance up and manage it with the [EyePop CLI](https://docs.eyepop.ai/developer-documentation/cli/on-premise), which detects the hardware, starts the runtime, and changes what it serves. Applications on the machine send it images and video at `http://127.0.0.1:8080`, through the CLI, the EyePop SDKs in local mode, or plain HTTP.

The instance still connects to EyePop, over outbound HTTPS. It registers with your account when it starts and downloads the models its pop needs. Allow the machine to reach `registry.eyepop.ai` for the runtime image, `compute.eyepop.ai` and `dataset-api.eyepop.ai`, and the storage URLs models are downloaded from.

### On-premise or cloud

|  | Cloud | On-premise |
| --- | --- | --- |
| **Where inference runs** | On EyePop's servers | On your machine, on its CPU, GPU or NPU |
| **Your images and video** | Uploaded to EyePop for processing | Processed on the machine; not uploaded |
| **Latency** | Every request travels over the internet | No round trip; the model runs next to the camera |
| **Network** | Needed for every request | Needed to start and to download models; inference runs locally |
| **Capacity** | Grows with the sessions and deployments you start | What one machine can do, serving one pop |
| **Hardware** | Chosen and maintained by EyePop | Yours to choose and maintain, from a CPU to a GPU or NPU |
| **Setup** | Nothing to install | Docker and the EyePop CLI on the machine, then one command |

Choose on-premise when media must not leave the site, when you need answers with no network delay, or when sending video to the cloud would cost too much bandwidth. Choose the [cloud](https://docs.eyepop.ai/developer-documentation/deploying/cloud) to start without hardware, or when your load varies.

### Supported platforms

| Platform | Hardware | CPU architecture |
| --- | --- | --- |
| CPU | Any machine; inference runs on the CPU | x86_64, ARM64 |
| NVIDIA GPU | NVIDIA GPUs, and NVIDIA Jetson on JetPack 7 or later | x86_64, ARM64 |
| NVIDIA Jetson | Jetson Orin on JetPack 6 | ARM64 |
| Intel | Intel GPUs, and the NPU of an Intel Core Ultra | x86_64 |
| Qualcomm | Dragonwing IQ-9075, on its Hexagon NPU | ARM64 |

Each platform has its own prerequisites, such as the NVIDIA Container Toolkit or Qualcomm's AI Runtime SDK. The CLI guide lists them.

### Get started

[On-Premise Instances](https://docs.eyepop.ai/developer-documentation/cli/on-premise) in the CLI documentation walks you through your first instance step by step, then covers each platform's prerequisites, every setting, model optimization, and running and removing an instance.
